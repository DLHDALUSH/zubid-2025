#!/usr/bin/env python
"""Migration script to add item_condition column to Auction table"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app import app, db
from sqlalchemy import inspect, text

def migrate_item_condition():
    """Add item_condition column to Auction table"""
    with app.app_context():
        try:
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            
            if 'auction' not in tables:
                print("Auction table doesn't exist!")
                return False
            
            # Check if item_condition column exists
            columns = [col['name'] for col in inspector.get_columns('auction')]
            print(f"Current Auction table columns: {columns}")
            
            # Add item_condition column if it doesn't exist
            if 'item_condition' not in columns:
                print("Adding item_condition column to Auction table...")
                with db.engine.connect() as conn:
                    conn.execute(text("ALTER TABLE auction ADD COLUMN item_condition VARCHAR(50)"))
                    conn.commit()
                print("[OK] item_condition column added successfully!")
            else:
                print("[OK] item_condition column already exists")
            
            # Verify
            columns = [col['name'] for col in inspector.get_columns('auction')]
            print(f"\nFinal Auction table columns: {columns}")
            
            print("\n[OK] Migration completed successfully!")
            
        except Exception as e:
            print(f"[ERROR] Error during migration: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    return True

if __name__ == '__main__':
    print("=" * 60)
    print("Item Condition Migration Script")
    print("=" * 60)
    print()
    
    if migrate_item_condition():
        print("\n[OK] Migration completed successfully!")
        print("\nYou can now restart the backend server.")
    else:
        print("\n[ERROR] Migration failed. Please check the error messages above.")
        sys.exit(1)

