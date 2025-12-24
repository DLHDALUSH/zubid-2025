#!/usr/bin/env python3
"""
Test server to verify backend functionality
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os

app = Flask(__name__)

# Enable CORS for mobile app
CORS(app, 
     supports_credentials=False,
     origins="*",
     allow_headers=['Content-Type', 'Authorization'],
     methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])

@app.route('/api/test', methods=['GET'])
def test():
    return jsonify({
        'status': 'success',
        'message': 'ZUBID Backend is running!',
        'version': '1.0.0'
    })

@app.route('/api/auctions', methods=['GET'])
def get_auctions():
    # Mock auction data
    return jsonify({
        'auctions': [
            {
                'id': 1,
                'title': 'Test Auction 1',
                'description': 'This is a test auction',
                'current_bid': 100.0,
                'status': 'active',
                'end_time': '2025-12-25T12:00:00Z',
                'images': []
            },
            {
                'id': 2,
                'title': 'Test Auction 2', 
                'description': 'Another test auction',
                'current_bid': 250.0,
                'status': 'active',
                'end_time': '2025-12-26T15:30:00Z',
                'images': []
            }
        ],
        'total': 2,
        'page': 1,
        'per_page': 10,
        'pages': 1
    })

@app.route('/api/login', methods=['POST', 'OPTIONS'])
def login():
    if request.method == 'OPTIONS':
        return '', 200
    
    data = request.get_json()
    print(f"Login attempt: {data}")
    
    # Mock successful login
    return jsonify({
        'success': True,
        'message': 'Login successful',
        'user': {
            'id': 1,
            'username': data.get('username', 'testuser'),
            'email': 'test@zubid.com',
            'role': 'user'
        }
    })

@app.route('/api/register', methods=['POST', 'OPTIONS'])
def register():
    if request.method == 'OPTIONS':
        return '', 200
    
    data = request.get_json()
    print(f"Register attempt: {data}")
    
    # Mock successful registration
    return jsonify({
        'success': True,
        'message': 'Registration successful',
        'user': {
            'id': 2,
            'username': data.get('username', 'newuser'),
            'email': data.get('email', 'new@zubid.com'),
            'role': 'user'
        }
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', '5000'))
    host = os.getenv('HOST', '0.0.0.0')
    
    print("\n" + "="*50)
    print("ZUBID Test Backend Server Starting...")
    print("="*50)
    print(f"Server will run on: http://{host}:{port}")
    print(f"API Test: http://{host}:{port}/api/test")
    print(f"Mock Auctions: http://{host}:{port}/api/auctions")
    print("="*50 + "\n")
    
    try:
        app.run(debug=True, port=port, host=host, use_reloader=False)
    except Exception as e:
        print(f"\n[ERROR] Failed to start server: {e}")
        raise
