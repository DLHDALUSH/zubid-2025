#!/usr/bin/env python
"""Database migration script to add market_price column to Auction table using SQLAlchemy"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app import app, db
from sqlalchemy import inspect, text

def migrate_market_price():
    """Add market_price column to Auction table"""
    with app.app_context():
        try:
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            
            if 'auction' not in tables:
                print("Auction table doesn't exist! Creating all tables...")
                db.create_all()
                print("[OK] Database tables created successfully!")
                return True
            
            # Check if market_price column exists
            columns = [col['name'] for col in inspector.get_columns('auction')]
            print(f"Current Auction table columns: {columns}")
            
            # Add market_price column if it doesn't exist
            if 'market_price' not in columns:
                print("Adding market_price column to Auction table...")
                try:
                    with db.engine.connect() as conn:
                        # Use begin() to ensure transaction
                        with conn.begin():
                            conn.execute(text("ALTER TABLE auction ADD COLUMN market_price FLOAT"))
                    print("[OK] market_price column added successfully!")
                except Exception as e:
                    print(f"[ERROR] Failed to add column: {e}")
                    # Try alternative method for SQLite
                    if 'sqlite' in str(db.engine.url).lower():
                        print("Attempting SQLite-specific migration...")
                        try:
                            with db.engine.connect() as conn:
                                with conn.begin():
                                    conn.execute(text("ALTER TABLE auction ADD COLUMN market_price REAL"))
                            print("[OK] market_price column added using REAL type!")
                        except Exception as e2:
                            print(f"[ERROR] SQLite migration also failed: {e2}")
                            raise
                    else:
                        raise
            else:
                print("[OK] market_price column already exists")
            
            # Verify - refresh inspector
            inspector = inspect(db.engine)
            columns = [col['name'] for col in inspector.get_columns('auction')]
            print(f"\nFinal Auction table columns: {columns}")
            if 'market_price' in columns:
                print("[OK] Verification successful - market_price column exists!")
            else:
                print("[WARNING] market_price column not found after migration!")
            
            print("\n[OK] Migration completed successfully!")
            
        except Exception as e:
            print(f"[ERROR] Error during migration: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    return True

if __name__ == '__main__':
    print("=" * 60)
    print("Database Migration: Add market_price to Auction table")
    print("=" * 60)
    print()
    
    if migrate_market_price():
        print("\n[OK] Migration successful!")
        sys.exit(0)
    else:
        print("\n[ERROR] Migration failed!")
        sys.exit(1)

