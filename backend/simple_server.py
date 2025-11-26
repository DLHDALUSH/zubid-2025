#!/usr/bin/env python3
"""
Simple Flask server for ZUBID authentication testing
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app, origins=["http://localhost:8000", "http://127.0.0.1:8000"])

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "message": "Backend is running"})

@app.route('/api/csrf-token', methods=['GET'])
def csrf_token():
    return jsonify({"csrf_token": "test-token-123"})

@app.route('/api/login', methods=['POST', 'OPTIONS'])
def login():
    if request.method == 'OPTIONS':
        return '', 200
    
    data = request.get_json()
    print(f"Login attempt: {data}")
    
    # Accept any login for testing
    return jsonify({
        "success": True,
        "message": "Login successful!",
        "user": {
            "id": 1,
            "username": data.get('username', 'testuser'),
            "email": data.get('email', 'test@example.com')
        }
    })

@app.route('/api/register', methods=['POST', 'OPTIONS'])
def register():
    if request.method == 'OPTIONS':
        return '', 200
    
    data = request.get_json()
    print(f"Registration attempt: {data}")
    
    # Accept any registration for testing
    return jsonify({
        "success": True,
        "message": "Registration successful!",
        "user": {
            "id": 1,
            "username": data.get('username', 'testuser'),
            "email": data.get('email', 'test@example.com')
        }
    })

@app.route('/api/logout', methods=['POST', 'OPTIONS'])
def logout():
    if request.method == 'OPTIONS':
        return '', 200
    return jsonify({"success": True, "message": "Logged out successfully"})

if __name__ == '__main__':
    print("Starting simple ZUBID backend server...")
    print("Backend available at: http://localhost:5001")
    print("CORS enabled for: http://localhost:8000")
    app.run(host='0.0.0.0', port=5001, debug=False)
