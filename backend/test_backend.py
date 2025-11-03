#!/usr/bin/env python
"""Quick test script to check backend issues"""
import sys

try:
    print("Testing imports...")
    from flask import Flask
    from flask_sqlalchemy import SQLAlchemy
    from flask_cors import CORS
    from werkzeug.security import generate_password_hash
    from datetime import datetime, timedelta
    from functools import wraps
    from sqlalchemy import func
    print("[OK] All imports successful")
    
    print("\nTesting app.py import...")
    import app
    print("[OK] app.py imported successfully")
    
    print("\nBackend is OK!")
    
except ImportError as e:
    print(f"[ERROR] Import Error: {e}")
    print("\nPlease install missing dependencies:")
    print("pip install -r requirements.txt")
    sys.exit(1)
    
except SyntaxError as e:
    print(f"✗ Syntax Error: {e}")
    sys.exit(1)
    
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
