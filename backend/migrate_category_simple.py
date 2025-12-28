#!/usr/bin/env python3
"""
Simple migration script to add enhanced fields to Category table
This script directly modifies the database without importing the app
"""

import sqlite3
import os
from datetime import datetime

def migrate_category_table():
    """Add new columns to Category table"""
    print("=" * 60)
    print("Category Table Enhancement Migration")
    print("=" * 60)
    
    # Database path
    db_path = os.path.join(os.path.dirname(__file__), 'instance', 'auction.db')
    
    if not os.path.exists(db_path):
        print(f"❌ Database not found at: {db_path}")
        return False
    
    print(f"\n✓ Found database at: {db_path}")
    
    try:
        # Connect to database
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Get existing columns
        cursor.execute("PRAGMA table_info(category)")
        existing_columns = [row[1] for row in cursor.fetchall()]
        print(f"✓ Existing columns: {', '.join(existing_columns)}")
        
        # Define new columns to add
        new_columns = {
            'parent_id': 'INTEGER',
            'icon_url': 'VARCHAR(500)',
            'image_url': 'VARCHAR(500)',
            'is_active': 'BOOLEAN DEFAULT 1',
            'sort_order': 'INTEGER DEFAULT 0',
            'created_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
            'updated_at': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'
        }
        
        # Add missing columns
        columns_added = []
        for column_name, column_type in new_columns.items():
            if column_name not in existing_columns:
                print(f"\n[+] Adding column: {column_name} ({column_type})")
                try:
                    sql = f"ALTER TABLE category ADD COLUMN {column_name} {column_type}"
                    cursor.execute(sql)
                    conn.commit()
                    columns_added.append(column_name)
                    print(f"   ✓ Column {column_name} added successfully")
                except Exception as e:
                    print(f"   ⚠ Warning: Could not add {column_name}: {str(e)}")
                    conn.rollback()
            else:
                print(f"   ✓ Column {column_name} already exists")
        
        # Update existing categories with default values
        if columns_added:
            print(f"\n[*] Updating existing categories with default values...")
            try:
                now = datetime.now().isoformat()
                
                # Get all categories
                cursor.execute("SELECT id FROM category")
                categories = cursor.fetchall()
                
                for idx, (cat_id,) in enumerate(categories):
                    updates = []
                    if 'is_active' in columns_added:
                        updates.append("is_active = 1")
                    if 'sort_order' in columns_added:
                        updates.append(f"sort_order = {idx}")
                    if 'created_at' in columns_added:
                        updates.append(f"created_at = '{now}'")
                    if 'updated_at' in columns_added:
                        updates.append(f"updated_at = '{now}'")
                    
                    if updates:
                        sql = f"UPDATE category SET {', '.join(updates)} WHERE id = {cat_id}"
                        cursor.execute(sql)
                
                conn.commit()
                print(f"   ✓ Updated {len(categories)} categories")
            except Exception as e:
                print(f"   ⚠ Warning: Could not update categories: {str(e)}")
                conn.rollback()
        
        # Create indexes
        print(f"\n[*] Creating indexes...")
        try:
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_category_parent ON category(parent_id)")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_category_active_sort ON category(is_active, sort_order)")
            conn.commit()
            print("   ✓ Indexes created successfully")
        except Exception as e:
            print(f"   ⚠ Warning: Could not create indexes: {str(e)}")
            conn.rollback()
        
        # Close connection
        conn.close()
        
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
    
    if success:
        print("\n✅ Migration completed! You can now restart your backend server.")
    else:
        print("\n❌ Migration failed! Please check the errors above.")
    
    input("\nPress Enter to exit...")

