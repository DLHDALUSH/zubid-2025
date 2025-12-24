#!/usr/bin/env python3
"""
Simple HTTP server for ZUBID authentication testing using built-in http.server
"""

import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading

class ZubidHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', 'http://localhost:8000')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', 'http://localhost:8000')
            self.end_headers()
            response = {"status": "ok", "message": "Backend is running"}
            self.wfile.write(json.dumps(response).encode())
            
        elif parsed_path.path == '/api/csrf-token':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', 'http://localhost:8000')
            self.end_headers()
            response = {"csrf_token": "test-token-123"}
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed_path = urlparse(self.path)
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data.decode('utf-8'))
        except:
            data = {}
        
        if parsed_path.path == '/api/login':
            print(f"Login attempt: {data}")
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', 'http://localhost:8000')
            self.end_headers()
            response = {
                "success": True,
                "message": "Login successful!",
                "user": {
                    "id": 1,
                    "username": data.get('username', 'testuser'),
                    "email": data.get('email', 'test@example.com')
                }
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif parsed_path.path == '/api/register':
            print(f"Registration attempt: {data}")
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', 'http://localhost:8000')
            self.end_headers()
            response = {
                "success": True,
                "message": "Registration successful!",
                "user": {
                    "id": 1,
                    "username": data.get('username', 'testuser'),
                    "email": data.get('email', 'test@example.com')
                }
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif parsed_path.path == '/api/logout':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', 'http://localhost:8000')
            self.end_headers()
            response = {"success": True, "message": "Logged out successfully"}
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    server = HTTPServer(('localhost', 5002), ZubidHandler)
    print("Starting ZUBID HTTP server...")
    print("Backend available at: http://localhost:5002")
    print("CORS enabled for: http://localhost:8000")
    server.serve_forever()
