#!/usr/bin/env python3
"""
ZUBID Database Seeding Script
Clears existing data and populates the database with realistic sample data
"""

import os
import sys
import random
from datetime import datetime, timedelta, timezone, date
from werkzeug.security import generate_password_hash

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db, User, Auction, Bid, Category, Image, Invoice

def clear_database():
    """Clear all existing data from the database"""
    print("🗑️  Clearing existing database data...")
    
    with app.app_context():
        # Drop all tables and recreate them
        db.drop_all()
        db.create_all()
        print("✅ Database cleared and tables recreated")

def create_categories():
    """Create realistic auction categories"""
    print("📂 Creating categories...")
    
    categories = [
        {
            'name': 'Electronics',
            'description': 'Smartphones, laptops, gaming consoles, and electronic devices',
            'icon': 'electronics'
        },
        {
            'name': 'Vehicles',
            'description': 'Cars, motorcycles, boats, and automotive parts',
            'icon': 'directions_car'
        },
        {
            'name': 'Jewelry & Watches',
            'description': 'Fine jewelry, luxury watches, and precious stones',
            'icon': 'watch'
        },
        {
            'name': 'Art & Collectibles',
            'description': 'Paintings, sculptures, antiques, and collectible items',
            'icon': 'palette'
        },
        {
            'name': 'Fashion & Accessories',
            'description': 'Designer clothing, shoes, bags, and fashion accessories',
            'icon': 'checkroom'
        },
        {
            'name': 'Home & Garden',
            'description': 'Furniture, appliances, garden tools, and home decor',
            'icon': 'home'
        },
        {
            'name': 'Sports & Recreation',
            'description': 'Sports equipment, outdoor gear, and recreational items',
            'icon': 'sports_soccer'
        },
        {
            'name': 'Books & Media',
            'description': 'Books, movies, music, and educational materials',
            'icon': 'library_books'
        }
    ]
    
    created_categories = []
    for cat_data in categories:
        category = Category(
            name=cat_data['name'],
            description=cat_data['description'],
            icon_url=cat_data['icon']  # Using icon_url field
        )
        db.session.add(category)
        created_categories.append(category)
    
    db.session.commit()
    print(f"✅ Created {len(created_categories)} categories")
    return created_categories

def create_users():
    """Create realistic users including admin and regular users"""
    print("👥 Creating users...")
    
    # Create admin user
    admin = User(
        username='admin',
        email='admin@zubid.com',
        password_hash=generate_password_hash('Admin123!@#'),
        role='admin',
        id_number='ADMIN001',
        birth_date=date(1985, 1, 1),
        phone='+1234567890',
        address='ZUBID Headquarters, Baghdad, Iraq',
        email_verified=True,
        phone_verified=True,
        is_active=True,
        balance=10000.0,
        created_at=datetime.now(timezone.utc)
    )
    db.session.add(admin)
    
    # Create regular users with realistic data
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
            'balance': 4800.0
        },
        {
            'username': 'hassan_cars',
            'email': 'hassan@example.com',
            'phone': '+9647701234571',
            'id_number': 'IQ321654987',
            'birth_date': date(1987, 9, 30),
            'address': 'Sadr City, Baghdad, Iraq',
            'balance': 15000.0
        }
    ]
    
    created_users = [admin]
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
            created_at=datetime.now(timezone.utc) - timedelta(days=random.randint(1, 365))
        )
        db.session.add(user)
        created_users.append(user)
    
    db.session.commit()
    print(f"✅ Created {len(created_users)} users (including admin)")
    return created_users

def create_auctions(users, categories):
    """Create realistic auctions with proper data"""
    print("🏷️  Creating auctions...")

    # High-quality auction data with realistic Iraqi context
    auctions_data = [
        {
            'item_name': 'iPhone 15 Pro Max 256GB - Natural Titanium',
            'description': 'Brand new iPhone 15 Pro Max with 256GB storage in Natural Titanium. Includes original box, charger, and documentation. Never used, still sealed. Perfect for photography and gaming.',
            'starting_bid': 1200.0,
            'current_bid': 1350.0,
            'bid_increment': 50.0,
            'market_price': 1500.0,
            'real_price': 1450.0,
            'item_condition': 'new',
            'category': 'Electronics',
            'featured': True,
            'days_remaining': 3,
            'image_url': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800&q=80'
        },
        {
            'item_name': '2022 Toyota Camry Hybrid - Low Mileage',
            'description': 'Excellent condition 2022 Toyota Camry Hybrid with only 15,000 km. Full service history, single owner. Features include leather seats, navigation system, and advanced safety features.',
            'starting_bid': 25000.0,
            'current_bid': 27500.0,
            'bid_increment': 500.0,
            'market_price': 32000.0,
            'real_price': 30000.0,
            'item_condition': 'used',
            'category': 'Vehicles',
            'featured': True,
            'days_remaining': 5,
            'image_url': 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&q=80'
        },
        {
            'item_name': 'Rolex Submariner Date - Stainless Steel',
            'description': 'Authentic Rolex Submariner Date in stainless steel. Purchased from authorized dealer in 2020. Includes original box, papers, and warranty card. Excellent condition.',
            'starting_bid': 8000.0,
            'current_bid': 9200.0,
            'bid_increment': 200.0,
            'market_price': 12000.0,
            'real_price': 11500.0,
            'item_condition': 'used',
            'category': 'Jewelry & Watches',
            'featured': True,
            'days_remaining': 7,
            'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'
        },
        {
            'item_name': 'Original Oil Painting - Baghdad Sunset',
            'description': 'Beautiful original oil painting depicting a sunset over Baghdad. Created by renowned Iraqi artist. Framed and ready to hang. Perfect for collectors of Middle Eastern art.',
            'starting_bid': 500.0,
            'current_bid': 650.0,
            'bid_increment': 25.0,
            'market_price': 1200.0,
            'real_price': 1000.0,
            'item_condition': 'used',
            'category': 'Art & Collectibles',
            'featured': False,
            'days_remaining': 4,
            'image_url': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80'
        },
        {
            'item_name': 'MacBook Pro M3 14-inch - Space Gray',
            'description': 'Latest MacBook Pro with M3 chip, 14-inch display, 16GB RAM, 512GB SSD. Perfect for professionals and creatives. Includes original charger and packaging.',
            'starting_bid': 1800.0,
            'current_bid': 1950.0,
            'bid_increment': 50.0,
            'market_price': 2400.0,
            'real_price': 2200.0,
            'item_condition': 'new',
            'category': 'Electronics',
            'featured': True,
            'days_remaining': 2,
            'image_url': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&q=80'
        },
        {
            'item_name': 'Louis Vuitton Neverfull MM - Monogram',
            'description': 'Authentic Louis Vuitton Neverfull MM in classic monogram canvas. Purchased from LV boutique. Includes dust bag and authenticity card. Excellent condition.',
            'starting_bid': 800.0,
            'current_bid': 920.0,
            'bid_increment': 30.0,
            'market_price': 1400.0,
            'real_price': 1200.0,
            'item_condition': 'used',
            'category': 'Fashion & Accessories',
            'featured': False,
            'days_remaining': 6,
            'image_url': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800&q=80'
        },
        {
            'item_name': 'Antique Persian Carpet - Hand Woven',
            'description': 'Beautiful hand-woven Persian carpet, approximately 100 years old. Excellent condition with vibrant colors. Perfect for traditional or modern homes. Size: 3x2 meters.',
            'starting_bid': 1500.0,
            'current_bid': 1750.0,
            'bid_increment': 100.0,
            'market_price': 3000.0,
            'real_price': 2500.0,
            'item_condition': 'used',
            'category': 'Home & Garden',
            'featured': True,
            'days_remaining': 8,
            'image_url': 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800&q=80'
        },
        {
            'item_name': 'PlayStation 5 Console + Extra Controller',
            'description': 'Sony PlayStation 5 console in excellent condition. Includes extra DualSense controller, original box, and cables. Perfect for gaming enthusiasts.',
            'starting_bid': 400.0,
            'current_bid': 480.0,
            'bid_increment': 20.0,
            'market_price': 600.0,
            'real_price': 550.0,
            'item_condition': 'used',
            'category': 'Electronics',
            'featured': False,
            'days_remaining': 1,
            'image_url': 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=800&q=80'
        },
        {
            'item_name': 'Canon EOS R5 Camera Body',
            'description': 'Professional Canon EOS R5 mirrorless camera body. Low shutter count, excellent condition. Perfect for professional photography and videography.',
            'starting_bid': 2500.0,
            'current_bid': 2750.0,
            'bid_increment': 100.0,
            'market_price': 3800.0,
            'real_price': 3500.0,
            'item_condition': 'used',
            'category': 'Electronics',
            'featured': True,
            'days_remaining': 4,
            'image_url': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&q=80'
        },
        {
            'item_name': 'Vintage Fender Stratocaster Guitar',
            'description': '1970s Fender Stratocaster electric guitar in sunburst finish. All original hardware and electronics. Excellent playing condition with beautiful tone.',
            'starting_bid': 3000.0,
            'current_bid': 3400.0,
            'bid_increment': 150.0,
            'market_price': 5000.0,
            'real_price': 4500.0,
            'item_condition': 'used',
            'category': 'Art & Collectibles',
            'featured': False,
            'days_remaining': 9,
            'image_url': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80'
        }
    ]

    created_auctions = []
    category_map = {cat.name: cat for cat in categories}

    for i, auction_data in enumerate(auctions_data):
        # Assign seller (rotate through users, skip admin for variety)
        seller = users[1 + (i % (len(users) - 1))]
        category = category_map[auction_data['category']]

        end_time = datetime.now(timezone.utc) + timedelta(days=auction_data['days_remaining'])

        auction = Auction(
            item_name=auction_data['item_name'],
            description=auction_data['description'],
            starting_bid=auction_data['starting_bid'],
            current_bid=auction_data['current_bid'],
            bid_increment=auction_data['bid_increment'],
            market_price=auction_data['market_price'],
            real_price=auction_data['real_price'],
            item_condition=auction_data['item_condition'],
            end_time=end_time,
            seller_id=seller.id,
            category_id=category.id,
            status='active',
            featured=auction_data['featured'],
            start_time=datetime.now(timezone.utc) - timedelta(hours=random.randint(1, 48))
        )

        db.session.add(auction)
        db.session.flush()  # Get the auction ID

        # Add primary image
        image = Image(
            auction_id=auction.id,
            url=auction_data['image_url'],
            is_primary=True
        )
        db.session.add(image)

        created_auctions.append(auction)

    db.session.commit()
    print(f"✅ Created {len(created_auctions)} auctions")
    return created_auctions

def create_bids(users, auctions):
    """Create realistic bids for auctions"""
    print("💰 Creating bids...")

    created_bids = []

    for auction in auctions:
        # Skip some auctions to have variety
        if random.random() < 0.3:
            continue

        # Determine number of bids (more popular items have more bids)
        if auction.featured:
            num_bids = random.randint(3, 8)
        else:
            num_bids = random.randint(1, 5)

        current_price = auction.starting_bid
        bid_times = []

        # Generate bid timestamps
        auction_duration = auction.end_time - auction.start_time
        for _ in range(num_bids):
            # Bids are more frequent near the end
            if random.random() < 0.4:  # 40% chance of recent bid
                bid_time = auction.end_time - timedelta(hours=random.randint(1, 24))
            else:
                bid_time = auction.start_time + timedelta(
                    seconds=random.randint(0, int(auction_duration.total_seconds()))
                )
            bid_times.append(bid_time)

        bid_times.sort()

        # Create bids
        used_bidders = set()
        for i, bid_time in enumerate(bid_times):
            # Select a bidder (not the seller)
            available_bidders = [u for u in users if u.id != auction.seller_id and u.id not in used_bidders]
            if not available_bidders:
                available_bidders = [u for u in users if u.id != auction.seller_id]
                used_bidders.clear()

            bidder = random.choice(available_bidders)
            used_bidders.add(bidder.id)

            # Calculate bid amount
            if i == 0:
                bid_amount = auction.starting_bid
            else:
                increment = auction.bid_increment + random.uniform(0, auction.bid_increment)
                bid_amount = current_price + increment

            current_price = bid_amount

            bid = Bid(
                auction_id=auction.id,
                user_id=bidder.id,
                amount=bid_amount,
                timestamp=bid_time,
                is_auto_bid=random.random() < 0.2  # 20% chance of auto bid
            )

            db.session.add(bid)
            created_bids.append(bid)

        # Update auction current bid
        auction.current_bid = current_price

    db.session.commit()
    print(f"✅ Created {len(created_bids)} bids")
    return created_bids

def create_sample_invoices(users, auctions):
    """Create some sample invoices for completed transactions"""
    print("🧾 Creating sample invoices...")

    # Create a few completed auctions with invoices
    completed_auctions = random.sample(auctions, min(3, len(auctions)))
    created_invoices = []

    for auction in completed_auctions:
        # Mark auction as ended
        auction.status = 'ended'
        auction.end_time = datetime.now(timezone.utc) - timedelta(days=random.randint(1, 30))

        # Find the highest bidder
        highest_bid = max([bid for bid in auction.bids], key=lambda b: b.amount, default=None)
        if highest_bid:
            auction.winner_id = highest_bid.user_id

            # Create invoice
            item_price = highest_bid.amount
            bid_fee = item_price * 0.01  # 1% bid fee
            delivery_fee = random.choice([0, 25, 50, 75])  # Random delivery fee
            total_amount = item_price + bid_fee + delivery_fee

            invoice = Invoice(
                auction_id=auction.id,
                user_id=highest_bid.user_id,
                item_price=item_price,
                bid_fee=bid_fee,
                delivery_fee=delivery_fee,
                total_amount=total_amount,
                payment_method=random.choice(['cash_on_delivery', 'fib']),
                payment_status=random.choice(['paid', 'pending']),
                created_at=auction.end_time + timedelta(hours=1)
            )

            db.session.add(invoice)
            created_invoices.append(invoice)

    db.session.commit()
    print(f"✅ Created {len(created_invoices)} sample invoices")
    return created_invoices

def main():
    """Main function to seed the database"""
    print("🌱 ZUBID Database Seeding Started")
    print("=" * 50)

    with app.app_context():
        try:
            # Clear existing data
            clear_database()

            # Create data in order
            categories = create_categories()
            users = create_users()
            auctions = create_auctions(users, categories)
            bids = create_bids(users, auctions)
            invoices = create_sample_invoices(users, auctions)

            print("\n" + "=" * 50)
            print("🎉 Database seeding completed successfully!")
            print(f"📊 Summary:")
            print(f"   • {len(categories)} categories")
            print(f"   • {len(users)} users (including admin)")
            print(f"   • {len(auctions)} auctions")
            print(f"   • {len(bids)} bids")
            print(f"   • {len(invoices)} invoices")
            print("\n🔐 Admin Login:")
            print("   Username: admin")
            print("   Password: Admin123!@#")
            print("\n🔐 User Login (any user):")
            print("   Password: User123!@#")
            print("\n🌐 Access the application:")
            print("   Web: http://localhost:5000")
            print("   API: http://localhost:5000/api")

        except Exception as e:
            print(f"❌ Error during seeding: {e}")
            import traceback
            traceback.print_exc()
            return 1

    return 0

if __name__ == '__main__':
    exit_code = main()
    sys.exit(exit_code)
