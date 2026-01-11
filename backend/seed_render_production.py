#!/usr/bin/env python3
"""
Seed Render Production Database via API
This script seeds the Render production database using API calls
"""

import os
import sys
import requests
import json
from datetime import datetime, timedelta, timezone

def seed_render_database():
    """Seed the Render production database via API"""
    base_url = 'https://zubid-2025.onrender.com'
    
    print(f"🌐 Seeding Render production database: {base_url}")
    
    # Test connection first
    try:
        print("🔍 Testing connection...")
        response = requests.get(f"{base_url}/api/health", timeout=30)
        if response.status_code != 200:
            print(f"❌ Server not responding: {response.status_code}")
            return False
        print("✅ Server is responding")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False
    
    # Initialize database
    try:
        print("🔧 Initializing database...")
        response = requests.post(f"{base_url}/api/admin/init-db", timeout=60)
        if response.status_code == 200:
            print("✅ Database initialized")
        else:
            print(f"⚠️ Database init response: {response.status_code}")
    except Exception as e:
        print(f"⚠️ Database init warning: {e}")
    
    # Create categories
    print("📂 Creating categories...")
    categories_data = [
        {'name': 'Electronics', 'description': 'Smartphones, laptops, gaming consoles, and electronic devices'},
        {'name': 'Vehicles', 'description': 'Cars, motorcycles, boats, and automotive parts'},
        {'name': 'Jewelry & Watches', 'description': 'Fine jewelry, luxury watches, and precious stones'},
        {'name': 'Art & Collectibles', 'description': 'Paintings, sculptures, antiques, and collectible items'},
        {'name': 'Fashion & Accessories', 'description': 'Designer clothing, shoes, bags, and fashion accessories'},
        {'name': 'Home & Garden', 'description': 'Furniture, appliances, garden tools, and home decor'},
        {'name': 'Sports & Recreation', 'description': 'Sports equipment, outdoor gear, and recreational items'},
        {'name': 'Books & Media', 'description': 'Books, movies, music, and educational materials'}
    ]
    
    categories_created = 0
    for cat_data in categories_data:
        try:
            response = requests.post(f"{base_url}/api/categories", 
                                   json=cat_data, timeout=30)
            if response.status_code in [200, 201]:
                categories_created += 1
                print(f"✅ Created category: {cat_data['name']}")
            else:
                print(f"⚠️ Category creation failed: {cat_data['name']} - {response.status_code}")
        except Exception as e:
            print(f"❌ Error creating category {cat_data['name']}: {e}")
    
    # Create users via registration
    print("👥 Creating users...")
    users_data = [
        {
            'username': 'ahmed_collector',
            'email': 'ahmed@example.com',
            'password': 'User123!@#',
            'phone': '+9647701234567',
            'id_number': 'IQ123456789',
            'birth_date': '1990-03-15',
            'address': 'Al-Mansour District, Baghdad, Iraq'
        },
        {
            'username': 'sara_antiques',
            'email': 'sara@example.com',
            'password': 'User123!@#',
            'phone': '+9647701234568',
            'id_number': 'IQ987654321',
            'birth_date': '1988-07-22',
            'address': 'Karrada District, Baghdad, Iraq'
        },
        {
            'username': 'omar_tech',
            'email': 'omar@example.com',
            'password': 'User123!@#',
            'phone': '+9647701234569',
            'id_number': 'IQ456789123',
            'birth_date': '1992-11-08',
            'address': 'Jadriya District, Baghdad, Iraq'
        },
        {
            'username': 'layla_fashion',
            'email': 'layla@example.com',
            'password': 'User123!@#',
            'phone': '+9647701234570',
            'id_number': 'IQ789123456',
            'birth_date': '1995-05-12',
            'address': 'Adhamiya District, Baghdad, Iraq'
        },
        {
            'username': 'hassan_cars',
            'email': 'hassan@example.com',
            'password': 'User123!@#',
            'phone': '+9647701234571',
            'id_number': 'IQ321654987',
            'birth_date': '1987-09-30',
            'address': 'Sadr City, Baghdad, Iraq'
        }
    ]
    
    users_created = 0
    for user_data in users_data:
        try:
            response = requests.post(f"{base_url}/api/auth/register", 
                                   json=user_data, timeout=30)
            if response.status_code in [200, 201]:
                users_created += 1
                print(f"✅ Created user: {user_data['username']}")
            else:
                print(f"⚠️ User creation failed: {user_data['username']} - {response.status_code}")
        except Exception as e:
            print(f"❌ Error creating user {user_data['username']}: {e}")
    
    print(f"\n📊 Summary:")
    print(f"   • {categories_created} categories created")
    print(f"   • {users_created} users created")
    
    return True

def main():
    """Main function"""
    print("🌱 ZUBID Render Production Database Seeding")
    print("=" * 50)
    
    try:
        success = seed_render_database()
        
        if success:
            print("\n" + "=" * 50)
            print("🎉 Render production database seeding completed!")
            print("🌐 Server: https://zubid-2025.onrender.com")
            print("🔐 Admin: admin / Admin123!@#")
            print("👥 Users: any username / User123!@#")
            print("\n🧪 Test the application:")
            print("   Web: https://zubid-2025.onrender.com")
            print("   API: https://zubid-2025.onrender.com/api")
            print("   Mobile: Configure app to use production server")
            return 0
        else:
            print("❌ Seeding failed")
            return 1
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
