#!/usr/bin/env python3
"""
Test API endpoints to verify they work
"""
import requests
import json

def test_api():
    base_urls = [
        'https://zubidauction.duckdns.org/api',  # External server
        'http://localhost:5000/api',
        'http://127.0.0.1:5000/api',
        'http://10.0.2.2:5000/api'  # Android emulator
    ]
    
    for base_url in base_urls:
        print(f"\n=== Testing {base_url} ===")
        
        try:
            # Test auctions endpoint
            response = requests.get(f"{base_url}/auctions", timeout=5)
            print(f"Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                auctions = data.get('auctions', [])
                print(f"✅ SUCCESS: Found {len(auctions)} auctions")
                
                if auctions:
                    auction = auctions[0]
                    print(f"Sample auction: {auction.get('title', 'No title')}")
                    print(f"Price: ${auction.get('currentPrice', 0)}")
                    print(f"Image: {auction.get('imageUrl', 'No image')[:50]}...")
                else:
                    print("❌ No auctions returned")
            else:
                print(f"❌ FAILED: {response.status_code} - {response.text[:100]}")
                
        except requests.exceptions.ConnectionError:
            print("❌ CONNECTION FAILED - Server not reachable")
        except requests.exceptions.Timeout:
            print("❌ TIMEOUT - Server too slow")
        except Exception as e:
            print(f"❌ ERROR: {e}")

if __name__ == "__main__":
    test_api()
