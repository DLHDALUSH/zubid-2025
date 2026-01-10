#!/usr/bin/env python3
"""
Script to fix the production database by running the migration
This script will add missing columns to the User table on the production server
"""

import requests
import json
import os
import sys

def run_migration_on_production():
    """Run the database migration on the production server"""
    
    base_url = "https://zubid-2025.onrender.com"
    
    print("🔧 Fixing ZUBID Production Database")
    print("=" * 50)
    
    # Step 1: Check current health
    print("1. Checking server health...")
    try:
        health_response = requests.get(f"{base_url}/api/health", timeout=10)
        if health_response.status_code == 200:
            health_data = health_response.json()
            print(f"   ✅ Server is healthy: {health_data.get('status')}")
            print(f"   📊 Database: {health_data.get('database')}")
        else:
            print(f"   ⚠️ Health check returned: {health_response.status_code}")
    except Exception as e:
        print(f"   ❌ Health check failed: {e}")
        return False
    
    # Step 2: Try to initialize database (this should add missing columns)
    print("\n2. Running database initialization...")
    try:
        init_response = requests.post(f"{base_url}/api/admin/init-database", timeout=60)
        print(f"   Status Code: {init_response.status_code}")
        
        if init_response.status_code == 200:
            init_data = init_response.json()
            print(f"   ✅ Database initialization successful!")
            print(f"   📋 Response: {init_data.get('message')}")
        else:
            # Print the error to understand what's still missing
            try:
                error_data = init_response.json()
                error_msg = error_data.get('error', 'Unknown error')
                print(f"   ❌ Database initialization failed:")
                print(f"   📝 Error: {error_msg}")
                
                # Check if it's still the missing column issue
                if 'google_id' in error_msg or 'profile_picture' in error_msg:
                    print(f"   🔍 Still missing columns - this needs manual database migration")
                    return False
                else:
                    print(f"   🤔 Different error - might be resolved now")
                    
            except json.JSONDecodeError:
                print(f"   ❌ Non-JSON error response: {init_response.text}")
                
    except Exception as e:
        print(f"   ❌ Database initialization request failed: {e}")
        return False
    
    # Step 3: Test login with admin credentials
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
                print(f"   ❌ Login failed with non-JSON response: {login_response.text}")
            return False
            
    except Exception as e:
        print(f"   ❌ Login test failed: {e}")
        return False

def main():
    """Main function"""
    print("Starting production database fix...")
    
    success = run_migration_on_production()
    
    print("\n" + "=" * 50)
    if success:
        print("🎉 SUCCESS: Production database is now working!")
        print("✅ Login and signup should work in the Flutter app")
        print("\n📱 Next steps:")
        print("   1. Test login in the Flutter app with: admin / Admin123!@#")
        print("   2. Test user registration")
        print("   3. Verify all authentication features work")
    else:
        print("❌ FAILED: Production database still has issues")
        print("\n🔧 Manual intervention needed:")
        print("   1. The database migration needs to be run manually on the server")
        print("   2. Contact the hosting provider to run the migration script")
        print("   3. Or deploy a new version with the database fixes")
    
    print("=" * 50)

if __name__ == "__main__":
    main()
