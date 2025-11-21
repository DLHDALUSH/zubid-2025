"""
Migration script to fix Image.url column from String(500) to Text
This allows storing full data URIs without truncation
"""
from app import app, db
from sqlalchemy import text

def migrate_image_url_column():
    """Change Image.url column from String(500) to Text"""
    with app.app_context():
        try:
            # Check current column type
            result = db.session.execute(text("""
                SELECT sql FROM sqlite_master 
                WHERE type='table' AND name='image'
            """))
            table_sql = result.fetchone()
            if table_sql:
                print("Current table definition:")
                print(table_sql[0])
            
            # For SQLite, we need to recreate the table
            # SQLite doesn't support ALTER COLUMN directly
            print("\n⚠️  SQLite detected - recreating table...")
            
            # Step 1: Create new table with correct schema
            db.session.execute(text("""
                CREATE TABLE image_new (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    auction_id INTEGER NOT NULL,
                    url TEXT NOT NULL,
                    is_primary BOOLEAN DEFAULT 0,
                    FOREIGN KEY(auction_id) REFERENCES auction(id)
                )
            """))
            
            # Step 2: Copy data from old table
            db.session.execute(text("""
                INSERT INTO image_new (id, auction_id, url, is_primary)
                SELECT id, auction_id, url, is_primary FROM image
            """))
            
            # Step 3: Drop old table
            db.session.execute(text("DROP TABLE image"))
            
            # Step 4: Rename new table
            db.session.execute(text("ALTER TABLE image_new RENAME TO image"))
            
            # Step 5: Recreate indexes
            db.session.execute(text("""
                CREATE INDEX ix_image_auction_id ON image(auction_id)
            """))
            
            db.session.commit()
            print("✅ Migration completed successfully!")
            print("Image.url column is now TEXT (unlimited length)")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Migration failed: {str(e)}")
            print("If using PostgreSQL or MySQL, you may need to run:")
            print("ALTER TABLE image ALTER COLUMN url TYPE TEXT;")
            raise

if __name__ == '__main__':
    print("=" * 60)
    print("Image URL Column Migration")
    print("=" * 60)
    print("\nThis will change Image.url from String(500) to Text")
    print("to support full-length data URIs.\n")
    
    response = input("Continue? (yes/no): ")
    if response.lower() == 'yes':
        migrate_image_url_column()
    else:
        print("Migration cancelled.")

