#!/usr/bin/env python3
"""
Test Category API to verify it returns all required fields
"""

import sys
import os

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app, db, Category
import json

def test_category_api():
    """Test the Category API endpoint"""
    print("=" * 60)
    print("Testing Category API")
    print("=" * 60)
    
    with app.app_context():
        try:
            # Test 1: Query categories directly from database
            print("\n[Test 1] Querying categories from database...")
            categories = Category.query.filter_by(is_active=True).order_by(Category.sort_order, Category.name).all()
            print(f"✓ Found {len(categories)} active categories")
            
            if categories:
                cat = categories[0]
                print(f"\n📋 Sample Category: {cat.name}")
                print(f"  - ID: {cat.id}")
                print(f"  - Description: {cat.description}")
                print(f"  - Parent ID: {cat.parent_id}")
                print(f"  - Icon URL: {cat.icon_url}")
                print(f"  - Image URL: {cat.image_url}")
                print(f"  - Is Active: {cat.is_active}")
                print(f"  - Sort Order: {cat.sort_order}")
                print(f"  - Created At: {cat.created_at}")
                print(f"  - Updated At: {cat.updated_at}")
                print(f"  - Auction Count: {cat.auction_count}")
            
            # Test 2: Test API endpoint
            print("\n[Test 2] Testing API endpoint...")
            with app.test_client() as client:
                response = client.get('/api/categories')
                print(f"✓ Status Code: {response.status_code}")
                
                if response.status_code == 200:
                    data = response.get_json()
                    print(f"✓ Returned {len(data)} categories")
                    
                    if data:
                        cat_data = data[0]
                        print(f"\n📋 Sample API Response:")
                        print(json.dumps(cat_data, indent=2))
                        
                        # Check required fields
                        required_fields = [
                            'id', 'name', 'description', 'parent_id', 'icon_url',
                            'image_url', 'auction_count', 'is_active', 'sort_order',
                            'created_at', 'updated_at', 'subcategories'
                        ]
                        
                        print(f"\n✅ Required Fields Check:")
                        all_present = True
                        for field in required_fields:
                            if field in cat_data:
                                print(f"  ✓ {field}: {cat_data[field]}")
                            else:
                                print(f"  ✗ {field} - MISSING!")
                                all_present = False
                        
                        if all_present:
                            print("\n✅ All required fields are present!")
                        else:
                            print("\n❌ Some required fields are missing!")
                        
                        return all_present
                else:
                    print(f"❌ API returned error: {response.status_code}")
                    print(f"   Response: {response.get_data(as_text=True)}")
                    return False
            
        except Exception as e:
            print(f"\n❌ Test failed: {str(e)}")
            import traceback
            traceback.print_exc()
            return False

if __name__ == '__main__':
    print("\n🧪 Testing Category API...\n")
    success = test_category_api()
    
    if success:
        print("\n✅ All tests passed! The Category API is working correctly.")
    else:
        print("\n❌ Tests failed! Please check the errors above.")

