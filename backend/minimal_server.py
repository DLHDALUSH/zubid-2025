#!/usr/bin/env python3
"""
Minimal Flask server for ZUBID - Just to test if Flask works
"""

from flask import Flask, jsonify
from flask_cors import CORS

print("Creating Flask app...")
app = Flask(__name__)

print("Setting up CORS...")
CORS(app, origins="*")

print("Setting up routes...")

@app.route('/')
def home():
    return jsonify({
        'message': 'ZUBID Backend is running!',
        'status': 'success',
        'version': '1.0.0'
    })

@app.route('/api/test')
def api_test():
    return jsonify({
        'message': 'API is working!',
        'status': 'success'
    })

@app.route('/api/auctions')
def get_auctions():
    return jsonify({
        'auctions': [
            {
                'id': 1,
                'title': 'Test Auction',
                'description': 'This is a test auction',
                'current_bid': 100.0,
                'status': 'active'
            }
        ],
        'total': 1
    })

if __name__ == '__main__':
    print("\n" + "="*50)
    print("ZUBID Minimal Backend Server")
    print("="*50)
    print("Starting server on http://0.0.0.0:5000")
    print("Test endpoints:")
    print("- http://localhost:5000/")
    print("- http://localhost:5000/api/test")
    print("- http://localhost:5000/api/auctions")
    print("="*50 + "\n")
    
    try:
        app.run(
            debug=False,
            port=5000,
            host='0.0.0.0',
            use_reloader=False,
            threaded=True
        )
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except Exception as e:
        print(f"\nServer error: {e}")
        raise
