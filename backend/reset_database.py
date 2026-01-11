#!/usr/bin/env python3
"""
Quick script to reset and seed the ZUBID database
"""

import os
import sys
import subprocess

def main():
    print("🔄 ZUBID Database Reset & Seed")
    print("=" * 40)
    
    # Confirm action
    response = input("⚠️  This will DELETE ALL existing data. Continue? (y/N): ")
    if response.lower() not in ['y', 'yes']:
        print("❌ Operation cancelled")
        return 1
    
    # Change to backend directory
    backend_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(backend_dir)
    
    print(f"📁 Working directory: {backend_dir}")
    
    # Run the seeding script
    try:
        print("🌱 Running database seeding...")
        result = subprocess.run([sys.executable, 'seed_database.py'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Database reset and seeded successfully!")
            print("\n" + result.stdout)
        else:
            print("❌ Seeding failed!")
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
            return 1
            
    except Exception as e:
        print(f"❌ Error running seeding script: {e}")
        return 1
    
    return 0

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
