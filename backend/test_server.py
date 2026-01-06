#!/usr/bin/env python3
"""
Minimal test server to debug startup issues
"""

import os
import sys

print("Starting test server...")
print(f"Python version: {sys.version}")
print(f"Current directory: {os.getcwd()}")

try:
    print("Importing Flask...")
    from flask import Flask, jsonify, session, request
    print("Flask imported successfully")
    
    print("Creating Flask app...")
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'test-secret-key-for-debugging'
    print("Flask app created")
    
    print("Importing CORS...")
    from flask_cors import CORS
    CORS(app, supports_credentials=True, origins=['http://localhost:3000', 'http://127.0.0.1:3000'])
    print("CORS configured")
    
    @app.route('/api/test', methods=['GET'])
    def test_endpoint():
        return jsonify({'message': 'Test server is working', 'status': 'ok'})
    
    @app.route('/api/login', methods=['POST'])
    def test_login():
        data = request.get_json() or {}
        username = data.get('username', '')
        password = data.get('password', '')
        
        if username == 'admin' and password == 'Admin123!@#':
            session['user_id'] = 1
            session['username'] = 'admin'
            return jsonify({
                'message': 'Login successful',
                'user': {
                    'id': '1',
                    'username': 'admin',
                    'role': 'admin'
                }
            })
        else:
            return jsonify({'error': 'Invalid credentials'}), 401
    
    @app.route('/api/user/profile', methods=['GET'])
    def test_profile():
        if 'user_id' not in session:
            return jsonify({'error': 'Authentication required'}), 401
        
        return jsonify({
            'profile': {
                'id': 1,
                'username': 'admin',
                'email': 'admin@zubid.com',
                'role': 'admin'
            }
        })
    
    @app.route('/api/logout', methods=['POST'])
    def test_logout():
        session.clear()
        return jsonify({'message': 'Logout successful'})
    
    print("Routes configured")
    print("Starting server on http://0.0.0.0:5000")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
    
except Exception as e:
    print(f"Error starting server: {e}")
    import traceback
    traceback.print_exc()
