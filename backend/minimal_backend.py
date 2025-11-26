from flask import Flask, jsonify, request
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

# Test endpoint
@app.route('/api/test')
def test():
    return jsonify({'message': 'Backend is working!', 'status': 'ok'})

# Health check
@app.route('/api/health')
def health():
    return jsonify({'status': 'healthy', 'message': 'ZUBID Backend is running'})

# CSRF token endpoint
@app.route('/api/csrf-token')
def csrf_token():
    return jsonify({'csrf_token': 'test-token-123'})

# User profile endpoint
@app.route('/api/user/profile')
def user_profile():
    return jsonify({'error': 'Not authenticated'}), 401

# Featured auctions endpoint
@app.route('/api/featured')
def featured():
    return jsonify([])

# Auctions endpoint
@app.route('/api/auctions')
def auctions():
    return jsonify({'auctions': [], 'total': 0, 'page': 1, 'per_page': 10})

# Categories endpoint
@app.route('/api/categories')
def categories():
    return jsonify([])

# Logout endpoint
@app.route('/api/logout', methods=['POST'])
def logout():
    return jsonify({'message': 'Logged out successfully'})

# Simple login endpoint for testing
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({'error': 'Email and password required'}), 400
    
    # Simple test - accept any email/password for now
    return jsonify({
        'message': 'Login successful (test mode)',
        'user': {'email': email, 'id': 1}
    })

# Simple register endpoint for testing
@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    
    if not email or not password or not name:
        return jsonify({'error': 'Name, email and password required'}), 400
    
    # Simple test - accept any registration for now
    return jsonify({
        'message': 'Registration successful (test mode)',
        'user': {'email': email, 'name': name, 'id': 1}
    })

if __name__ == '__main__':
    print("Starting minimal ZUBID backend...")
    print("Backend will be available at: http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
