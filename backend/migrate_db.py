#!/usr/bin/env python
"""Database migration script to add profile_photo column to User table"""

import sys
import os

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

from app import app, db
from sqlalchemy import inspect, text

def migrate_database():
    """Add missing columns to existing database tables"""
    with app.app_context():
        try:
            # Check if User table exists
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            
            if 'user' not in tables:
                print("User table doesn't exist. Running db.create_all() to create it...")
                db.create_all()
                print("Database tables created successfully!")
                return True
            
            # Get current columns
            columns = [col['name'] for col in inspector.get_columns('user')]
            print(f"Current User table columns: {columns}")
            
            # Add profile_photo column if it doesn't exist
            if 'profile_photo' not in columns:
                print("Adding profile_photo column to User table...")
                with db.engine.connect() as conn:
                    conn.execute(text("ALTER TABLE user ADD COLUMN profile_photo VARCHAR(500)"))
                    conn.commit()
                print("[OK] profile_photo column added successfully!")
            else:
                print("[OK] profile_photo column already exists")
            
            # Verify the column was added
            columns = [col['name'] for col in inspector.get_columns('user')]
            print(f"Final User table columns: {columns}")
            
            print("\nDatabase migration completed successfully!")
            
        except Exception as e:
            print(f"Error during migration: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    return True

if __name__ == '__main__':
    print("=" * 60)
    print("Database Migration Script")
    print("=" * 60)
    print()
    
    if migrate_database():
        print("\n[OK] Migration completed successfully!")
        print("\nYou can now start the backend server.")
    else:
        print("\n[ERROR] Migration failed. Please check the error messages above.")
        sys.exit(1)
