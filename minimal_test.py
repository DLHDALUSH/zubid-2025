#!/usr/bin/env python3
"""
Minimal test to check what's causing the timeout
"""
import os
import sys

print("Step 1: Setting environment variables...")
os.environ['DB_USE_NULLPOOL'] = 'true'
os.environ['DATABASE_URI'] = 'postgresql://test:test@localhost/test'
os.environ['SKIP_DB_INIT'] = 'true'

print("Step 2: Adding backend to path...")
sys.path.insert(0, 'backend')

print("Step 3: Testing basic imports...")
try:
    print("  - Importing Flask...")
    from flask import Flask
    print("  ✅ Flask imported")
    
    print("  - Importing SQLAlchemy...")
    from flask_sqlalchemy import SQLAlchemy
    print("  ✅ SQLAlchemy imported")
    
    print("  - Importing app module...")
    import backend.app as app_module
    print("  ✅ App module imported")
    
    print("Step 4: Checking configuration...")
    app = app_module.app
    print(f"  - Database URI: {app.config.get('SQLALCHEMY_DATABASE_URI', 'NOT SET')}")
    print(f"  - Engine options: {app.config.get('SQLALCHEMY_ENGINE_OPTIONS', 'NOT SET')}")
    
    print("✅ All tests completed successfully!")
    
except Exception as e:
    print(f"❌ Error at step: {e}")
    import traceback
    traceback.print_exc()
