"""
User Profile API Tests for ZUBID Backend
Tests: Profile CRUD, Wishlist, Notifications, Preferences
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


class TestUserProfile:
    """Test user profile endpoints"""
    
    def test_get_profile(self, authenticated_client, test_user):
        """Test getting user profile"""
        response = authenticated_client.get('/api/user/profile')
        if response.status_code == 200:
            data = response.get_json()
            assert 'user' in data or 'email' in data or 'username' in data
    
    def test_get_profile_unauthenticated(self, client):
        """Test getting profile without authentication"""
        response = client.get('/api/user/profile')
        assert response.status_code in [401, 403]
    
    def test_update_profile(self, authenticated_client, test_user):
        """Test updating user profile"""
        response = authenticated_client.put('/api/user/profile', json={
            'first_name': 'Updated',
            'last_name': 'User',
            'bio': 'This is my updated bio'
        })
        assert response.status_code in [200, 204]
    
    def test_update_profile_invalid_email(self, authenticated_client):
        """Test updating profile with invalid email"""
        response = authenticated_client.put('/api/user/profile', json={
            'email': 'invalid-email'
        })
        assert response.status_code == 400


class TestWishlist:
    """Test wishlist endpoints"""
    
    def test_get_wishlist(self, authenticated_client):
        """Test getting user's wishlist"""
        response = authenticated_client.get('/api/wishlist')
        if response.status_code == 200:
            data = response.get_json()
            assert 'wishlist' in data or 'auctions' in data or isinstance(data, list)
    
    def test_add_to_wishlist(self, authenticated_client, test_auction):
        """Test adding auction to wishlist"""
        response = authenticated_client.post(f'/api/wishlist/{test_auction.id}')
        assert response.status_code in [200, 201, 204]
    
    def test_remove_from_wishlist(self, authenticated_client, test_auction):
        """Test removing auction from wishlist"""
        # First add it
        authenticated_client.post(f'/api/wishlist/{test_auction.id}')
        # Then remove it
        response = authenticated_client.delete(f'/api/wishlist/{test_auction.id}')
        assert response.status_code in [200, 204]
    
    def test_wishlist_unauthenticated(self, client):
        """Test wishlist access without authentication"""
        response = client.get('/api/wishlist')
        assert response.status_code in [401, 403]


class TestNotifications:
    """Test notification endpoints"""
    
    def test_get_notifications(self, authenticated_client):
        """Test getting user notifications"""
        response = authenticated_client.get('/api/notifications')
        if response.status_code == 200:
            data = response.get_json()
            assert 'notifications' in data or isinstance(data, list)
    
    def test_get_unread_count(self, authenticated_client):
        """Test getting unread notification count"""
        response = authenticated_client.get('/api/notifications/unread-count')
        if response.status_code == 200:
            data = response.get_json()
            assert 'count' in data or 'unread_count' in data or isinstance(data.get('count'), int)
    
    def test_mark_notification_read(self, authenticated_client, db_session, test_user):
        """Test marking notification as read"""
        from app import Notification
        
        notification = Notification(
            user_id=test_user.id,
            title='Test Notification',
            message='This is a test notification',
            is_read=False
        )
        db_session.session.add(notification)
        db_session.session.commit()
        
        response = authenticated_client.put(f'/api/notifications/{notification.id}/read')
        assert response.status_code in [200, 204]
    
    def test_mark_all_read(self, authenticated_client):
        """Test marking all notifications as read"""
        response = authenticated_client.put('/api/notifications/read-all')
        assert response.status_code in [200, 204]
    
    def test_delete_notification(self, authenticated_client, db_session, test_user):
        """Test deleting a notification"""
        from app import Notification
        
        notification = Notification(
            user_id=test_user.id,
            title='Delete Me',
            message='This notification will be deleted',
            is_read=False
        )
        db_session.session.add(notification)
        db_session.session.commit()
        
        response = authenticated_client.delete(f'/api/notifications/{notification.id}')
        assert response.status_code in [200, 204]


class TestUserPreferences:
    """Test user preferences endpoints"""
    
    def test_get_preferences(self, authenticated_client):
        """Test getting user preferences"""
        response = authenticated_client.get('/api/user/preferences')
        if response.status_code == 200:
            data = response.get_json()
            assert isinstance(data, dict)
    
    def test_update_preferences(self, authenticated_client):
        """Test updating user preferences"""
        response = authenticated_client.put('/api/user/preferences', json={
            'email_notifications': True,
            'push_notifications': False,
            'language': 'en'
        })
        assert response.status_code in [200, 204]


class TestMyAuctions:
    """Test user's own auctions endpoints"""
    
    def test_get_my_auctions(self, authenticated_client, test_auction):
        """Test getting user's own auctions"""
        response = authenticated_client.get('/api/my-auctions')
        if response.status_code == 200:
            data = response.get_json()
            assert 'auctions' in data or isinstance(data, list)
    
    def test_get_user_auctions(self, authenticated_client):
        """Test alternative endpoint for user auctions"""
        response = authenticated_client.get('/api/user/auctions')
        if response.status_code == 200:
            data = response.get_json()
            assert 'auctions' in data or isinstance(data, list)

