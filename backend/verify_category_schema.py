#!/usr/bin/env python3
"""
Verify Category table schema
"""

import sqlite3
import os

def verify_schema():
    """Verify Category table has all required columns"""
    print("=" * 60)
    print("Verifying Category Table Schema")
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
        
        # Get table info
        cursor.execute("PRAGMA table_info(category)")
        columns = cursor.fetchall()
        
        print(f"\n📋 Category Table Columns:")
        print("-" * 60)
        for col in columns:
            col_id, name, col_type, not_null, default, pk = col
            print(f"  {name:20} {col_type:15} {'NOT NULL' if not_null else ''} {'PK' if pk else ''}")
        
        # Check required columns
        required_columns = [
            'id', 'name', 'description', 'parent_id', 'icon_url', 
            'image_url', 'is_active', 'sort_order', 'created_at', 'updated_at'
        ]
        
        existing_columns = [col[1] for col in columns]
        
        print(f"\n✅ Required Columns Check:")
        print("-" * 60)
        all_present = True
        for col in required_columns:
            if col in existing_columns:
                print(f"  ✓ {col}")
            else:
                print(f"  ✗ {col} - MISSING!")
                all_present = False
        
        # Get sample data
        cursor.execute("SELECT id, name, parent_id, is_active, sort_order FROM category LIMIT 5")
        categories = cursor.fetchall()
        
        if categories:
            print(f"\n📊 Sample Data ({len(categories)} categories):")
            print("-" * 60)
            for cat in categories:
                cat_id, name, parent_id, is_active, sort_order = cat
                print(f"  ID: {cat_id}, Name: {name}, Parent: {parent_id}, Active: {is_active}, Order: {sort_order}")
        
        # Close connection
        conn.close()
        
        print("\n" + "=" * 60)
        if all_present:
            print("✅ All required columns are present!")
        else:
            print("❌ Some required columns are missing!")
        print("=" * 60)
        
        return all_present
        
    except Exception as e:
        print(f"\n❌ Verification failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("\n🔍 Verifying Category table schema...\n")
    verify_schema()

