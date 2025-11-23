"""
Initialize default navigation menu items
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db, NavigationMenu

def init_navigation_menu():
    """Create default navigation menu items"""
    with app.app_context():
        print("\n" + "="*60)
        print("Initializing Navigation Menu")
        print("="*60 + "\n")
        
        # Check if menu items already exist
        existing_count = NavigationMenu.query.count()
        if existing_count > 0:
            print(f"✓ Navigation menu already initialized ({existing_count} items)")
            return
        
        print("Creating default navigation menu...")
        
        # Home
        home_menu = NavigationMenu(
            name='home',
            label='Home',
            url='index.html',
            icon='home',
            order=1,
            is_active=True,
            requires_auth=False
        )
        db.session.add(home_menu)
        
        # My Account (parent dropdown - requires auth)
        my_account_menu = NavigationMenu(
            name='my_account',
            label='My Account',
            url=None,
            icon='user',
            order=2,
            is_active=True,
            requires_auth=True
        )
        db.session.add(my_account_menu)
        db.session.flush()
        
        # My Account children
        profile_menu = NavigationMenu(
            name='profile',
            label='Profile',
            url='profile.html',
            parent_id=my_account_menu.id,
            order=1,
            is_active=True,
            requires_auth=True
        )
        db.session.add(profile_menu)
        
        my_bids_menu = NavigationMenu(
            name='my_bids',
            label='My Bids',
            url='my-bids.html',
            parent_id=my_account_menu.id,
            order=2,
            is_active=True,
            requires_auth=True
        )
        db.session.add(my_bids_menu)
        
        payments_menu = NavigationMenu(
            name='payments',
            label='Payments',
            url='payments.html',
            parent_id=my_account_menu.id,
            order=3,
            is_active=True,
            requires_auth=True
        )
        db.session.add(payments_menu)
        
        return_requests_menu = NavigationMenu(
            name='return_requests',
            label='Return Requests',
            url='return-requests.html',
            parent_id=my_account_menu.id,
            order=4,
            is_active=True,
            requires_auth=True
        )
        db.session.add(return_requests_menu)
        
        # Info (parent dropdown)
        info_menu = NavigationMenu(
            name='info',
            label='Info',
            url=None,
            icon='info',
            order=3,
            is_active=True,
            requires_auth=False
        )
        db.session.add(info_menu)
        db.session.flush()
        
        # Info children
        how_to_bid_menu = NavigationMenu(
            name='how_to_bid',
            label='How to Bid',
            url='how-to-bid.html',
            parent_id=info_menu.id,
            order=1,
            is_active=True,
            requires_auth=False
        )
        db.session.add(how_to_bid_menu)
        
        contact_menu = NavigationMenu(
            name='contact',
            label='Contact Us',
            url='contact-us.html',
            parent_id=info_menu.id,
            order=2,
            is_active=True,
            requires_auth=False
        )
        db.session.add(contact_menu)
        
        db.session.commit()
        
        print("✓ Created default navigation menu!")
        print(f"  - Home")
        print(f"  - My Account (4 children)")
        print(f"  - Info (2 children)")
        print("\n" + "="*60)
        print("Navigation menu initialized successfully!")
        print("="*60 + "\n")

if __name__ == '__main__':
    try:
        init_navigation_menu()
    except Exception as e:
        print(f"\n[ERROR] Failed to initialize navigation menu: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

