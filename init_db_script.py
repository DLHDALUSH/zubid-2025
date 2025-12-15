#!/usr/bin/env python3
"""
Database initialization script for ZUBID backend
"""
import sys
import os

# Add backend directory to path
sys.path.insert(0, '/opt/zubid/backend')
os.chdir('/opt/zubid/backend')

# Import Flask app and database
from app import app, db

def init_database():
    """Initialize the database with tables and default data"""
    with app.app_context():
        print("=" * 60)
        print("ZUBID Database Initialization")
        print("=" * 60)
        
        # Create all tables
        print("\n[1/3] Creating database tables...")
        try:
            db.create_all()
            print("✓ Database tables created successfully!")
        except Exception as e:
            print(f"✗ Error creating tables: {e}")
            return False
        
        # Create default categories
        print("\n[2/3] Creating default categories...")
        try:
            from app import Category
            if Category.query.count() == 0:
                categories = [
                    Category(name='Electronics', description='Electronic devices and gadgets'),
                    Category(name='Art & Collectibles', description='Artwork and collectible items'),
                    Category(name='Jewelry', description='Precious jewelry and watches'),
                    Category(name='Vehicles', description='Cars, motorcycles, and other vehicles'),
                    Category(name='Real Estate', description='Properties and land'),
                    Category(name='Fashion', description='Clothing and accessories'),
                    Category(name='Sports', description='Sports equipment and memorabilia'),
                    Category(name='Other', description='Other miscellaneous items')
                ]
                for cat in categories:
                    db.session.add(cat)
                db.session.commit()
                print(f"✓ Created {len(categories)} default categories!")
            else:
                print("✓ Categories already exist!")
        except Exception as e:
            print(f"✗ Error creating categories: {e}")
            db.session.rollback()
            return False
        
        # Create admin user
        print("\n[3/3] Creating admin user...")
        try:
            from app import User
            from werkzeug.security import generate_password_hash
            from datetime import datetime
            
            admin = User.query.filter_by(username='admin').first()
            if not admin:
                admin = User(
                    username='admin',
                    email='admin@zubid.com',
                    password_hash=generate_password_hash('Admin123!@#'),
                    role='admin',
                    id_number='ADMIN001',
                    birth_date=datetime(1990, 1, 1),
                    phone='+1234567890',
                    address='ZUBID HQ'
                )
                db.session.add(admin)
                db.session.commit()
                print("✓ Admin user created!")
                print("  Username: admin")
                print("  Password: Admin123!@#")
            else:
                print("✓ Admin user already exists!")
        except Exception as e:
            print(f"✗ Error creating admin user: {e}")
            db.session.rollback()
            return False
        
        print("\n" + "=" * 60)
        print("✓ Database initialization completed successfully!")
        print("=" * 60)
        return True

if __name__ == '__main__':
    success = init_database()
    sys.exit(0 if success else 1)

