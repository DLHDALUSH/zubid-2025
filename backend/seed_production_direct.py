#!/usr/bin/env python3
"""
ZUBID Production Database Direct Seeding Script
Directly seeds the production database with realistic sample data
"""

import os
import sys
from datetime import datetime, timedelta, timezone, date
from werkzeug.security import generate_password_hash

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import Flask app and models
from app import app, db, User, Category, Auction, Bid

def clear_existing_data():
    """Clear existing data from the database"""
    print("🗑️ Clearing existing database data...")
    
    with app.app_context():
        try:
            # Clear data in correct order (respecting foreign key constraints)
            db.session.execute(db.text('DELETE FROM bid'))
            db.session.execute(db.text('DELETE FROM invoice'))
            db.session.execute(db.text('DELETE FROM image'))
            db.session.execute(db.text('DELETE FROM auction'))
            db.session.execute(db.text('DELETE FROM user WHERE role != \'admin\''))  # Keep admin
            db.session.execute(db.text('DELETE FROM category'))
            
            db.session.commit()
            print("✅ Database cleared successfully")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Error clearing database: {e}")
            raise

def create_categories():
    """Create sample categories"""
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
    
    categories = []
    for cat_data in categories_data:
        category = Category(
            name=cat_data['name'],
            description=cat_data['description'],
            is_active=True,
            created_at=datetime.now(timezone.utc)
        )
        db.session.add(category)
        categories.append(category)
    
    db.session.commit()
    print(f"✅ Created {len(categories)} categories")
    return categories

def create_users():
    """Create sample users"""
    print("👥 Creating users...")
    
    users_data = [
        {
            'username': 'ahmed_collector',
            'email': 'ahmed@example.com',
            'phone': '+9647701234567',
            'id_number': 'IQ123456789',
            'birth_date': date(1990, 3, 15),
            'address': 'Al-Mansour District, Baghdad, Iraq',
            'balance': 5000.0
        },
        {
            'username': 'sara_antiques',
            'email': 'sara@example.com', 
            'phone': '+9647701234568',
            'id_number': 'IQ987654321',
            'birth_date': date(1988, 7, 22),
            'address': 'Karrada District, Baghdad, Iraq',
            'balance': 7500.0
        },
        {
            'username': 'omar_tech',
            'email': 'omar@example.com',
            'phone': '+9647701234569',
            'id_number': 'IQ456789123',
            'birth_date': date(1992, 11, 8),
            'address': 'Jadriya District, Baghdad, Iraq',
            'balance': 3200.0
        },
        {
            'username': 'layla_fashion',
            'email': 'layla@example.com',
            'phone': '+9647701234570',
            'id_number': 'IQ789123456',
            'birth_date': date(1995, 5, 12),
            'address': 'Adhamiya District, Baghdad, Iraq',
            'balance': 4100.0
        },
        {
            'username': 'hassan_cars',
            'email': 'hassan@example.com',
            'phone': '+9647701234571',
            'id_number': 'IQ321654987',
            'birth_date': date(1987, 9, 30),
            'address': 'Sadr City, Baghdad, Iraq',
            'balance': 8900.0
        }
    ]
    
    users = []
    for user_data in users_data:
        user = User(
            username=user_data['username'],
            email=user_data['email'],
            password_hash=generate_password_hash('User123!@#'),
            role='user',
            id_number=user_data['id_number'],
            birth_date=user_data['birth_date'],
            phone=user_data['phone'],
            address=user_data['address'],
            email_verified=True,
            phone_verified=True,
            is_active=True,
            balance=user_data['balance'],
            created_at=datetime.now(timezone.utc)
        )
        db.session.add(user)
        users.append(user)
    
    db.session.commit()
    print(f"✅ Created {len(users)} users")
    return users

def create_auctions(categories, users):
    """Create sample auctions"""
    print("🏷️ Creating auctions...")

    # Get admin user as seller
    admin_user = User.query.filter_by(role='admin').first()
    if not admin_user:
        print("❌ Admin user not found!")
        return []

    auctions_data = [
        {
            'item_name': 'iPhone 15 Pro Max 256GB',
            'description': 'Brand new iPhone 15 Pro Max in Natural Titanium. Unlocked, with original box and accessories. Perfect condition.',
            'starting_price': 1200.0,
            'current_price': 1350.0,
            'category_id': categories[0].id,  # Electronics
            'condition': 'New',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=3),
            'is_featured': True
        },
        {
            'item_name': '2022 Toyota Camry Hybrid',
            'description': 'Excellent condition Toyota Camry Hybrid with low mileage. Full service history, single owner.',
            'starting_price': 25000.0,
            'current_price': 27500.0,
            'category_id': categories[1].id,  # Vehicles
            'condition': 'Used - Excellent',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=5),
            'is_featured': True
        },
        {
            'item_name': 'Rolex Submariner Date',
            'description': 'Authentic Rolex Submariner Date in stainless steel. Excellent condition with box and papers.',
            'starting_price': 8000.0,
            'current_price': 9200.0,
            'category_id': categories[2].id,  # Jewelry & Watches
            'condition': 'Used - Very Good',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=7),
            'is_featured': True
        },
        {
            'item_name': 'MacBook Pro M3 14-inch',
            'description': 'Latest MacBook Pro with M3 chip, 16GB RAM, 512GB SSD. Space Gray, barely used.',
            'starting_price': 1800.0,
            'current_price': 1950.0,
            'category_id': categories[0].id,  # Electronics
            'condition': 'Used - Like New',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=2),
            'is_featured': False
        },
        {
            'item_name': 'Louis Vuitton Neverfull MM',
            'description': 'Authentic Louis Vuitton Neverfull MM in Damier Ebene canvas. Excellent condition.',
            'starting_price': 800.0,
            'current_price': 920.0,
            'category_id': categories[4].id,  # Fashion & Accessories
            'condition': 'Used - Very Good',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=4),
            'is_featured': False
        },
        {
            'item_name': 'Antique Persian Carpet',
            'description': 'Beautiful hand-woven Persian carpet from the 1960s. Excellent condition with rich colors and intricate patterns.',
            'starting_price': 1500.0,
            'current_price': 1750.0,
            'category_id': categories[3].id,  # Art & Collectibles
            'condition': 'Used - Very Good',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=6),
            'is_featured': True
        },
        {
            'item_name': 'PlayStation 5 Console',
            'description': 'Sony PlayStation 5 console with controller and original packaging. Barely used, excellent condition.',
            'starting_price': 450.0,
            'current_price': 480.0,
            'category_id': categories[0].id,  # Electronics
            'condition': 'Used - Like New',
            'location': 'Baghdad, Iraq',
            'featured_image_url': 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=800',
            'end_time': datetime.now(timezone.utc) + timedelta(days=1),
            'is_featured': False
        }
    ]

    auctions = []
    for auction_data in auctions_data:
        auction = Auction(
            item_name=auction_data['item_name'],
            description=auction_data['description'],
            starting_bid=auction_data['starting_price'],
            current_bid=auction_data['current_price'],
            category_id=auction_data['category_id'],
            seller_id=admin_user.id,
            item_condition=auction_data['condition'],
            featured_image_url=auction_data['featured_image_url'],
            end_time=auction_data['end_time'],
            featured=auction_data['is_featured'],
            status='active'
        )
        db.session.add(auction)
        auctions.append(auction)

    db.session.commit()
    print(f"✅ Created {len(auctions)} auctions")
    return auctions

def create_bids(auctions, users):
    """Create sample bids"""
    print("💰 Creating bids...")

    import random

    bids = []
    for auction in auctions[:5]:  # Add bids to first 5 auctions
        num_bids = random.randint(2, 6)
        current_price = auction.starting_bid

        for i in range(num_bids):
            bidder = random.choice(users)
            bid_amount = current_price + random.uniform(50, 200)

            bid = Bid(
                auction_id=auction.id,
                user_id=bidder.id,
                amount=bid_amount,
                timestamp=datetime.now(timezone.utc) - timedelta(hours=random.randint(1, 48))
            )
            db.session.add(bid)
            bids.append(bid)
            current_price = bid_amount

        # Update auction current bid
        auction.current_bid = current_price

    db.session.commit()
    print(f"✅ Created {len(bids)} bids")
    return bids

def main():
    """Main function to seed the production database"""
    print("🌱 ZUBID Production Database Direct Seeding Started")
    print("=" * 60)

    try:
        with app.app_context():
            # Clear existing data
            clear_existing_data()

            # Create sample data
            categories = create_categories()
            users = create_users()
            auctions = create_auctions(categories, users)
            bids = create_bids(auctions, users)

            print("\n" + "=" * 60)
            print("🎉 Production database seeding completed!")
            print(f"📊 Summary:")
            print(f"   • {len(categories)} categories created")
            print(f"   • {len(users)} users created")
            print(f"   • {len(auctions)} auctions created")
            print(f"   • {len(bids)} bids created")
            print("\n🔐 Login Credentials:")
            print("   Admin: admin / Admin123!@#")
            print("   Users: any username / User123!@#")
            print("\n🌐 Production URLs:")
            print("   Render: https://zubid-2025.onrender.com")
            print("   DuckDNS: https://zubidauction.duckdns.org")

    except Exception as e:
        print(f"❌ Error during seeding: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
