#!/usr/bin/env python3
"""
Test script to verify the API is working with the new seeded data
"""

import requests
import json
import sys

def test_api_endpoint(url, description):
    """Test an API endpoint and display results"""
    print(f"\n🔍 Testing: {description}")
    print(f"📡 URL: {url}")
    
    try:
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success! Status: {response.status_code}")
            
            if isinstance(data, dict):
                if 'data' in data:
                    print(f"📊 Records: {len(data['data']) if isinstance(data['data'], list) else 'N/A'}")
                elif 'auctions' in data:
                    print(f"📊 Auctions: {len(data['auctions'])}")
                elif 'categories' in data:
                    print(f"📊 Categories: {len(data['categories'])}")
                else:
                    print(f"📊 Response keys: {list(data.keys())}")
            elif isinstance(data, list):
                print(f"📊 Records: {len(data)}")
            
            # Show first item if available
            if isinstance(data, dict) and 'data' in data and data['data']:
                first_item = data['data'][0]
                if isinstance(first_item, dict):
                    print(f"📝 Sample: {first_item.get('item_name', first_item.get('name', 'N/A'))}")
            elif isinstance(data, list) and data:
                first_item = data[0]
                if isinstance(first_item, dict):
                    print(f"📝 Sample: {first_item.get('item_name', first_item.get('name', 'N/A'))}")
                    
        else:
            print(f"❌ Failed! Status: {response.status_code}")
            print(f"📄 Response: {response.text[:200]}...")
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection failed! Make sure the backend server is running.")
    except requests.exceptions.Timeout:
        print("❌ Request timed out!")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    """Test various API endpoints"""
    base_url = "http://localhost:5000/api"
    
    print("🧪 ZUBID API Data Test")
    print("=" * 40)
    
    # Test endpoints
    endpoints = [
        (f"{base_url}/auctions", "Active Auctions"),
        (f"{base_url}/auctions/featured", "Featured Auctions"),
        (f"{base_url}/categories", "Categories"),
        (f"{base_url}/auctions/1", "Single Auction Details"),
        (f"{base_url}/auctions/1/bids", "Auction Bids"),
    ]
    
    for url, description in endpoints:
        test_api_endpoint(url, description)
    
    print("\n" + "=" * 40)
    print("🎯 Test completed!")
    print("\n💡 Tips:")
    print("   • Make sure backend server is running: python app.py")
    print("   • Web interface: http://localhost:5000")
    print("   • Admin login: admin / Admin123!@#")
    print("   • User login: any username / User123!@#")

if __name__ == '__main__':
    main()
