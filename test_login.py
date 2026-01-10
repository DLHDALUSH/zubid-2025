#!/usr/bin/env python3
"""
Test script to verify the ZUBID backend login endpoint
"""

import requests
import json

def test_login():
    """Test the login endpoint with default admin credentials"""
    
    # Backend URL
    base_url = "https://zubid-2025.onrender.com"
    login_url = f"{base_url}/api/login"
    
    # Default admin credentials
    credentials = {
        "username": "admin",
        "password": "Admin123!@#"
    }
    
    print("Testing ZUBID Backend Login...")
    print(f"URL: {login_url}")
    print(f"Credentials: {credentials['username']} / {credentials['password']}")
    print("-" * 50)
    
    try:
        # Test health check first
        print("1. Testing health check...")
        health_response = requests.get(f"{base_url}/api/health", timeout=10)
        print(f"Health Status: {health_response.status_code}")
        if health_response.status_code == 200:
            health_data = health_response.json()
            print(f"Health Data: {json.dumps(health_data, indent=2)}")
        print()
        
        # Test login
        print("2. Testing login...")
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        
        response = requests.post(
            login_url, 
            json=credentials, 
            headers=headers,
            timeout=10
        )
        
        print(f"Login Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"✅ Login Successful!")
                print(f"Response: {json.dumps(data, indent=2)}")
            except json.JSONDecodeError:
                print(f"✅ Login Successful (non-JSON response)")
                print(f"Response Text: {response.text}")
        else:
            print(f"❌ Login Failed!")
            try:
                error_data = response.json()
                print(f"Error Response: {json.dumps(error_data, indent=2)}")
            except json.JSONDecodeError:
                print(f"Error Text: {response.text}")
                
    except requests.exceptions.RequestException as e:
        print(f"❌ Network Error: {e}")
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")

if __name__ == "__main__":
    test_login()
