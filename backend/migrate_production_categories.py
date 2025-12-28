#!/usr/bin/env python3
"""
Production Category Migration Script for Render.com
This script safely migrates the Category table to include all required fields.
"""

import os
import sys
from datetime import datetime
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.exc import SQLAlchemyError

def get_database_url():
    """Get database URL from environment or use default"""
    db_url = os.getenv('DATABASE_URI') or os.getenv('DATABASE_URL')
    if not db_url:
        print("❌ ERROR: DATABASE_URI or DATABASE_URL environment variable not set")
        sys.exit(1)
    return db_url

def backup_reminder():
    """Remind user to backup database"""
    print("\n" + "="*70)
    print("⚠️  IMPORTANT: DATABASE MIGRATION")
    print("="*70)
    print("This script will modify the Category table structure.")
    print("BEFORE proceeding, ensure you have:")
    print("  1. ✅ Backed up your production database")
    print("  2. ✅ Tested this migration on a staging environment")
    print("  3. ✅ Scheduled maintenance window (if needed)")
    print("="*70)
    
    response = input("\nHave you backed up the database? (yes/no): ").strip().lower()
    if response != 'yes':
        print("❌ Migration cancelled. Please backup your database first.")
        sys.exit(0)

def check_column_exists(engine, table_name, column_name):
    """Check if a column exists in a table"""
    inspector = inspect(engine)
    columns = [col['name'] for col in inspector.get_columns(table_name)]
    return column_name in columns

def migrate_categories(engine):
    """Migrate the Category table"""
    print("\n📊 Starting Category table migration...")
    
    with engine.connect() as conn:
        # Start transaction
        trans = conn.begin()
        
        try:
            # Check which columns need to be added
            columns_to_add = {
                'parent_id': 'INTEGER',
                'icon_url': 'VARCHAR(500)',
                'image_url': 'VARCHAR(500)',
                'is_active': 'BOOLEAN DEFAULT TRUE',
                'sort_order': 'INTEGER DEFAULT 0',
                'created_at': 'TIMESTAMP',
                'updated_at': 'TIMESTAMP'
            }
            
            added_columns = []
            skipped_columns = []
            
            for column_name, column_type in columns_to_add.items():
                if check_column_exists(engine, 'category', column_name):
                    print(f"  ⏭️  Column '{column_name}' already exists, skipping...")
                    skipped_columns.append(column_name)
                else:
                    print(f"  ➕ Adding column '{column_name}'...")
                    
                    # Add the column
                    if 'DEFAULT' in column_type:
                        sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type}"
                    else:
                        sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type}"
                    
                    conn.execute(text(sql))
                    added_columns.append(column_name)
                    print(f"  ✅ Column '{column_name}' added successfully")
            
            # Set default values for existing records
            print("\n📝 Setting default values for existing records...")
            
            current_time = datetime.utcnow()
            
            # Update timestamps if they were just added
            if 'created_at' in added_columns or 'updated_at' in added_columns:
                conn.execute(text("""
                    UPDATE category 
                    SET created_at = :current_time,
                        updated_at = :current_time
                    WHERE created_at IS NULL OR updated_at IS NULL
                """), {"current_time": current_time})
                print("  ✅ Timestamps set for existing records")
            
            # Update is_active if it was just added
            if 'is_active' in added_columns:
                conn.execute(text("UPDATE category SET is_active = TRUE WHERE is_active IS NULL"))
                print("  ✅ is_active set to TRUE for existing records")
            
            # Update sort_order if it was just added
            if 'sort_order' in added_columns:
                conn.execute(text("UPDATE category SET sort_order = id WHERE sort_order IS NULL"))
                print("  ✅ sort_order set based on ID for existing records")
            
            # Create indexes for better performance
            print("\n🔍 Creating indexes...")
            
            indexes = [
                ("idx_category_parent_id", "parent_id"),
                ("idx_category_is_active", "is_active"),
                ("idx_category_sort_order", "sort_order")
            ]
            
            for index_name, column_name in indexes:
                try:
                    conn.execute(text(f"CREATE INDEX IF NOT EXISTS {index_name} ON category({column_name})"))
                    print(f"  ✅ Index '{index_name}' created")
                except Exception as e:
                    print(f"  ⚠️  Index '{index_name}' might already exist: {str(e)}")
            
            # Commit transaction
            trans.commit()
            
            print("\n" + "="*70)
            print("✅ MIGRATION COMPLETED SUCCESSFULLY")
            print("="*70)
            print(f"  • Columns added: {len(added_columns)}")
            print(f"  • Columns skipped (already exist): {len(skipped_columns)}")
            print(f"  • Indexes created: {len(indexes)}")
            print("="*70)
            
            return True
            
        except Exception as e:
            trans.rollback()
            print(f"\n❌ ERROR during migration: {str(e)}")
            print("Transaction rolled back. Database unchanged.")
            return False

def verify_migration(engine):
    """Verify the migration was successful"""
    print("\n🔍 Verifying migration...")
    
    inspector = inspect(engine)
    columns = inspector.get_columns('category')
    column_names = [col['name'] for col in columns]
    
    required_columns = [
        'id', 'name', 'description', 'parent_id', 'icon_url', 
        'image_url', 'is_active', 'sort_order', 'created_at', 'updated_at'
    ]
    
    missing_columns = [col for col in required_columns if col not in column_names]
    
    if missing_columns:
        print(f"❌ Missing columns: {', '.join(missing_columns)}")
        return False
    
    print(f"✅ All {len(required_columns)} required columns present")
    
    # Check record count
    with engine.connect() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM category"))
        count = result.scalar()
        print(f"✅ Category table has {count} records")
    
    return True

def main():
    """Main migration function"""
    print("\n🚀 ZUBID Production Category Migration")
    print("="*70)
    
    # Show backup reminder
    backup_reminder()
    
    # Get database URL
    db_url = get_database_url()
    print(f"\n📊 Connecting to database...")
    
    try:
        # Create engine
        engine = create_engine(db_url)
        
        # Test connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        print("✅ Database connection successful")
        
        # Run migration
        success = migrate_categories(engine)
        
        if success:
            # Verify migration
            verify_migration(engine)
            print("\n🎉 Migration completed successfully!")
            print("You can now restart your application.")
            return 0
        else:
            print("\n❌ Migration failed. Please check the errors above.")
            return 1
            
    except SQLAlchemyError as e:
        print(f"\n❌ Database error: {str(e)}")
        return 1
    except Exception as e:
        print(f"\n❌ Unexpected error: {str(e)}")
        return 1

if __name__ == '__main__':
    sys.exit(main())

