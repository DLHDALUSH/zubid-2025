#!/usr/bin/env python3
"""
Quick test script to verify database connection and pool configuration
"""
import os
import sys

# Set environment variables for testing
os.environ['DB_USE_NULLPOOL'] = 'true'
os.environ['DATABASE_URI'] = 'postgresql://test:test@localhost/test'  # Test with PostgreSQL URI
os.environ['SKIP_DB_INIT'] = 'true'  # Skip auto-initialization during import

try:
    print("1. Testing imports...")
    sys.path.insert(0, 'backend')
    
    print("2. Importing Flask app...")
    from backend.app import app, db
    
    print("3. Testing app context...")
    with app.app_context():
        print("4. Checking database configuration...")
        print(f"   Database URI: {app.config['SQLALCHEMY_DATABASE_URI']}")
        print(f"   Engine options: {app.config.get('SQLALCHEMY_ENGINE_OPTIONS', {})}")
        
        print("5. Testing database connection...")
        from sqlalchemy import text
        result = db.session.execute(text('SELECT 1')).scalar()
        print(f"   Connection test result: {result}")
        
        print("6. Testing pool info...")
        try:
            engine = db.engine
            pool = engine.pool
            print(f"   Pool class: {type(pool).__name__}")
            print(f"   Pool size: {getattr(pool, 'size', 'N/A')}")
        except Exception as e:
            print(f"   Pool info error: {e}")
        
        print("✅ All tests passed!")

except Exception as e:
    print(f"❌ Test failed: {e}")
    import traceback
    traceback.print_exc()
