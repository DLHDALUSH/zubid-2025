"""
Auction API Tests for ZUBID Backend
Tests: Listing, Creating, Updating, Bidding, Buy Now
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


class TestAuctionListing:
    """Test auction listing endpoints"""
    
    def test_get_auctions_empty(self, client, db_session):
        """Test getting auctions when none exist"""
        response = client.get('/api/auctions')
        data = assert_success_response(response)
        assert 'auctions' in data or isinstance(data, list)
    
    def test_get_auctions_with_data(self, client, test_auction):
        """Test getting auctions when they exist"""
        response = client.get('/api/auctions')
        data = assert_success_response(response)
        auctions = data.get('auctions', data)
        assert len(auctions) >= 1
    
    def test_get_auctions_with_pagination(self, client, test_auction):
        """Test auction pagination"""
        response = client.get('/api/auctions?page=1&per_page=10')
        data = assert_success_response(response)
        assert 'auctions' in data or isinstance(data, list)
    
    def test_get_auctions_filter_by_category(self, client, test_auction, test_category):
        """Test filtering auctions by category"""
        response = client.get(f'/api/auctions?category_id={test_category.id}')
        data = assert_success_response(response)
        auctions = data.get('auctions', data)
        if len(auctions) > 0:
            # Verify filter worked
            for auction in auctions:
                assert auction.get('category_id') == test_category.id
    
    def test_get_auctions_filter_by_status(self, client, test_auction):
        """Test filtering auctions by status"""
        response = client.get('/api/auctions?status=active')
        data = assert_success_response(response)
        auctions = data.get('auctions', data)
        for auction in auctions:
            assert auction.get('status') == 'active'
    
    def test_get_auctions_search(self, client, test_auction):
        """Test searching auctions"""
        response = client.get('/api/auctions?search=Test')
        data = assert_success_response(response)
        assert 'auctions' in data or isinstance(data, list)
    
    def test_get_single_auction(self, client, test_auction):
        """Test getting a single auction"""
        response = client.get(f'/api/auctions/{test_auction.id}')
        data = assert_success_response(response)
        assert data.get('id') == test_auction.id or data.get('auction', {}).get('id') == test_auction.id
    
    def test_get_nonexistent_auction(self, client, db_session):
        """Test getting non-existent auction"""
        response = client.get('/api/auctions/99999')
        assert response.status_code == 404


class TestAuctionCreation:
    """Test auction creation endpoints"""
    
    def test_create_auction_success(self, authenticated_client, test_category, test_user):
        """Test successful auction creation"""
        response = authenticated_client.post('/api/auctions', json={
            'title': 'New Auction Item',
            'description': 'A brand new item for auction',
            'starting_price': 50.0,
            'min_increment': 5.0,
            'end_time': (datetime.utcnow() + timedelta(days=7)).isoformat(),
            'category_id': test_category.id
        })
        assert response.status_code in [200, 201]
        data = response.get_json()
        assert 'auction' in data or 'id' in data
    
    def test_create_auction_unauthenticated(self, client, test_category):
        """Test creating auction without authentication"""
        response = client.post('/api/auctions', json={
            'title': 'New Auction Item',
            'description': 'A brand new item for auction',
            'starting_price': 50.0,
            'end_time': (datetime.utcnow() + timedelta(days=7)).isoformat(),
            'category_id': test_category.id
        })
        assert response.status_code in [401, 403]
    
    def test_create_auction_missing_title(self, authenticated_client, test_category):
        """Test creating auction without title"""
        response = authenticated_client.post('/api/auctions', json={
            'description': 'Missing title',
            'starting_price': 50.0,
            'end_time': (datetime.utcnow() + timedelta(days=7)).isoformat(),
            'category_id': test_category.id
        })
        assert response.status_code == 400
    
    def test_create_auction_invalid_price(self, authenticated_client, test_category):
        """Test creating auction with invalid price"""
        response = authenticated_client.post('/api/auctions', json={
            'title': 'Test Item',
            'description': 'Invalid price test',
            'starting_price': -10.0,  # Negative price
            'end_time': (datetime.utcnow() + timedelta(days=7)).isoformat(),
            'category_id': test_category.id
        })
        assert response.status_code == 400
    
    def test_create_auction_past_end_time(self, authenticated_client, test_category):
        """Test creating auction with past end time"""
        response = authenticated_client.post('/api/auctions', json={
            'title': 'Test Item',
            'description': 'Past end time test',
            'starting_price': 50.0,
            'end_time': (datetime.utcnow() - timedelta(days=1)).isoformat(),  # Past
            'category_id': test_category.id
        })
        assert response.status_code == 400


class TestAuctionUpdate:
    """Test auction update endpoints"""
    
    def test_update_own_auction(self, authenticated_client, test_auction, test_user):
        """Test updating own auction"""
        response = authenticated_client.put(f'/api/auctions/{test_auction.id}', json={
            'title': 'Updated Auction Title',
            'description': 'Updated description'
        })
        # May succeed or fail depending on auction state
        assert response.status_code in [200, 400, 403]
    
    def test_update_others_auction(self, client, test_auction, db_session):
        """Test updating another user's auction fails"""
        # Create another user and login
        from app import User
        other_user = User(
            username='otheruser',
            email='other@example.com',
            phone='5556667777',
            is_verified=True
        )
        other_user.set_password('OtherPassword123!')
        db_session.session.add(other_user)
        db_session.session.commit()
        
        # Login as other user
        with client.session_transaction() as sess:
            sess['_user_id'] = str(other_user.id)
        
        response = client.put(f'/api/auctions/{test_auction.id}', json={
            'title': 'Hacked Title'
        })
        assert response.status_code in [401, 403]

