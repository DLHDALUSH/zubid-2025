"""
Fix profile_photo column in User table
"""

import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'instance', 'auction.db')

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Check if profile_photo column exists
    cursor.execute("PRAGMA table_info(user)")
    columns = [row[1] for row in cursor.fetchall()]
    
    print(f"Current User table columns: {', '.join(columns)}")
    
    if 'profile_photo' not in columns:
        print("\nAdding profile_photo column...")
        cursor.execute("ALTER TABLE user ADD COLUMN profile_photo VARCHAR(500)")
        conn.commit()
        print("✓ profile_photo column added successfully!")
    else:
        print("\n✓ profile_photo column already exists")
    
    conn.close()
    print("\nDone!")
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()

