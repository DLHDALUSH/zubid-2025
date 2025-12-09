#!/usr/bin/env python
"""Test script to verify market_price column exists and backend can run"""

import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app import app, db
from sqlalchemy import inspect

def test_market_price():
    """Test that market_price column exists"""
    with app.app_context():
        try:
            inspector = inspect(db.engine)
            columns = [col['name'] for col in inspector.get_columns('auction')]
            
            print("=" * 60)
            print("Testing market_price column")
            print("=" * 60)
            print(f"\nAuction table columns: {columns}")
            
            if 'market_price' in columns:
                print("\n[OK] market_price column exists!")
                print("[OK] Backend should be able to run successfully")
                return True
            else:
                print("\n[ERROR] market_price column NOT found!")
                print("Please run: python migrate_market_price.py")
                return False
                
        except Exception as e:
            print(f"\n[ERROR] Error: {e}")
            import traceback
            traceback.print_exc()
            return False

if __name__ == '__main__':
    if test_market_price():
        print("\n" + "=" * 60)
        print("[OK] All tests passed! Backend is ready to run.")
        print("=" * 60)
        sys.exit(0)
    else:
        print("\n" + "=" * 60)
        print("[ERROR] Tests failed! Please fix the issues above.")
        print("=" * 60)
        sys.exit(1)

