#!/usr/bin/env python
"""
Database migration script to add balance and fcm_token columns to User table
Run this script to update existing databases with new fields
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
    print(f"\nCurrent columns: {', '.join(columns)}")
    
    changes_made = False

    # Add balance column if it doesn't exist
    if 'balance' not in columns:
        print("\n[1/2] Adding balance column...")
        cursor.execute("ALTER TABLE user ADD COLUMN balance REAL DEFAULT 0.0 NOT NULL")
        conn.commit()
        print("✓ Balance column added successfully!")
        changes_made = True
    else:
        print("\n[1/2] Balance column already exists ✓")

    # Add fcm_token column if it doesn't exist
    if 'fcm_token' not in columns:
        print("\n[2/2] Adding fcm_token column...")
        cursor.execute("ALTER TABLE user ADD COLUMN fcm_token VARCHAR(255)")
        conn.commit()
        print("✓ FCM token column added successfully!")
        changes_made = True
    else:
        print("\n[2/2] FCM token column already exists ✓")

    if changes_made:
        # Verify changes
        cursor.execute("PRAGMA table_info(user)")
        columns = [row[1] for row in cursor.fetchall()]
        print(f"\nUpdated columns: {', '.join(columns)}")

    conn.close()
    print("\n" + "="*50)
    print("✓ Migration completed successfully!")
    print("="*50)
    
    if changes_made:
        print(f"\nBackup saved at: {backup_path}")
        print("You can delete the backup file once you've verified everything works.")

except Exception as e:
    print(f"\n[ERROR] Migration failed: {e}")
    print(f"Restoring from backup: {backup_path}")
    shutil.copy2(backup_path, db_path)
    print("Database restored from backup")
    raise SystemExit(1)

