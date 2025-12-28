#!/usr/bin/env python3
"""
Quick Migration Script for Render.com
Run this to add missing columns to the Category table.
"""
import os
import sys
from sqlalchemy import create_engine, text

def get_db_url():
    url = os.getenv('DATABASE_URI') or os.getenv('DATABASE_URL')
    if not url:
        print("ERROR: No database URL found")
        sys.exit(1)
    return url

def run_migration():
    print("Starting Category table migration...")
    engine = create_engine(get_db_url())
    
    migrations = [
        ("parent_id", "ALTER TABLE category ADD COLUMN IF NOT EXISTS parent_id INTEGER"),
        ("icon_url", "ALTER TABLE category ADD COLUMN IF NOT EXISTS icon_url VARCHAR(500)"),
        ("image_url", "ALTER TABLE category ADD COLUMN IF NOT EXISTS image_url VARCHAR(500)"),
        ("is_active", "ALTER TABLE category ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE"),
        ("sort_order", "ALTER TABLE category ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0"),
        ("created_at", "ALTER TABLE category ADD COLUMN IF NOT EXISTS created_at TIMESTAMP"),
        ("updated_at", "ALTER TABLE category ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP"),
    ]
    
    with engine.connect() as conn:
        for col_name, sql in migrations:
            try:
                conn.execute(text(sql))
                conn.commit()
                print(f"  ✓ Added column: {col_name}")
            except Exception as e:
                if "already exists" in str(e).lower() or "duplicate" in str(e).lower():
                    print(f"  - Column {col_name} already exists, skipping")
                else:
                    print(f"  ! Error adding {col_name}: {e}")
        
        # Set defaults for existing rows
        try:
            conn.execute(text("UPDATE category SET is_active = TRUE WHERE is_active IS NULL"))
            conn.execute(text("UPDATE category SET sort_order = id WHERE sort_order IS NULL"))
            conn.execute(text("UPDATE category SET created_at = NOW() WHERE created_at IS NULL"))
            conn.execute(text("UPDATE category SET updated_at = NOW() WHERE updated_at IS NULL"))
            conn.commit()
            print("  ✓ Set default values for existing rows")
        except Exception as e:
            print(f"  ! Error setting defaults: {e}")
    
    print("\nMigration complete!")
    print("Please restart the Render.com service.")

if __name__ == '__main__':
    run_migration()

