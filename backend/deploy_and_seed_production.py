#!/usr/bin/env python3
"""
Deploy and Seed Production Database Script
This script deploys the latest code and seeds the production database
"""

import os
import sys
import subprocess
import requests
import time

def check_server_status(url, max_retries=5):
    """Check if the server is responding"""
    for i in range(max_retries):
        try:
            print(f"🔍 Checking server status ({i+1}/{max_retries})...")
            response = requests.get(f"{url}/api/health", timeout=10)
            if response.status_code == 200:
                print(f"✅ Server is responding at {url}")
                return True
        except Exception as e:
            print(f"⚠️ Server check failed: {e}")
            if i < max_retries - 1:
                print("⏳ Waiting 10 seconds before retry...")
                time.sleep(10)
    
    print(f"❌ Server is not responding at {url}")
    return False

def deploy_to_render():
    """Deploy to Render by triggering a new deployment"""
    print("🚀 Deploying to Render...")
    
    # Check if we can trigger a deployment via git push
    try:
        # Check if we're in a git repository
        result = subprocess.run(['git', 'status'], capture_output=True, text=True)
        if result.returncode != 0:
            print("❌ Not in a git repository")
            return False
        
        # Check for uncommitted changes
        result = subprocess.run(['git', 'status', '--porcelain'], capture_output=True, text=True)
        if result.stdout.strip():
            print("📝 Committing changes...")
            subprocess.run(['git', 'add', '.'], check=True)
            subprocess.run(['git', 'commit', '-m', 'Update production database seeding'], check=True)
        
        # Push to main branch to trigger Render deployment
        print("📤 Pushing to main branch...")
        result = subprocess.run(['git', 'push', 'origin', 'main'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Code pushed successfully")
            print("⏳ Waiting for Render deployment (this may take 2-3 minutes)...")
            time.sleep(180)  # Wait 3 minutes for deployment
            return True
        else:
            print(f"❌ Git push failed: {result.stderr}")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Git operation failed: {e}")
        return False
    except Exception as e:
        print(f"❌ Deployment error: {e}")
        return False

def seed_production_database(server_url):
    """Seed the production database"""
    print(f"🌱 Seeding production database at {server_url}...")
    
    try:
        # First, initialize the database
        print("🔧 Initializing database...")
        response = requests.post(f"{server_url}/api/admin/init-db", timeout=60)
        if response.status_code == 200:
            print("✅ Database initialized")
        else:
            print(f"⚠️ Database init response: {response.status_code}")
        
        # Run the seeding script locally but targeting production
        print("🌱 Running production seeding script...")
        
        # Set environment variable to target production database
        env = os.environ.copy()
        env['DATABASE_URI'] = 'production'  # This will be handled by the script
        env['PRODUCTION_SERVER'] = server_url
        
        # Run the direct seeding script
        result = subprocess.run([
            sys.executable, 'seed_production_direct.py'
        ], capture_output=True, text=True, env=env, cwd=os.path.dirname(os.path.abspath(__file__)))
        
        if result.returncode == 0:
            print("✅ Production database seeded successfully!")
            print(result.stdout)
            return True
        else:
            print("❌ Seeding failed!")
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Error seeding database: {e}")
        return False

def main():
    """Main function"""
    print("🚀 ZUBID Production Deployment & Seeding")
    print("=" * 50)
    
    # Production server URLs
    production_servers = [
        'https://zubid-2025.onrender.com',
        'https://zubidauction.duckdns.org'
    ]
    
    # Ask user which server to target
    print("Select production server:")
    for i, server in enumerate(production_servers, 1):
        print(f"  {i}. {server}")
    
    try:
        choice = input("Enter choice (1-2) or press Enter for Render: ").strip()
        if not choice:
            choice = "1"
        
        server_index = int(choice) - 1
        if server_index < 0 or server_index >= len(production_servers):
            print("❌ Invalid choice")
            return 1
        
        target_server = production_servers[server_index]
        print(f"🎯 Target server: {target_server}")
        
    except (ValueError, KeyboardInterrupt):
        print("❌ Invalid input or cancelled")
        return 1
    
    # Deploy if targeting Render
    if 'render' in target_server:
        if not deploy_to_render():
            print("❌ Deployment failed")
            return 1
    
    # Check server status
    if not check_server_status(target_server):
        print("❌ Server is not accessible")
        return 1
    
    # Seed the database
    if not seed_production_database(target_server):
        print("❌ Database seeding failed")
        return 1
    
    print("\n" + "=" * 50)
    print("🎉 Production deployment and seeding completed!")
    print(f"🌐 Server: {target_server}")
    print("🔐 Admin: admin / Admin123!@#")
    print("👥 Users: any username / User123!@#")
    
    return 0

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
