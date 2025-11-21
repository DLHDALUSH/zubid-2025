#!/usr/bin/env python
"""Migration script to add qr_code_url column and generate QR codes for existing auctions"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app import app, db, Auction, generate_qr_code
from sqlalchemy import inspect, text

def migrate_qr_codes():
    """Add qr_code_url column and generate QR codes for existing auctions"""
    with app.app_context():
        try:
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            
            if 'auction' not in tables:
                print("Auction table doesn't exist!")
                return False
            
            # Check if qr_code_url column exists
            columns = [col['name'] for col in inspector.get_columns('auction')]
            print(f"Current Auction table columns: {columns}")
            
            # Add qr_code_url column if it doesn't exist
            if 'qr_code_url' not in columns:
                print("Adding qr_code_url column to Auction table...")
                with db.engine.connect() as conn:
                    conn.execute(text("ALTER TABLE auction ADD COLUMN qr_code_url VARCHAR(500)"))
                    conn.commit()
                print("[OK] qr_code_url column added successfully!")
            else:
                print("[OK] qr_code_url column already exists")
            
            # Generate QR codes for auctions that don't have them
            auctions_without_qr = Auction.query.filter_by(qr_code_url=None).all()
            if auctions_without_qr:
                print(f"\nGenerating QR codes for {len(auctions_without_qr)} auctions...")
                for auction in auctions_without_qr:
                    try:
                        qr_code_url = generate_qr_code(auction.id, auction.item_name, auction.current_bid or auction.starting_bid)
                        if qr_code_url:
                            auction.qr_code_url = qr_code_url
                            print(f"  [OK] Generated QR code for auction #{auction.id}: {auction.item_name}")
                        else:
                            print(f"  [ERROR] Failed to generate QR code for auction #{auction.id}")
                    except Exception as e:
                        print(f"  [ERROR] Error generating QR code for auction #{auction.id}: {e}")
                
                db.session.commit()
                print(f"\n[OK] QR codes generated for {len(auctions_without_qr)} auctions!")
            else:
                print("\n[OK] All auctions already have QR codes")
            
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
    print("QR Code Migration Script")
    print("=" * 60)
    print()
    
    if migrate_qr_codes():
        print("\n[OK] Migration completed successfully!")
        print("\nYou can now restart the backend server.")
    else:
        print("\n[ERROR] Migration failed. Please check the error messages above.")
        sys.exit(1)

