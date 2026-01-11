#!/usr/bin/env python3
"""
ZUBID Production Database Seeding Script
Clears and populates the production database on Render with realistic sample data
"""

import os
import sys
import random
import requests
from datetime import datetime, timedelta, timezone, date
from werkzeug.security import generate_password_hash

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def seed_via_api(base_url):
    """Seed the production database via API calls"""
    print(f"🌐 Seeding production database via API: {base_url}")
    
    # First, initialize the database
    print("🔧 Initializing database...")
    try:
        response = requests.post(f"{base_url}/api/admin/init-db", timeout=30)
        if response.status_code == 200:
            print("✅ Database initialized successfully")
        else:
            print(f"⚠️ Database init response: {response.status_code}")
    except Exception as e:
        print(f"⚠️ Database init warning: {e}")
    
    # Clear existing data (if endpoint exists)
    print("🗑️ Clearing existing data...")
    try:
        response = requests.post(f"{base_url}/api/admin/clear-data", timeout=30)
        if response.status_code == 200:
            print("✅ Data cleared successfully")
        else:
            print(f"⚠️ Clear data response: {response.status_code}")
    except Exception as e:
        print(f"⚠️ Clear data warning: {e}")
    
    # Create categories
    print("📂 Creating categories...")
    categories_data = [
        {
            'name': 'Electronics',
            'description': 'Smartphones, laptops, gaming consoles, and electronic devices'
        },
        {
            'name': 'Vehicles',
            'description': 'Cars, motorcycles, boats, and automotive parts'
        },
        {
            'name': 'Jewelry & Watches',
            'description': 'Fine jewelry, luxury watches, and precious stones'
        },
        {
            'name': 'Art & Collectibles',
            'description': 'Paintings, sculptures, antiques, and collectible items'
        },
        {
            'name': 'Fashion & Accessories',
            'description': 'Designer clothing, shoes, bags, and fashion accessories'
        },
        {
            'name': 'Home & Garden',
            'description': 'Furniture, appliances, garden tools, and home decor'
        },
        {
            'name': 'Sports & Recreation',
            'description': 'Sports equipment, outdoor gear, and recreational items'
        },
        {
            'name': 'Books & Media',
            'description': 'Books, movies, music, and educational materials'
        }
    ]
    
    created_categories = []
    for cat_data in categories_data:
        try:
            response = requests.post(f"{base_url}/api/admin/categories", 
                                   json=cat_data, timeout=15)
            if response.status_code in [200, 201]:
                created_categories.append(response.json())
                print(f"✅ Created category: {cat_data['name']}")
            else:
                print(f"⚠️ Category creation failed: {cat_data['name']} - {response.status_code}")
        except Exception as e:
            print(f"❌ Error creating category {cat_data['name']}: {e}")
    
    print(f"✅ Created {len(created_categories)} categories")
    
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
    
    created_users = []
    for user_data in users_data:
        try:
            response = requests.post(f"{base_url}/api/auth/register", 
                                   json=user_data, timeout=15)
            if response.status_code in [200, 201]:
                created_users.append(user_data)
                print(f"✅ Created user: {user_data['username']}")
            else:
                print(f"⚠️ User creation failed: {user_data['username']} - {response.status_code}")
        except Exception as e:
            print(f"❌ Error creating user {user_data['username']}: {e}")
    
    print(f"✅ Created {len(created_users)} users")

    # Create sample auctions with realistic data
    print("🏷️ Creating sample auctions...")

    # Sample auction data
    auctions_data = [
        {
            'item_name': 'iPhone 15 Pro Max 256GB',
            'description': 'Brand new iPhone 15 Pro Max in Natural Titanium. Unlocked, with original box and accessories. Perfect condition.',
            'starting_price': 1200.0,
            'current_price': 1350.0,
            'category_id': 1,  # Electronics
            'condition': 'New',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800',
            'end_time': (datetime.now(timezone.utc) + timedelta(days=3)).isoformat(),
            'is_featured': True
        },
        {
            'item_name': '2022 Toyota Camry Hybrid',
            'description': 'Excellent condition Toyota Camry Hybrid with low mileage. Full service history, single owner.',
            'starting_price': 25000.0,
            'current_price': 27500.0,
            'category_id': 2,  # Vehicles
            'condition': 'Used - Excellent',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800',
            'end_time': (datetime.now(timezone.utc) + timedelta(days=5)).isoformat(),
            'is_featured': True
        },
        {
            'item_name': 'Rolex Submariner Date',
            'description': 'Authentic Rolex Submariner Date in stainless steel. Excellent condition with box and papers.',
            'starting_price': 8000.0,
            'current_price': 9200.0,
            'category_id': 3,  # Jewelry & Watches
            'condition': 'Used - Very Good',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=800',
            'end_time': (datetime.now(timezone.utc) + timedelta(days=7)).isoformat(),
            'is_featured': True
        },
        {
            'item_name': 'MacBook Pro M3 14-inch',
            'description': 'Latest MacBook Pro with M3 chip, 16GB RAM, 512GB SSD. Space Gray, barely used.',
            'starting_price': 1800.0,
            'current_price': 1950.0,
            'category_id': 1,  # Electronics
            'condition': 'Used - Like New',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800',
            'end_time': (datetime.now(timezone.utc) + timedelta(days=2)).isoformat(),
            'is_featured': False
        },
        {
            'item_name': 'Louis Vuitton Neverfull MM',
            'description': 'Authentic Louis Vuitton Neverfull MM in Damier Ebene canvas. Excellent condition.',
            'starting_price': 800.0,
            'current_price': 920.0,
            'category_id': 5,  # Fashion & Accessories
            'condition': 'Used - Very Good',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800',
            'end_time': (datetime.now(timezone.utc) + timedelta(days=4)).isoformat(),
            'is_featured': False
        }
    ]

    created_auctions = 0
    for auction_data in auctions_data:
        try:
            # Create auction via API (if endpoint exists)
            response = requests.post(f"{base_url}/api/admin/auctions",
                                   json=auction_data, timeout=15)
            if response.status_code in [200, 201]:
                created_auctions += 1
                print(f"✅ Created auction: {auction_data['item_name']}")
            else:
                print(f"⚠️ Auction creation failed: {auction_data['item_name']} - {response.status_code}")
        except Exception as e:
            print(f"❌ Error creating auction {auction_data['item_name']}: {e}")

    print(f"✅ Created {created_auctions} auctions")

    return len(created_categories), len(created_users), created_auctions

def main():
    """Main function to seed the production database"""
    print("🌱 ZUBID Production Database Seeding Started")
    print("=" * 60)
    
    # Determine the production URL
    production_urls = [
        'https://zubid-2025.onrender.com',  # Render deployment
        'https://zubidauction.duckdns.org'  # DuckDNS deployment
    ]
    
    # Try to find which production server is available
    active_url = None
    for url in production_urls:
        try:
            print(f"🔍 Testing connection to {url}...")
            response = requests.get(f"{url}/api/health", timeout=10)
            if response.status_code == 200:
                active_url = url
                print(f"✅ Connected to {url}")
                break
        except Exception as e:
            print(f"❌ Failed to connect to {url}: {e}")
    
    if not active_url:
        print("❌ No production server is accessible!")
        print("Please ensure one of the following is running:")
        for url in production_urls:
            print(f"   • {url}")
        return 1
    
    try:
        # Seed the database
        categories_count, users_count, auctions_count = seed_via_api(active_url)

        print("\n" + "=" * 60)
        print("🎉 Production database seeding completed!")
        print(f"📊 Summary:")
        print(f"   • {categories_count} categories created")
        print(f"   • {users_count} users created")
        print(f"   • {auctions_count} auctions created")
        print(f"   • Production URL: {active_url}")
        print("\n🔐 Login Credentials:")
        print("   Admin: admin / Admin123!@#")
        print("   Users: any username / User123!@#")
        print(f"\n🌐 Access the application:")
        print(f"   Web: {active_url}")
        print(f"   API: {active_url}/api")
        print(f"   Admin: {active_url}/admin.html")
        
    except Exception as e:
        print(f"❌ Error during seeding: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
