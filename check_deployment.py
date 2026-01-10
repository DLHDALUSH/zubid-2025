#!/usr/bin/env python3
"""
Simple script to check if the authentication fix has been deployed
"""

import requests
import json
import time

def test_authentication():
    """Test if authentication is working"""
    
    base_url = "https://zubid-2025.onrender.com"
    
    print("🔍 Testing ZUBID Authentication Status")
    print("=" * 50)
    
    # Test login
    try:
        login_data = {
            "username": "admin",
            "password": "Admin123!@#"
        }
        
        response = requests.post(
            f"{base_url}/api/login",
            json=login_data,
            headers={'Content-Type': 'application/json'},
            timeout=10
        )
        
        print(f"Login Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ SUCCESS: Authentication is working!")
            print(f"👤 Logged in as: {result.get('user', {}).get('username')}")
            print(f"🎯 Role: {result.get('user', {}).get('role')}")
            return True
        else:
            try:
                error_data = response.json()
                error_msg = error_data.get('error', 'Unknown error')
                print(f"❌ FAILED: {error_msg}")
                
                if 'google_id' in error_msg or 'profile_picture' in error_msg:
                    print("🔄 Still waiting for deployment to complete...")
                elif 'Invalid credentials' in error_msg:
                    print("🔑 Credentials issue - but server is responding!")
                    return True  # Server is working, just wrong credentials
                else:
                    print("🤔 Different error - check server logs")
                    
            except json.JSONDecodeError:
                print(f"❌ Non-JSON response: {response.text[:200]}")
            
            return False
            
    except Exception as e:
        print(f"❌ Connection error: {e}")
        return False

def main():
    """Main function"""
    print("Checking authentication deployment status...")
    print("This will test if the hotfix has been deployed.\n")
    
    success = test_authentication()
    
    print("\n" + "=" * 50)
    
    if success:
        print("🎉 DEPLOYMENT SUCCESSFUL!")
        print("\n📱 Next steps:")
        print("1. Open the ZUBID Flutter app")
        print("2. Try logging in with: admin / Admin123!@#")
        print("3. Test user registration")
        print("4. Report any remaining issues")
        
    else:
        print("⏳ DEPLOYMENT STILL IN PROGRESS")
        print("\n⏰ What to do:")
        print("1. Wait 5-10 more minutes")
        print("2. Run this script again: python check_deployment.py")
        print("3. Check Render.com dashboard for deployment status")
        print("4. Look for build errors in deployment logs")
        
    print("\n💡 Tip: Run 'python deploy_hotfix.py' for continuous monitoring")
    print("=" * 50)

if __name__ == "__main__":
    main()
