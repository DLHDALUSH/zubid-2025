#!/usr/bin/env python
"""Database migration script to add video_url column to Auction table using SQLAlchemy"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app import app, db
from sqlalchemy import inspect, text

def migrate_video_url():
    """Add video_url column to Auction table"""
    with app.app_context():
        try:
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            
            if 'auction' not in tables:
                print("Auction table doesn't exist! Creating all tables...")
                db.create_all()
                print("[OK] Database tables created successfully!")
                return True
            
            # Check if video_url column exists
            columns = [col['name'] for col in inspector.get_columns('auction')]
            print(f"Current Auction table columns: {columns}")
            
            # Add video_url column if it doesn't exist
            if 'video_url' not in columns:
                print("Adding video_url column to Auction table...")
                with db.engine.connect() as conn:
                    conn.execute(text("ALTER TABLE auction ADD COLUMN video_url VARCHAR(500)"))
                    conn.commit()
                print("[OK] video_url column added successfully!")
            else:
                print("[OK] video_url column already exists")
            
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
    print("Database Migration: Add video_url to Auction table")
    print("=" * 60)
    print()
    
    if migrate_video_url():
        print("\n[OK] Migration successful!")
        sys.exit(0)
    else:
        print("\n[ERROR] Migration failed!")
        sys.exit(1)

