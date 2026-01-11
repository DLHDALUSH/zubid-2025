#!/usr/bin/env python3
"""
ZUBID Production Server Test Script
Tests all major endpoints and functionality on the production server.
"""

import requests
import json
import time
from datetime import datetime

# Production server configuration
PRODUCTION_URL = "https://zubid-2025.onrender.com"
API_BASE = f"{PRODUCTION_URL}/api"

def test_endpoint(name, url, method="GET", data=None, headers=None):
    """Test a single endpoint and return the result."""
    print(f"🧪 Testing {name}...")
    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=30)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=30)
        elif method == "PUT":
            response = requests.put(url, json=data, headers=headers, timeout=30)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers, timeout=30)
        
        print(f"   Status: {response.status_code}")
        if response.status_code < 400:
            print(f"   ✅ {name} - SUCCESS")
            return True, response
        else:
            print(f"   ❌ {name} - FAILED ({response.status_code})")
            return False, response
    except Exception as e:
        print(f"   ❌ {name} - ERROR: {str(e)}")
        return False, None

def main():
    print("🌐 ZUBID Production Server Test")
    print("=" * 50)
    print(f"🎯 Target: {PRODUCTION_URL}")
    print(f"⏰ Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    # Test results
    results = {}
    
    # 1. Test server health
    success, response = test_endpoint("Server Health", f"{PRODUCTION_URL}/")
    results["server_health"] = success
    
    # 2. Test API health
    success, response = test_endpoint("API Health", f"{API_BASE}/health")
    results["api_health"] = success
    
    # 3. Test categories
    success, response = test_endpoint("Categories", f"{API_BASE}/categories")
    results["categories"] = success
    if success and response:
        categories = response.json()
        print(f"   📊 Found {len(categories)} categories")
    
    # 4. Test auctions
    success, response = test_endpoint("Auctions", f"{API_BASE}/auctions")
    results["auctions"] = success
    if success and response:
        auctions = response.json()
        print(f"   🏷️ Found {len(auctions)} auctions")
    
    # 5. Test authentication endpoints
    success, response = test_endpoint("Login Endpoint", f"{API_BASE}/auth/login", "POST", {
        "username": "test",
        "password": "test"
    })
    results["auth_login"] = success
    
    # 6. Test registration endpoint
    success, response = test_endpoint("Register Endpoint", f"{API_BASE}/auth/register", "POST", {
        "username": "test_user",
        "email": "test@example.com",
        "password": "Test123!@#"
    })
    results["auth_register"] = success
    
    # 7. Test WebSocket endpoint (basic connection test)
    print("🧪 Testing WebSocket Connection...")
    try:
        import websocket
        ws_url = f"wss://zubid-2025.onrender.com/ws"
        ws = websocket.create_connection(ws_url, timeout=10)
        ws.close()
        print("   ✅ WebSocket Connection - SUCCESS")
        results["websocket"] = True
    except Exception as e:
        print(f"   ❌ WebSocket Connection - ERROR: {str(e)}")
        results["websocket"] = False
    
    # 8. Test static files
    success, response = test_endpoint("Static Files", f"{PRODUCTION_URL}/static/css/style.css")
    results["static_files"] = success
    
    # 9. Test admin page
    success, response = test_endpoint("Admin Page", f"{PRODUCTION_URL}/admin.html")
    results["admin_page"] = success
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 TEST SUMMARY")
    print("=" * 50)
    
    total_tests = len(results)
    passed_tests = sum(1 for result in results.values() if result)
    failed_tests = total_tests - passed_tests
    
    print(f"✅ Passed: {passed_tests}/{total_tests}")
    print(f"❌ Failed: {failed_tests}/{total_tests}")
    print(f"📈 Success Rate: {(passed_tests/total_tests)*100:.1f}%")
    
    print("\n📋 Detailed Results:")
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"   {test_name}: {status}")
    
    # Recommendations
    print("\n🎯 RECOMMENDATIONS:")
    if results.get("server_health", False):
        print("✅ Server is online and responding")
    else:
        print("❌ Server may be sleeping - try again in 1-2 minutes")
    
    if results.get("categories", False) and results.get("auctions", False):
        print("✅ Core auction functionality is working")
    else:
        print("❌ Core auction endpoints may need attention")
    
    if results.get("auth_login", False) or results.get("auth_register", False):
        print("✅ Authentication system is functional")
    else:
        print("❌ Authentication endpoints may need configuration")
    
    if results.get("websocket", False):
        print("✅ Real-time bidding should work")
    else:
        print("❌ WebSocket connection failed - real-time features may not work")
    
    print("\n🌐 Access URLs:")
    print(f"   Web App: {PRODUCTION_URL}")
    print(f"   Admin Panel: {PRODUCTION_URL}/admin.html")
    print(f"   API Docs: {PRODUCTION_URL}/api")
    print(f"   Mobile Config: Use production server URL in Flutter app")
    
    print("\n🔐 Login Credentials:")
    print("   Admin: admin / Admin123!@#")
    print("   Users: any_username / User123!@#")
    
    print("\n🎉 Production server test completed!")

if __name__ == "__main__":
    main()
