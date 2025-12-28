#!/usr/bin/env python3
"""
Migration script to add enhanced fields to Category table
Adds: parent_id, icon_url, image_url, is_active, sort_order, created_at, updated_at
"""

import sys
import os
from datetime import datetime, timezone

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db
from sqlalchemy import text, inspect

def migrate_category_table():
    """Add new columns to Category table"""
    with app.app_context():
        print("=" * 60)
        print("Category Table Enhancement Migration")
        print("=" * 60)
        
        try:
            # Get database inspector
            inspector = inspect(db.engine)
            
            # Check if category table exists
            if 'category' not in inspector.get_table_names():
                print("❌ Category table does not exist!")
                print("   Run init_db() first to create tables.")
                return False
            
            # Get existing columns
            existing_columns = [col['name'] for col in inspector.get_columns('category')]
            print(f"\n✓ Found Category table with columns: {', '.join(existing_columns)}")
            
            # Define new columns to add
            new_columns = {
                'parent_id': 'INTEGER',
                'icon_url': 'VARCHAR(500)',
                'image_url': 'VARCHAR(500)',
                'is_active': 'BOOLEAN DEFAULT TRUE',
                'sort_order': 'INTEGER DEFAULT 0',
                'created_at': 'TIMESTAMP',
                'updated_at': 'TIMESTAMP'
            }
            
            # Add missing columns
            columns_added = []
            for column_name, column_type in new_columns.items():
                if column_name not in existing_columns:
                    print(f"\n[+] Adding column: {column_name} ({column_type})")
                    try:
                        # Determine SQL based on database type
                        db_uri = str(db.engine.url)
                        
                        if 'postgresql' in db_uri or 'postgres' in db_uri:
                            # PostgreSQL syntax
                            if column_name == 'parent_id':
                                sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type} REFERENCES category(id)"
                            elif column_name in ['created_at', 'updated_at']:
                                sql = f"ALTER TABLE category ADD COLUMN {column_name} TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                            else:
                                sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type}"
                        else:
                            # SQLite syntax
                            if column_name == 'parent_id':
                                sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type}"
                            elif column_name in ['created_at', 'updated_at']:
                                sql = f"ALTER TABLE category ADD COLUMN {column_name} TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                            else:
                                sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type}"
                        
                        db.session.execute(text(sql))
                        db.session.commit()
                        columns_added.append(column_name)
                        print(f"   ✓ Column {column_name} added successfully")
                    except Exception as e:
                        print(f"   ⚠ Warning: Could not add {column_name}: {str(e)}")
                        db.session.rollback()
                else:
                    print(f"   ✓ Column {column_name} already exists")
            
            # Update existing categories with default values
            if columns_added:
                print(f"\n[*] Updating existing categories with default values...")
                try:
                    from app import Category
                    categories = Category.query.all()
                    now = datetime.now(timezone.utc)
                    
                    for idx, cat in enumerate(categories):
                        if 'is_active' in columns_added and not hasattr(cat, 'is_active'):
                            cat.is_active = True
                        if 'sort_order' in columns_added and not hasattr(cat, 'sort_order'):
                            cat.sort_order = idx
                        if 'created_at' in columns_added and not hasattr(cat, 'created_at'):
                            cat.created_at = now
                        if 'updated_at' in columns_added and not hasattr(cat, 'updated_at'):
                            cat.updated_at = now
                    
                    db.session.commit()
                    print(f"   ✓ Updated {len(categories)} categories")
                except Exception as e:
                    print(f"   ⚠ Warning: Could not update categories: {str(e)}")
                    db.session.rollback()
            
            # Create indexes
            print(f"\n[*] Creating indexes...")
            try:
                db_uri = str(db.engine.url)
                if 'postgresql' in db_uri or 'postgres' in db_uri:
                    # PostgreSQL indexes
                    db.session.execute(text("CREATE INDEX IF NOT EXISTS idx_category_parent ON category(parent_id)"))
                    db.session.execute(text("CREATE INDEX IF NOT EXISTS idx_category_active_sort ON category(is_active, sort_order)"))
                else:
                    # SQLite indexes
                    db.session.execute(text("CREATE INDEX IF NOT EXISTS idx_category_parent ON category(parent_id)"))
                    db.session.execute(text("CREATE INDEX IF NOT EXISTS idx_category_active_sort ON category(is_active, sort_order)"))
                
                db.session.commit()
                print("   ✓ Indexes created successfully")
            except Exception as e:
                print(f"   ⚠ Warning: Could not create indexes: {str(e)}")
                db.session.rollback()
            
            print("\n" + "=" * 60)
            print("✅ Category table migration completed successfully!")
            print("=" * 60)
            print(f"\nColumns added: {len(columns_added)}")
            if columns_added:
                for col in columns_added:
                    print(f"  - {col}")
            print("\nYou can now use the enhanced Category model with:")
            print("  - parent_id (for subcategories)")
            print("  - icon_url (category icon)")
            print("  - image_url (category image)")
            print("  - is_active (active status)")
            print("  - sort_order (display order)")
            print("  - created_at (creation timestamp)")
            print("  - updated_at (update timestamp)")
            print("  - auction_count (computed property)")
            
            return True
            
        except Exception as e:
            print(f"\n❌ Migration failed: {str(e)}")
            import traceback
            traceback.print_exc()
            return False

if __name__ == '__main__':
    print("\n🚀 Starting Category table migration...\n")
    success = migrate_category_table()
    sys.exit(0 if success else 1)

