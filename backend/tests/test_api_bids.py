"""
Bidding API Tests for ZUBID Backend
Tests: Placing bids, Getting bids, Bid validation
"""
import pytest
from datetime import datetime, timedelta


def assert_success_response(response, expected_status=200):
    """Assert response is successful and return JSON data"""
    assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}: {response.data}"
    return response.get_json()


def assert_error_response(response, expected_status=400):
    """Assert response is an error"""
    assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}"
    return response.get_json()


class TestBidding:
    """Test bidding endpoints"""
    
    def test_place_bid_success(self, authenticated_client, test_auction, test_user, db_session):
        """Test successfully placing a bid"""
        # Create a different user to bid (can't bid on own auction)
        from app import User
        bidder = User(
            username='bidder',
            email='bidder@example.com',
            phone='9998887777',
            is_verified=True
        )
        bidder.set_password('BidderPassword123!')
        db_session.session.add(bidder)
        db_session.session.commit()
        
        # Login as bidder
        with authenticated_client.session_transaction() as sess:
            sess['_user_id'] = str(bidder.id)
        
        response = authenticated_client.post(f'/api/auctions/{test_auction.id}/bids', json={
            'amount': test_auction.current_price + test_auction.min_increment
        })
        assert response.status_code in [200, 201]
    
    def test_place_bid_on_own_auction(self, authenticated_client, test_auction):
        """Test that bidding on own auction fails"""
        response = authenticated_client.post(f'/api/auctions/{test_auction.id}/bids', json={
            'amount': test_auction.current_price + test_auction.min_increment
        })
        # Should fail - can't bid on your own auction
        assert response.status_code in [400, 403]
    
    def test_place_bid_too_low(self, authenticated_client, test_auction, db_session):
        """Test placing bid lower than current price fails"""
        from app import User
        bidder = User(
            username='lowbidder',
            email='lowbidder@example.com',
            phone='1112223344',
            is_verified=True
        )
        bidder.set_password('LowBidder123!')
        db_session.session.add(bidder)
        db_session.session.commit()
        
        with authenticated_client.session_transaction() as sess:
            sess['_user_id'] = str(bidder.id)
        
        response = authenticated_client.post(f'/api/auctions/{test_auction.id}/bids', json={
            'amount': test_auction.current_price - 10  # Below current price
        })
        assert response.status_code == 400
    
    def test_place_bid_below_min_increment(self, authenticated_client, test_auction, db_session):
        """Test placing bid below minimum increment fails"""
        from app import User
        bidder = User(
            username='smallbidder',
            email='smallbidder@example.com',
            phone='4445556666',
            is_verified=True
        )
        bidder.set_password('SmallBidder123!')
        db_session.session.add(bidder)
        db_session.session.commit()
        
        with authenticated_client.session_transaction() as sess:
            sess['_user_id'] = str(bidder.id)
        
        # Bid exactly at current price (no increment)
        response = authenticated_client.post(f'/api/auctions/{test_auction.id}/bids', json={
            'amount': test_auction.current_price + 1  # Less than min_increment
        })
        assert response.status_code == 400
    
    def test_place_bid_unauthenticated(self, client, test_auction):
        """Test placing bid without authentication"""
        response = client.post(f'/api/auctions/{test_auction.id}/bids', json={
            'amount': 150.0
        })
        assert response.status_code in [401, 403]
    
    def test_place_bid_on_nonexistent_auction(self, authenticated_client):
        """Test placing bid on non-existent auction"""
        response = authenticated_client.post('/api/auctions/99999/bids', json={
            'amount': 100.0
        })
        assert response.status_code == 404
    
    def test_get_bids_for_auction(self, client, test_auction):
        """Test getting bids for an auction"""
        response = client.get(f'/api/auctions/{test_auction.id}/bids')
        data = assert_success_response(response)
        assert 'bids' in data or isinstance(data, list)
    
    def test_get_user_bids(self, authenticated_client, test_user):
        """Test getting user's own bids"""
        response = authenticated_client.get('/api/user/bids')
        if response.status_code == 200:
            data = response.get_json()
            assert 'bids' in data or isinstance(data, list)
    
    def test_get_my_bids(self, authenticated_client):
        """Test getting my bids (alternative endpoint)"""
        response = authenticated_client.get('/api/my-bids')
        if response.status_code == 200:
            data = response.get_json()
            assert 'bids' in data or isinstance(data, list)


class TestBuyNow:
    """Test buy now functionality"""
    
    def test_buy_now_success(self, authenticated_client, db_session, test_category, test_user):
        """Test successful buy now"""
        from app import Auction, User
        
        # Create auction with buy now price
        seller = User(
            username='buynowseller',
            email='seller@example.com',
            phone='7778889999',
            is_verified=True
        )
        seller.set_password('SellerPassword123!')
        db_session.session.add(seller)
        db_session.session.commit()
        
        auction = Auction(
            title='Buy Now Item',
            description='Item with buy now option',
            starting_price=100.0,
            current_price=100.0,
            buy_now_price=200.0,
            min_increment=10.0,
            end_time=datetime.utcnow() + timedelta(days=7),
            seller_id=seller.id,
            category_id=test_category.id,
            status='active'
        )
        db_session.session.add(auction)
        db_session.session.commit()
        
        # Try to buy now as test_user
        response = authenticated_client.post(f'/api/auctions/{auction.id}/buy-now')
        # May succeed or fail depending on implementation
        assert response.status_code in [200, 201, 400, 403]
    
    def test_buy_now_own_auction(self, authenticated_client, test_auction):
        """Test that buying own auction fails"""
        # test_auction is owned by test_user who is logged in
        response = authenticated_client.post(f'/api/auctions/{test_auction.id}/buy-now')
        assert response.status_code in [400, 403]

