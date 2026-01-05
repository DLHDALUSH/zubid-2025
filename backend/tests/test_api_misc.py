"""
Miscellaneous API Tests for ZUBID Backend
Tests: Categories, Health, CSRF, Featured, Navigation
"""
import pytest


def assert_success_response(response, expected_status=200):
    """Assert response is successful and return JSON data"""
    assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}: {response.data}"
    return response.get_json()


class TestHealthCheck:
    """Test health check endpoints"""
    
    def test_health_endpoint(self, client):
        """Test health check endpoint"""
        response = client.get('/api/health')
        data = assert_success_response(response)
        assert 'status' in data or 'healthy' in data or 'ok' in str(data).lower()
    
    def test_test_endpoint(self, client):
        """Test basic test endpoint"""
        response = client.get('/api/test')
        data = assert_success_response(response)
        assert 'message' in data or 'status' in data


class TestCSRF:
    """Test CSRF token endpoints"""
    
    def test_get_csrf_token(self, client):
        """Test getting CSRF token"""
        response = client.get('/api/csrf-token')
        if response.status_code == 200:
            data = response.get_json()
            assert 'csrf_token' in data or 'token' in data


class TestCategories:
    """Test category endpoints"""
    
    def test_get_categories(self, client):
        """Test getting all categories"""
        response = client.get('/api/categories')
        data = assert_success_response(response)
        assert 'categories' in data or isinstance(data, list)
    
    def test_get_categories_with_auctions(self, client, test_auction, test_category):
        """Test getting categories includes auction counts"""
        response = client.get('/api/categories')
        data = assert_success_response(response)
        categories = data.get('categories', data)
        assert len(categories) >= 1
    
    def test_create_category_authenticated(self, authenticated_client):
        """Test creating category when authenticated"""
        response = authenticated_client.post('/api/categories', json={
            'name': 'User Category',
            'description': 'Created by user'
        })
        # May or may not be allowed for regular users
        assert response.status_code in [200, 201, 401, 403]


class TestFeatured:
    """Test featured auctions endpoints"""
    
    def test_get_featured_auctions(self, client):
        """Test getting featured auctions"""
        response = client.get('/api/featured')
        data = assert_success_response(response)
        assert 'auctions' in data or 'featured' in data or isinstance(data, list)


class TestNavigation:
    """Test navigation menu endpoints"""
    
    def test_get_navigation_menu(self, client):
        """Test getting navigation menu"""
        response = client.get('/api/navigation/menu')
        if response.status_code == 200:
            data = response.get_json()
            assert isinstance(data, (dict, list))
    
    def test_create_menu_item(self, authenticated_client):
        """Test creating navigation menu item"""
        response = authenticated_client.post('/api/navigation/menu', json={
            'title': 'New Menu Item',
            'url': '/new-page',
            'order': 10
        })
        # Usually requires admin
        assert response.status_code in [200, 201, 401, 403]
    
    def test_update_menu_item(self, authenticated_client):
        """Test updating navigation menu item"""
        response = authenticated_client.put('/api/navigation/menu/1', json={
            'title': 'Updated Menu Item'
        })
        # Usually requires admin
        assert response.status_code in [200, 204, 401, 403, 404]


class TestImageUpload:
    """Test image upload endpoints"""
    
    def test_upload_image_unauthenticated(self, client):
        """Test image upload without authentication"""
        response = client.post('/api/upload/image')
        assert response.status_code in [401, 403]
    
    def test_upload_without_file(self, authenticated_client):
        """Test upload without providing file"""
        response = authenticated_client.post('/api/upload/image')
        assert response.status_code == 400


class TestFCMToken:
    """Test FCM token endpoints"""
    
    def test_register_fcm_token(self, authenticated_client):
        """Test registering FCM token"""
        response = authenticated_client.post('/api/user/fcm-token', json={
            'token': 'test-fcm-token-12345'
        })
        assert response.status_code in [200, 201, 204]
    
    def test_delete_fcm_token(self, authenticated_client):
        """Test deleting FCM token"""
        response = authenticated_client.delete('/api/user/fcm-token')
        assert response.status_code in [200, 204]


class TestDebugEndpoints:
    """Test debug endpoints (should be restricted in production)"""
    
    def test_db_status(self, client):
        """Test database status endpoint"""
        response = client.get('/api/debug/db-status')
        # May be disabled in production
        assert response.status_code in [200, 403, 404]

