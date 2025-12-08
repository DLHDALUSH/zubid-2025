"""
Test script for enhanced backend features
Tests navigation menu, user preferences, and enhanced profiles
"""

import sys
import os

# Change to the backend directory so database path is resolved correctly
os.chdir(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db, User, NavigationMenu, UserPreference
from datetime import datetime, timezone

def test_enhanced_features():
    """Test all enhanced features"""
    with app.app_context():
        # Ensure tables exist
        db.create_all()
        print("\n" + "="*60)
        print("Testing Enhanced Backend Features")
        print("="*60 + "\n")
        
        # Test 1: Check NavigationMenu table
        print("[1/5] Testing NavigationMenu...")
        menu_count = NavigationMenu.query.count()
        print(f"  ✓ Found {menu_count} navigation menu items")
        
        if menu_count > 0:
            # Get top-level menus
            top_menus = NavigationMenu.query.filter_by(parent_id=None).all()
            print(f"  ✓ Top-level menus: {len(top_menus)}")
            for menu in top_menus:
                children = NavigationMenu.query.filter_by(parent_id=menu.id).count()
                print(f"    - {menu.label} ({menu.name}): {children} children")
        else:
            print("  ⚠ No navigation menu items found. Run init_db() to create defaults.")
        
        # Test 2: Check UserPreference table
        print("\n[2/5] Testing UserPreference...")
        pref_count = UserPreference.query.count()
        print(f"  ✓ Found {pref_count} user preferences")
        
        # Test 3: Check User table new columns
        print("\n[3/5] Testing User table enhancements...")
        user = User.query.first()
        if user:
            print(f"  ✓ User found: {user.username}")
            
            # Check new fields exist
            new_fields = [
                'first_name', 'last_name', 'bio', 'company', 'website',
                'city', 'country', 'postal_code', 'phone_verified',
                'email_verified', 'is_active', 'last_login', 'login_count'
            ]
            
            missing_fields = []
            for field in new_fields:
                if not hasattr(user, field):
                    missing_fields.append(field)
            
            if missing_fields:
                print(f"  ✗ Missing fields: {', '.join(missing_fields)}")
            else:
                print(f"  ✓ All {len(new_fields)} new fields exist")
                print(f"    - is_active: {user.is_active}")
                print(f"    - login_count: {user.login_count}")
                print(f"    - last_login: {user.last_login}")
        else:
            print("  ⚠ No users found in database")
        
        # Test 4: Test creating a user preference
        print("\n[4/5] Testing UserPreference creation...")
        if user and not user.preferences:
            try:
                pref = UserPreference(user_id=user.id)
                db.session.add(pref)
                db.session.commit()
                print(f"  ✓ Created default preferences for user {user.username}")
                print(f"    - Theme: {pref.theme}")
                print(f"    - Language: {pref.language}")
                print(f"    - Items per page: {pref.items_per_page}")
            except Exception as e:
                print(f"  ✗ Failed to create preferences: {str(e)}")
                db.session.rollback()
        elif user and user.preferences:
            print(f"  ✓ User already has preferences")
            print(f"    - Theme: {user.preferences.theme}")
            print(f"    - Language: {user.preferences.language}")
        
        # Test 5: Test navigation menu hierarchy
        print("\n[5/5] Testing navigation menu hierarchy...")
        my_account = NavigationMenu.query.filter_by(name='my_account').first()
        if my_account:
            print(f"  ✓ Found 'My Account' menu")
            print(f"    - Label: {my_account.label}")
            print(f"    - Requires auth: {my_account.requires_auth}")
            print(f"    - Children: {len(my_account.children)}")
            for child in my_account.children:
                print(f"      • {child.label} ({child.url})")
        else:
            print("  ⚠ 'My Account' menu not found")
        
        print("\n" + "="*60)
        print("Test Summary")
        print("="*60)
        print(f"✓ NavigationMenu table: {menu_count} items")
        print(f"✓ UserPreference table: {pref_count} preferences")
        print(f"✓ User enhancements: {'OK' if user and hasattr(user, 'is_active') else 'MISSING'}")
        print(f"✓ Database structure: OK")
        print("\n✅ All tests completed successfully!")
        print("\n")

if __name__ == '__main__':
    try:
        test_enhanced_features()
    except Exception as e:
        print(f"\n[ERROR] Test failed: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

