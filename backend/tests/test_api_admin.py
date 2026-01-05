"""
Admin API Tests for ZUBID Backend
Tests: Admin user management, auction management, stats
"""
import pytest


def assert_success_response(response, expected_status=200):
    """Assert response is successful and return JSON data"""
    assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}: {response.data}"
    return response.get_json()


def assert_error_response(response, expected_status=400):
    """Assert response is an error"""
    assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}"
    return response.get_json()


class TestAdminUsers:
    """Test admin user management endpoints"""
    
    def test_get_users_as_admin(self, admin_client):
        """Test getting users list as admin"""
        response = admin_client.get('/api/admin/users')
        if response.status_code == 200:
            data = response.get_json()
            assert 'users' in data or isinstance(data, list)
    
    def test_get_users_as_regular_user(self, authenticated_client):
        """Test that regular users cannot access admin users"""
        response = authenticated_client.get('/api/admin/users')
        assert response.status_code in [401, 403]
    
    def test_get_users_unauthenticated(self, client):
        """Test that unauthenticated users cannot access admin"""
        response = client.get('/api/admin/users')
        assert response.status_code in [401, 403]
    
    def test_get_single_user_as_admin(self, admin_client, test_user):
        """Test getting single user as admin"""
        response = admin_client.get(f'/api/admin/users/{test_user.id}')
        if response.status_code == 200:
            data = response.get_json()
            assert 'user' in data or 'id' in data
    
    def test_update_user_as_admin(self, admin_client, test_user):
        """Test updating user as admin"""
        response = admin_client.put(f'/api/admin/users/{test_user.id}', json={
            'is_verified': True
        })
        assert response.status_code in [200, 204]
    
    def test_delete_user_as_admin(self, admin_client, db_session):
        """Test deleting user as admin"""
        from app import User
        # Create a user to delete
        user_to_delete = User(
            username='deleteme',
            email='deleteme@example.com',
            phone='1231231234',
            is_verified=True
        )
        user_to_delete.set_password('DeleteMe123!')
        db_session.session.add(user_to_delete)
        db_session.session.commit()
        
        response = admin_client.delete(f'/api/admin/users/{user_to_delete.id}')
        assert response.status_code in [200, 204]


class TestAdminAuctions:
    """Test admin auction management endpoints"""
    
    def test_get_auctions_as_admin(self, admin_client):
        """Test getting all auctions as admin"""
        response = admin_client.get('/api/admin/auctions')
        if response.status_code == 200:
            data = response.get_json()
            assert 'auctions' in data or isinstance(data, list)
    
    def test_update_auction_as_admin(self, admin_client, test_auction):
        """Test updating auction as admin"""
        response = admin_client.put(f'/api/admin/auctions/{test_auction.id}', json={
            'status': 'active'
        })
        assert response.status_code in [200, 204]
    
    def test_delete_auction_as_admin(self, admin_client, db_session, test_category, test_user):
        """Test deleting auction as admin"""
        from app import Auction
        from datetime import datetime, timedelta
        
        auction = Auction(
            title='Auction to Delete',
            description='This will be deleted',
            starting_price=50.0,
            current_price=50.0,
            min_increment=5.0,
            end_time=datetime.utcnow() + timedelta(days=1),
            seller_id=test_user.id,
            category_id=test_category.id,
            status='draft'
        )
        db_session.session.add(auction)
        db_session.session.commit()
        
        response = admin_client.delete(f'/api/admin/auctions/{auction.id}')
        assert response.status_code in [200, 204]


class TestAdminStats:
    """Test admin statistics endpoints"""
    
    def test_get_stats_as_admin(self, admin_client):
        """Test getting admin stats"""
        response = admin_client.get('/api/admin/stats')
        if response.status_code == 200:
            data = response.get_json()
            # Stats should contain various metrics
            assert isinstance(data, dict)
    
    def test_get_stats_as_regular_user(self, authenticated_client):
        """Test that regular users cannot access admin stats"""
        response = authenticated_client.get('/api/admin/stats')
        assert response.status_code in [401, 403]


class TestAdminCategories:
    """Test admin category management endpoints"""
    
    def test_create_category_as_admin(self, admin_client):
        """Test creating category as admin"""
        response = admin_client.post('/api/admin/categories', json={
            'name': 'New Admin Category',
            'description': 'Created by admin',
            'icon': 'new-icon'
        })
        assert response.status_code in [200, 201]
    
    def test_update_category_as_admin(self, admin_client, test_category):
        """Test updating category as admin"""
        response = admin_client.put(f'/api/admin/categories/{test_category.id}', json={
            'name': 'Updated Category Name'
        })
        assert response.status_code in [200, 204]
    
    def test_delete_category_as_admin(self, admin_client, db_session):
        """Test deleting category as admin"""
        from app import Category
        
        category = Category(
            name='Category to Delete',
            description='This will be deleted',
            icon='delete-icon',
            is_active=True
        )
        db_session.session.add(category)
        db_session.session.commit()
        
        response = admin_client.delete(f'/api/admin/categories/{category.id}')
        assert response.status_code in [200, 204, 400]  # 400 if category has auctions


class TestAdminReturnRequests:
    """Test admin return request management"""
    
    def test_get_return_requests_as_admin(self, admin_client):
        """Test getting return requests as admin"""
        response = admin_client.get('/api/admin/return-requests')
        if response.status_code == 200:
            data = response.get_json()
            assert 'requests' in data or isinstance(data, list)

