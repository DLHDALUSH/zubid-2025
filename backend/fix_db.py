#!/usr/bin/env python
"""Database migration script - direct SQLite approach

This script locates the SQLite database file (prefers `backend/instance/auction.db`),
backs it up and then ensures the `user` table contains a `profile_photo` column.
"""

import sqlite3
import os
import shutil
import datetime

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
    raise SystemExit(0)

print(f"Found database at: {db_path}")

# Create a timestamped backup
bak_path = f"{db_path}.bak.{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}"
shutil.copy2(db_path, bak_path)
print(f"Backup created at: {bak_path}")

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
