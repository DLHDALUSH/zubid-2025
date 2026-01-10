#!/usr/bin/env python3
"""
Deploy hotfix to production server
This script will trigger a deployment to fix the database column issue
"""

import requests
import time
import json

def check_deployment_status():
    """Check if the deployment has updated the production server"""
    
    base_url = "https://zubid-2025.onrender.com"
    
    print("🚀 Checking Production Deployment Status")
    print("=" * 50)
    
    # Check if the server is responding
    print("1. Testing server connectivity...")
    try:
        health_response = requests.get(f"{base_url}/api/health", timeout=10)
        if health_response.status_code == 200:
            health_data = health_response.json()
            print(f"   ✅ Server is responding: {health_data.get('status')}")
            print(f"   📊 Database: {health_data.get('database')}")
            print(f"   🕐 Timestamp: {health_data.get('timestamp')}")
        else:
            print(f"   ⚠️ Server returned: {health_response.status_code}")
            return False
    except Exception as e:
        print(f"   ❌ Server connectivity failed: {e}")
        return False
    
    # Test database initialization
    print("\n2. Testing database initialization...")
    try:
        init_response = requests.post(f"{base_url}/api/admin/init-database", timeout=60)
        print(f"   Status Code: {init_response.status_code}")
        
        if init_response.status_code == 200:
            init_data = init_response.json()
            print(f"   ✅ Database initialization successful!")
            print(f"   📋 Message: {init_data.get('message')}")
        else:
            try:
                error_data = init_response.json()
                error_msg = error_data.get('error', 'Unknown error')
                print(f"   ❌ Database initialization failed:")
                print(f"   📝 Error: {error_msg[:200]}...")
                
                # Check if it's still the column issue
                if 'google_id' in error_msg or 'profile_picture' in error_msg:
                    print(f"   🔄 Still waiting for deployment to update...")
                    return False
                else:
                    print(f"   🤔 Different error - might be a new issue")
                    
            except json.JSONDecodeError:
                print(f"   ❌ Non-JSON error response")
                
    except Exception as e:
        print(f"   ❌ Database initialization request failed: {e}")
        return False
    
    # Test login functionality
    print("\n3. Testing login functionality...")
    try:
        login_data = {
            "username": "admin",
            "password": "Admin123!@#"
        }
        
        login_response = requests.post(
            f"{base_url}/api/login",
            json=login_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        print(f"   Status Code: {login_response.status_code}")
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            print(f"   ✅ Login successful!")
            print(f"   👤 User: {login_result.get('user', {}).get('username')}")
            print(f"   🎯 Role: {login_result.get('user', {}).get('role')}")
            return True
        else:
            try:
                error_data = login_response.json()
                print(f"   ❌ Login failed: {error_data.get('error')}")
            except json.JSONDecodeError:
                print(f"   ❌ Login failed with non-JSON response")
            return False
            
    except Exception as e:
        print(f"   ❌ Login test failed: {e}")
        return False

def wait_for_deployment():
    """Wait for the deployment to complete and test periodically"""
    
    print("⏳ Waiting for deployment to complete...")
    print("This may take several minutes as Render.com rebuilds the application.")
    print()
    
    max_attempts = 20  # Wait up to 10 minutes (30 seconds * 20)
    attempt = 1
    
    while attempt <= max_attempts:
        print(f"🔍 Attempt {attempt}/{max_attempts} - Checking deployment status...")
        
        if check_deployment_status():
            print("\n" + "=" * 50)
            print("🎉 SUCCESS: Deployment completed and authentication is working!")
            print("✅ Login and signup should now work in the Flutter app")
            print("\n📱 Next steps:")
            print("   1. Test login in the Flutter app with: admin / Admin123!@#")
            print("   2. Test user registration")
            print("   3. Verify all authentication features work")
            print("=" * 50)
            return True
        
        if attempt < max_attempts:
            print(f"   ⏳ Deployment not ready yet. Waiting 30 seconds...")
            time.sleep(30)
        
        attempt += 1
    
    print("\n" + "=" * 50)
    print("⏰ TIMEOUT: Deployment is taking longer than expected")
    print("🔧 Manual check needed:")
    print("   1. Check Render.com dashboard for deployment status")
    print("   2. Look for build errors in the deployment logs")
    print("   3. Try running the test script again later")
    print("=" * 50)
    return False

def main():
    """Main function"""
    print("Starting deployment monitoring...")
    print("Note: The hotfix has been committed to the repository.")
    print("Render.com should automatically deploy the changes.")
    print()
    
    success = wait_for_deployment()
    
    if not success:
        print("\n💡 Alternative solutions:")
        print("   1. Manually trigger a redeploy on Render.com")
        print("   2. Check the deployment logs for any errors")
        print("   3. Contact support if the issue persists")

if __name__ == "__main__":
    main()
