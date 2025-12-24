#!/usr/bin/env python3
"""
Debug script to identify what's causing the startup hang
"""

import os
import sys

print("=== ZUBID Backend Debug Startup ===")
print(f"Python version: {sys.version}")
print(f"Current directory: {os.getcwd()}")

# Set environment variables
os.environ['DATABASE_URI'] = 'sqlite:///auction.db'
os.environ['FLASK_ENV'] = 'development'

print("Environment variables set:")
print(f"DATABASE_URI: {os.getenv('DATABASE_URI')}")
print(f"FLASK_ENV: {os.getenv('FLASK_ENV')}")

print("\n1. Testing basic imports...")
try:
    import flask
    print(f"✓ Flask imported successfully (version: {flask.__version__})")
except Exception as e:
    print(f"✗ Flask import failed: {e}")
    sys.exit(1)

try:
    from flask_sqlalchemy import SQLAlchemy
    print("✓ Flask-SQLAlchemy imported successfully")
except Exception as e:
    print(f"✗ Flask-SQLAlchemy import failed: {e}")
    sys.exit(1)

try:
    from flask_cors import CORS
    print("✓ Flask-CORS imported successfully")
except Exception as e:
    print(f"✗ Flask-CORS import failed: {e}")
    sys.exit(1)

print("\n2. Testing Flask app creation...")
try:
    from flask import Flask
    app = Flask(__name__)
    print("✓ Flask app created successfully")
except Exception as e:
    print(f"✗ Flask app creation failed: {e}")
    sys.exit(1)

print("\n3. Testing database configuration...")
try:
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    db = SQLAlchemy(app)
    print("✓ Database configuration successful")
except Exception as e:
    print(f"✗ Database configuration failed: {e}")
    sys.exit(1)

print("\n4. Testing CORS setup...")
try:
    CORS(app)
    print("✓ CORS setup successful")
except Exception as e:
    print(f"✗ CORS setup failed: {e}")
    sys.exit(1)

print("\n5. Testing basic route...")
try:
    @app.route('/test')
    def test():
        return {'status': 'ok'}
    print("✓ Route creation successful")
except Exception as e:
    print(f"✗ Route creation failed: {e}")
    sys.exit(1)

print("\n6. Testing app context...")
try:
    with app.app_context():
        print("✓ App context works")
except Exception as e:
    print(f"✗ App context failed: {e}")
    sys.exit(1)

print("\n7. Testing server startup...")
try:
    print("Starting Flask development server...")
    print("Server should be available at: http://localhost:5000/test")
    app.run(debug=False, port=5000, host='0.0.0.0', use_reloader=False)
except Exception as e:
    print(f"✗ Server startup failed: {e}")
    sys.exit(1)
