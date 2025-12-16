#!/usr/bin/env python3
"""
Simple test server to verify connectivity
"""
from flask import Flask, jsonify
import sqlite3

app = Flask(__name__)

@app.route('/api/test')
def test():
    return jsonify({'status': 'ok', 'message': 'Server is running!'})

@app.route('/api/auctions')
def get_auctions():
    try:
        # Connect to database and get auctions
        conn = sqlite3.connect('backend/instance/auction.db')
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT id, item_name, starting_bid, current_bid, status, end_time 
            FROM auction 
            ORDER BY id DESC 
            LIMIT 10
        """)
        auctions_data = cursor.fetchall()
        
        # Get images for auctions
        cursor.execute("""
            SELECT auction_id, url, is_primary 
            FROM image 
            WHERE is_primary = 1
        """)
        images_data = cursor.fetchall()
        images_dict = {img[0]: img[1] for img in images_data}
        
        conn.close()
        
        auctions = []
        for auction in auctions_data:
            auction_id = auction[0]
            auctions.append({
                'id': str(auction_id),
                'title': auction[1],
                'description': f"Auction for {auction[1]}",
                'imageUrl': images_dict.get(auction_id, None),
                'currentPrice': auction[3] or auction[2],
                'startingPrice': auction[2],
                'endTime': 1735689600000,  # Fixed timestamp for testing
                'categoryId': '1',
                'sellerId': '1',
                'bidCount': 0,
                'isWishlisted': False,
                'status': auction[4]
            })
        
        return jsonify({
            'auctions': auctions,
            'total': len(auctions),
            'page': 1,
            'per_page': 10,
            'pages': 1
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Starting simple test server on http://0.0.0.0:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)
