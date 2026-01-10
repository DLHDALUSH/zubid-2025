#!/usr/bin/env python3
"""
Database migration script to add missing User table columns
Run this script to add the google_id and profile_picture fields to the User table
"""

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError, ProgrammingError

def migrate_database():
    """Add missing fields to User table"""

    # Get database URI from environment or use default
    database_uri = os.getenv('DATABASE_URI')
    if not database_uri:
        # Try common environment variable names
        database_uri = os.getenv('DATABASE_URL')
    if not database_uri:
        database_uri = 'sqlite:///auction.db'

    print(f"🔗 Connecting to database: {database_uri[:50]}...")

    try:
        engine = create_engine(database_uri)

        with engine.connect() as conn:
            print("🔄 Starting User table migration...")

            # List of columns to add with their definitions
            columns_to_add = [
                ('google_id', 'VARCHAR(100)'),
                ('profile_picture', 'VARCHAR(500)'),
            ]

            for column_name, column_type in columns_to_add:
                try:
                    # Try to select from the column to see if it exists
                    result = conn.execute(text(f"SELECT {column_name} FROM \"user\" LIMIT 1"))
                    print(f"✅ {column_name} column already exists")
                except (OperationalError, ProgrammingError) as e:
                    # Column doesn't exist, add it
                    print(f"➕ Adding {column_name} column...")
                    try:
                        # Use proper PostgreSQL syntax with quotes around table name
                        if column_name == 'google_id':
                            # Add UNIQUE constraint for google_id
                            conn.execute(text(f'ALTER TABLE "user" ADD COLUMN {column_name} {column_type} UNIQUE'))
                        else:
                            conn.execute(text(f'ALTER TABLE "user" ADD COLUMN {column_name} {column_type}'))
                        conn.commit()
                        print(f"✅ {column_name} column added successfully")
                    except Exception as add_error:
                        print(f"❌ Failed to add {column_name} column: {add_error}")
                        # Continue with other columns
                        continue

            print("🎉 User table migration completed successfully!")

    except Exception as e:
        print(f"❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    migrate_database()
