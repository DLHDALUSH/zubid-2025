"""
Migration script to add enhanced user profile fields, navigation menu, and user preferences
Run this script to update the database schema for new features
"""

import os
import sys
from datetime import datetime, timezone

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db
from sqlalchemy import text, inspect

def migrate_database():
    """Add new columns and tables to existing database"""
    with app.app_context():
        print("\n" + "="*60)
        print("ZUBID Database Migration - Enhanced Features")
        print("="*60 + "\n")
        
        inspector = inspect(db.engine)
        is_sqlite = 'sqlite' in str(db.engine.url).lower()
        
        # Get existing tables
        existing_tables = inspector.get_table_names()
        print(f"Found {len(existing_tables)} existing tables")
        
        # 1. Add new columns to User table
        print("\n[1/3] Checking User table columns...")
        user_columns = [col['name'] for col in inspector.get_columns('user')]
        
        new_user_columns = {
            'profile_photo': 'VARCHAR(500)',
            'first_name': 'VARCHAR(50)',
            'last_name': 'VARCHAR(50)',
            'bio': 'TEXT',
            'company': 'VARCHAR(100)',
            'website': 'VARCHAR(255)',
            'city': 'VARCHAR(100)',
            'country': 'VARCHAR(100)',
            'postal_code': 'VARCHAR(20)',
            'phone_verified': 'BOOLEAN DEFAULT 0',
            'email_verified': 'BOOLEAN DEFAULT 0',
            'is_active': 'BOOLEAN DEFAULT 1',
            'last_login': 'DATETIME',
            'login_count': 'INTEGER DEFAULT 0'
        }
        
        added_columns = []
        for col_name, col_type in new_user_columns.items():
            if col_name not in user_columns:
                try:
                    with db.engine.connect() as conn:
                        with conn.begin():
                            conn.execute(text(f"ALTER TABLE user ADD COLUMN {col_name} {col_type}"))
                    added_columns.append(col_name)
                    print(f"  ✓ Added column: {col_name}")
                except Exception as e:
                    print(f"  ✗ Failed to add {col_name}: {str(e)}")
            else:
                print(f"  - Column exists: {col_name}")
        
        if added_columns:
            print(f"\n  Added {len(added_columns)} new columns to User table")
        else:
            print("  All User columns already exist")
        
        # 2. Create NavigationMenu table
        print("\n[2/3] Checking NavigationMenu table...")
        if 'navigation_menu' not in existing_tables:
            try:
                db.create_all()
                print("  ✓ Created NavigationMenu table")
            except Exception as e:
                print(f"  ✗ Failed to create NavigationMenu table: {str(e)}")
        else:
            print("  - NavigationMenu table already exists")
        
        # 3. Create UserPreference table
        print("\n[3/3] Checking UserPreference table...")
        if 'user_preference' not in existing_tables:
            try:
                db.create_all()
                print("  ✓ Created UserPreference table")
            except Exception as e:
                print(f"  ✗ Failed to create UserPreference table: {str(e)}")
        else:
            print("  - UserPreference table already exists")
        
        # Verify all tables were created
        print("\n" + "="*60)
        print("Verifying database structure...")
        print("="*60)
        
        inspector = inspect(db.engine)
        final_tables = inspector.get_table_names()
        
        required_tables = ['user', 'navigation_menu', 'user_preference']
        for table in required_tables:
            if table in final_tables:
                print(f"  ✓ {table}")
            else:
                print(f"  ✗ {table} - MISSING!")
        
        print("\n" + "="*60)
        print("Migration completed!")
        print("="*60)
        print("\nNext steps:")
        print("1. Restart the backend server")
        print("2. Test the new features:")
        print("   - Enhanced user profiles")
        print("   - Dynamic navigation menu")
        print("   - User preferences")
        print("\n")

if __name__ == '__main__':
    try:
        migrate_database()
    except Exception as e:
        print(f"\n[ERROR] Migration failed: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

