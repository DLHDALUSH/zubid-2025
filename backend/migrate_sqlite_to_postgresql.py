#!/usr/bin/env python
"""
Database Migration Script: SQLite to PostgreSQL
This script migrates data from SQLite development database to PostgreSQL production database.

Usage:
    python migrate_sqlite_to_postgresql.py

Prerequisites:
    1. PostgreSQL database must be created and accessible
    2. Set DATABASE_URI environment variable to PostgreSQL connection string
    3. SQLite database file should be in backend/instance/auction.db (or specify path)
"""

import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

try:
    from sqlalchemy import create_engine, inspect, text
    import sqlite3
except ImportError as e:
    print(f"Error: Missing required package: {e}")
    print("Please install: pip install sqlalchemy psycopg2-binary")
    sys.exit(1)

def get_sqlite_connection(sqlite_path):
    """Get SQLite connection"""
    if not os.path.exists(sqlite_path):
        raise FileNotFoundError(f"SQLite database not found at: {sqlite_path}")
    return sqlite3.connect(sqlite_path)

def get_postgresql_engine(postgresql_uri):
    """Get PostgreSQL engine"""
    try:
        engine = create_engine(postgresql_uri)
        # Test connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return engine
    except Exception as e:
        raise ConnectionError(f"Failed to connect to PostgreSQL: {e}")

def migrate_table_data(sqlite_conn, pg_engine, table_name, columns, order_by=None):
    """Migrate data from SQLite table to PostgreSQL table"""
    print(f"\nMigrating {table_name}...")
    
    # Build SELECT query
    column_list = ', '.join(columns)
    query = f"SELECT {column_list} FROM {table_name}"
    if order_by:
        query += f" ORDER BY {order_by}"
    
    # Fetch data from SQLite
    cursor = sqlite_conn.cursor()
    cursor.execute(query)
    rows = cursor.fetchall()
    
    if not rows:
        print(f"  No data to migrate for {table_name}")
        return 0
    
    # Insert into PostgreSQL
    with pg_engine.connect() as conn:
        # Use transaction
        trans = conn.begin()
        try:
            inserted = 0
            for row in rows:
                # Build INSERT query
                placeholders = ', '.join(['%s'] * len(columns))
                insert_query = f"""
                    INSERT INTO {table_name} ({column_list})
                    VALUES ({placeholders})
                    ON CONFLICT DO NOTHING
                """
                
                # Execute insert
                conn.execute(text(insert_query), row)
                inserted += 1
            
            trans.commit()
            print(f"  Migrated {inserted} rows to {table_name}")
            return inserted
        except Exception as e:
            trans.rollback()
            print(f"  ERROR migrating {table_name}: {e}")
            raise

def migrate_database(sqlite_path, postgresql_uri):
    """Main migration function"""
    print("=" * 60)
    print("ZUBID Database Migration: SQLite to PostgreSQL")
    print("=" * 60)
    print()
    
    # Connect to databases
    print("Connecting to databases...")
    sqlite_conn = get_sqlite_connection(sqlite_path)
    pg_engine = get_postgresql_engine(postgresql_uri)
    print("[OK] Connected to both databases")
    
    # Verify PostgreSQL schema exists
    print("\nVerifying PostgreSQL schema...")
    inspector = inspect(pg_engine)
    pg_tables = inspector.get_table_names()
    
    required_tables = ['user', 'category', 'auction', 'image', 'bid', 'invoice']
    missing_tables = [t for t in required_tables if t not in pg_tables]
    
    if missing_tables:
        print(f"ERROR: PostgreSQL database is missing tables: {missing_tables}")
        print("Please run db.create_all() first to create the schema.")
        return False
    
    print("[OK] PostgreSQL schema verified")
    
    # Migration order (respecting foreign key constraints)
    migrations = [
        {
            'table': 'category',
            'columns': ['id', 'name', 'description'],
            'order_by': 'id'
        },
        {
            'table': 'user',
            'columns': ['id', 'username', 'email', 'password_hash', 'id_number', 
                       'birth_date', 'biometric_data', 'profile_photo', 'address', 
                       'phone', 'role', 'created_at'],
            'order_by': 'id'
        },
        {
            'table': 'auction',
            'columns': ['id', 'item_name', 'description', 'item_condition', 
                       'starting_bid', 'current_bid', 'bid_increment', 
                       'start_time', 'end_time', 'seller_id', 'category_id', 
                       'winner_id', 'status', 'featured', 'qr_code_url', 'video_url'],
            'order_by': 'id'
        },
        {
            'table': 'image',
            'columns': ['id', 'auction_id', 'url', 'is_primary'],
            'order_by': 'id'
        },
        {
            'table': 'bid',
            'columns': ['id', 'auction_id', 'user_id', 'amount', 'timestamp', 
                       'is_auto_bid', 'max_auto_bid'],
            'order_by': 'id'
        },
        {
            'table': 'invoice',
            'columns': ['id', 'auction_id', 'user_id', 'item_price', 'bid_fee', 
                       'delivery_fee', 'total_amount', 'payment_method', 
                       'payment_status', 'created_at', 'paid_at'],
            'order_by': 'id'
        }
    ]
    
    # Perform migrations
    total_migrated = 0
    try:
        for migration in migrations:
            count = migrate_table_data(
                sqlite_conn, 
                pg_engine, 
                migration['table'],
                migration['columns'],
                migration.get('order_by')
            )
            total_migrated += count
        
        print("\n" + "=" * 60)
        print("Migration completed successfully!")
        print(f"Total rows migrated: {total_migrated}")
        print("=" * 60)
        return True
        
    except Exception as e:
        print(f"\nERROR: Migration failed: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        sqlite_conn.close()
        pg_engine.dispose()

if __name__ == '__main__':
    # Get SQLite database path
    sqlite_path = os.getenv('SQLITE_DB_PATH', 'instance/auction.db')
    if not os.path.isabs(sqlite_path):
        # Relative path - assume it's in backend directory
        sqlite_path = os.path.join(os.path.dirname(__file__), sqlite_path)
    
    # Get PostgreSQL URI
    postgresql_uri = os.getenv('POSTGRESQL_URI')
    if not postgresql_uri:
        print("ERROR: POSTGRESQL_URI environment variable not set")
        print("\nUsage:")
        print("  export POSTGRESQL_URI='postgresql://user:password@localhost/zubid_db'")
        print("  python migrate_sqlite_to_postgresql.py")
        print("\nOr set SQLITE_DB_PATH if SQLite database is in a different location:")
        print("  export SQLITE_DB_PATH='/path/to/auction.db'")
        sys.exit(1)
    
    # Run migration
    success = migrate_database(sqlite_path, postgresql_uri)
    
    if success:
        print("\n[OK] Migration completed successfully!")
        print("\nNext steps:")
        print("1. Verify data in PostgreSQL database")
        print("2. Update DATABASE_URI in production .env file")
        print("3. Test application with PostgreSQL database")
        sys.exit(0)
    else:
        print("\n[ERROR] Migration failed. Please check the error messages above.")
        sys.exit(1)

