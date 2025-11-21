#!/usr/bin/env python
"""Database migration script to add video_url column to Auction table"""

import sqlite3
import os
import sys

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
    print("Database not found. The video_url column will be created automatically when the server starts.")
    sys.exit(0)

print(f"Found database at: {db_path}")

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Check current columns
    cursor.execute("PRAGMA table_info(auction)")
    columns = [row[1] for row in cursor.fetchall()]
    print(f"Current columns: {columns}")
    
    # Add video_url if it doesn't exist
    if 'video_url' not in columns:
        print("Adding video_url column...")
        cursor.execute("ALTER TABLE auction ADD COLUMN video_url VARCHAR(500)")
        conn.commit()
        print("[OK] Column added successfully!")
        
        # Verify
        cursor.execute("PRAGMA table_info(auction)")
        columns = [row[1] for row in cursor.fetchall()]
        print(f"Updated columns: {columns}")
    else:
        print("[OK] video_url column already exists")
    
    conn.close()
    print("\n[OK] Migration completed!")
    
except Exception as e:
    print(f"[ERROR] {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

