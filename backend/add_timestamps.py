#!/usr/bin/env python3
"""
Add created_at and updated_at columns to Category table
"""

import sqlite3
import os
from datetime import datetime

def add_timestamps():
    """Add timestamp columns to Category table"""
    print("=" * 60)
    print("Adding Timestamp Columns to Category Table")
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
        
        # Add created_at if not exists
        if 'created_at' not in existing_columns:
            print(f"\n[+] Adding column: created_at")
            try:
                cursor.execute("ALTER TABLE category ADD COLUMN created_at TIMESTAMP")
                conn.commit()
                print(f"   ✓ Column created_at added successfully")
                
                # Set default value for existing rows
                now = datetime.now().isoformat()
                cursor.execute(f"UPDATE category SET created_at = '{now}' WHERE created_at IS NULL")
                conn.commit()
                print(f"   ✓ Set default values for existing rows")
            except Exception as e:
                print(f"   ⚠ Warning: Could not add created_at: {str(e)}")
                conn.rollback()
        else:
            print(f"   ✓ Column created_at already exists")
        
        # Add updated_at if not exists
        if 'updated_at' not in existing_columns:
            print(f"\n[+] Adding column: updated_at")
            try:
                cursor.execute("ALTER TABLE category ADD COLUMN updated_at TIMESTAMP")
                conn.commit()
                print(f"   ✓ Column updated_at added successfully")
                
                # Set default value for existing rows
                now = datetime.now().isoformat()
                cursor.execute(f"UPDATE category SET updated_at = '{now}' WHERE updated_at IS NULL")
                conn.commit()
                print(f"   ✓ Set default values for existing rows")
            except Exception as e:
                print(f"   ⚠ Warning: Could not add updated_at: {str(e)}")
                conn.rollback()
        else:
            print(f"   ✓ Column updated_at already exists")
        
        # Close connection
        conn.close()
        
        print("\n" + "=" * 60)
        print("✅ Timestamp columns added successfully!")
        print("=" * 60)
        
        return True
        
    except Exception as e:
        print(f"\n❌ Failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("\n🚀 Adding timestamp columns...\n")
    success = add_timestamps()
    
    if success:
        print("\n✅ Done! You can now restart your backend server.")
    else:
        print("\n❌ Failed! Please check the errors above.")

