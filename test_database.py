#!/usr/bin/env python3
"""
Test script to check database content
"""
import sqlite3
import json
from datetime import datetime

def check_database():
    try:
        # Connect to the database
        conn = sqlite3.connect('backend/instance/auction.db')
        cursor = conn.cursor()
        
        print("=== DATABASE CONTENT CHECK ===\n")
        
        # Check users
        cursor.execute("SELECT COUNT(*) FROM user")
        user_count = cursor.fetchone()[0]
        print(f"👥 Users: {user_count}")
        
        if user_count > 0:
            cursor.execute("SELECT id, username, email FROM user LIMIT 5")
            users = cursor.fetchall()
            print("Sample users:")
            for user in users:
                print(f"  - ID: {user[0]}, Username: {user[1]}, Email: {user[2]}")
        
        print()
        
        # Check auctions
        cursor.execute("SELECT COUNT(*) FROM auction")
        auction_count = cursor.fetchone()[0]
        print(f"🏷️  Auctions: {auction_count}")
        
        if auction_count > 0:
            cursor.execute("""
                SELECT id, item_name, starting_bid, current_bid, status, end_time 
                FROM auction 
                ORDER BY id DESC 
                LIMIT 10
            """)
            auctions = cursor.fetchall()
            print("Recent auctions:")
            for auction in auctions:
                print(f"  - ID: {auction[0]}, Name: {auction[1]}, Start: ${auction[2]}, Current: ${auction[3]}, Status: {auction[4]}")
        
        print()
        
        # Check categories
        cursor.execute("SELECT COUNT(*) FROM category")
        category_count = cursor.fetchone()[0]
        print(f"📂 Categories: {category_count}")
        
        if category_count > 0:
            cursor.execute("SELECT id, name FROM category")
            categories = cursor.fetchall()
            print("Categories:")
            for category in categories:
                print(f"  - ID: {category[0]}, Name: {category[1]}")
        
        print()
        
        # Check bids
        cursor.execute("SELECT COUNT(*) FROM bid")
        bid_count = cursor.fetchone()[0]
        print(f"💰 Bids: {bid_count}")
        
        print()
        
        # Check auction images
        cursor.execute("SELECT COUNT(*) FROM image")
        image_count = cursor.fetchone()[0]
        print(f"🖼️  Auction Images: {image_count}")

        if image_count > 0:
            cursor.execute("SELECT auction_id, url, is_primary FROM image LIMIT 5")
            images = cursor.fetchall()
            print("Sample images:")
            for image in images:
                primary = " (PRIMARY)" if image[2] else ""
                print(f"  - Auction {image[0]}: {image[1][:50]}...{primary}")
        
        print("\n=== SUMMARY ===")
        if auction_count == 0:
            print("❌ NO AUCTIONS FOUND - This explains why Android app shows no data!")
        else:
            print(f"✅ Database has {auction_count} auctions")
            
        if user_count == 0:
            print("❌ NO USERS FOUND - This explains authentication issues!")
        else:
            print(f"✅ Database has {user_count} users")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ Error checking database: {e}")

if __name__ == "__main__":
    check_database()
