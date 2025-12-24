#!/usr/bin/env python
"""
Database migration script to add fcm_token column to User table
"""

import sqlite3
import os
import shutil
import datetime

# Find the database file
db_paths = [
    'instance/auction.db',
    '../instance/auction.db',
    'backend/instance/auction.db',
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

print(f"Found database: {db_path}")

# Backup the database
backup_path = f"{db_path}.backup_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}"
shutil.copy2(db_path, backup_path)
print(f"Backup created: {backup_path}")

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Check current columns
    cursor.execute("PRAGMA table_info(user)")
    columns = [row[1] for row in cursor.fetchall()]
    print(f"Current columns: {columns}")

    # Add fcm_token column if it doesn't exist
    if 'fcm_token' not in columns:
        print("Adding fcm_token column...")
        cursor.execute("ALTER TABLE user ADD COLUMN fcm_token VARCHAR(255)")
        conn.commit()
        print("[OK] FCM token column added successfully!")

        # Verify
        cursor.execute("PRAGMA table_info(user)")
        columns = [row[1] for row in cursor.fetchall()]
        print(f"Updated columns: {columns}")
    else:
        print("[OK] FCM token column already exists")

    conn.close()
    print("\n[OK] Migration completed successfully!")

except Exception as e:
    print(f"[ERROR] Migration failed: {e}")
    print(f"Restoring from backup: {backup_path}")
    shutil.copy2(backup_path, db_path)
    print("Database restored from backup")
    raise SystemExit(1)

