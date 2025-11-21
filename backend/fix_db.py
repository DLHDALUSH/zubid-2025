#!/usr/bin/env python
"""Database migration script - direct SQLite approach"""

import sqlite3
import os

# Find the database file
db_paths = [
    'backend/instance/auction.db',
    'instance/auction.db',
    'auction.db'
]

db_path = None
for path in db_paths:
    if os.path.exists(path):
        db_path = path
        break

if not db_path:
    print("Database not found. It will be created when the server starts.")
    exit(0)

print(f"Found database at: {db_path}")

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Check current columns
    cursor.execute("PRAGMA table_info(user)")
    columns = [row[1] for row in cursor.fetchall()]
    print(f"Current columns: {columns}")
    
    # Add profile_photo if it doesn't exist
    if 'profile_photo' not in columns:
        print("Adding profile_photo column...")
        cursor.execute("ALTER TABLE user ADD COLUMN profile_photo VARCHAR(500)")
        conn.commit()
        print("[OK] Column added successfully!")
        
        # Verify
        cursor.execute("PRAGMA table_info(user)")
        columns = [row[1] for row in cursor.fetchall()]
        print(f"Updated columns: {columns}")
    else:
        print("[OK] profile_photo column already exists")
    
    conn.close()
    print("\n[OK] Migration completed!")
    
except Exception as e:
    print(f"[ERROR] {e}")
    import traceback
    traceback.print_exc()

