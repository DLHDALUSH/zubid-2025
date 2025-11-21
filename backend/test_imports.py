#!/usr/bin/env python
"""Test script to verify all backend imports work correctly"""

import sys
import os

print("Testing backend imports...")
print("=" * 50)

try:
    from app import app, db, limiter
    print("[OK] Flask app imported successfully")
    print(f"[OK] App name: {app.name}")
    print(f"[OK] Database URI: {app.config.get('SQLALCHEMY_DATABASE_URI', 'Not set')}")
    print(f"[OK] Secret key configured: {'Yes' if app.config.get('SECRET_KEY') else 'No'}")
    
    # Check upload folder
    upload_folder = os.getenv('UPLOAD_FOLDER', 'uploads')
    if os.path.exists(upload_folder):
        print(f"[OK] Upload folder exists: {os.path.abspath(upload_folder)}")
    else:
        print(f"[WARN] Upload folder missing: {upload_folder}")
    
    print("\n" + "=" * 50)
    print("All imports successful! Backend is ready to run.")
    print("=" * 50)
    print("\nTo start the backend server, run:")
    print("  python app.py")
    print("\nOr for production:")
    print("  gunicorn -c gunicorn_config.py app:app")
    
except ImportError as e:
    print(f"[ERROR] Import error: {e}")
    print("\nPlease install missing dependencies:")
    print("  pip install -r requirements.txt")
    sys.exit(1)
except Exception as e:
    print(f"[ERROR] Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

