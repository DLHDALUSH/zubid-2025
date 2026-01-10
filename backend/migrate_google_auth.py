#!/usr/bin/env python3
"""
Database migration script to add Google authentication support
Run this script to add the google_id and profile_picture fields to the User table
"""

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError

def migrate_database():
    """Add Google authentication fields to User table"""
    
    # Get database URI from environment or use default
    database_uri = os.getenv('DATABASE_URI', 'sqlite:///auction.db')
    
    try:
        engine = create_engine(database_uri)
        
        with engine.connect() as conn:
            print("🔄 Starting Google authentication migration...")
            
            # Check if columns already exist
            try:
                result = conn.execute(text("SELECT google_id FROM user LIMIT 1"))
                print("✅ google_id column already exists")
            except OperationalError:
                # Add google_id column
                print("➕ Adding google_id column...")
                conn.execute(text("ALTER TABLE user ADD COLUMN google_id VARCHAR(100) UNIQUE"))
                conn.commit()
                print("✅ google_id column added")
            
            try:
                result = conn.execute(text("SELECT profile_picture FROM user LIMIT 1"))
                print("✅ profile_picture column already exists")
            except OperationalError:
                # Add profile_picture column
                print("➕ Adding profile_picture column...")
                conn.execute(text("ALTER TABLE user ADD COLUMN profile_picture VARCHAR(500)"))
                conn.commit()
                print("✅ profile_picture column added")
            
            print("🎉 Google authentication migration completed successfully!")
            
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    migrate_database()
