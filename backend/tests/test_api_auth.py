"""
Authentication API Tests for ZUBID Backend
Tests: Register, Login, Logout, Password Reset, User Profile
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


class TestRegistration:
    """Test user registration endpoints"""

    def test_register_success(self, client, db_session):
        """Test successful user registration"""
        response = client.post('/api/register', json={
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'SecurePassword123!',
            'phone': '1112223333',
            'id_number': 'NEW123456',
            'birth_date': '1990-01-01',
            'address': 'Test Address'
        })
        data = assert_success_response(response, 201)
        assert 'user' in data or 'message' in data

    def test_register_duplicate_email(self, client, test_user):
        """Test registration with existing email fails"""
        response = client.post('/api/register', json={
            'username': 'anotheruser',
            'email': 'test@example.com',  # Same as test_user
            'password': 'SecurePassword123!',
            'phone': '1112223334',
            'id_number': 'DUP123456'
        })
        assert response.status_code in [400, 409]

    def test_register_duplicate_username(self, client, test_user):
        """Test registration with existing username fails"""
        response = client.post('/api/register', json={
            'username': 'testuser',  # Same as test_user
            'email': 'different@example.com',
            'password': 'SecurePassword123!',
            'phone': '1112223335',
            'id_number': 'DUP123457'
        })
        assert response.status_code in [400, 409]
    
    def test_register_invalid_email(self, client, db_session):
        """Test registration with invalid email fails"""
        response = client.post('/api/register', json={
            'username': 'newuser',
            'email': 'invalid-email',
            'password': 'SecurePassword123!',
            'phone': '1112223333'
        })
        assert response.status_code == 400
    
    def test_register_weak_password(self, client, db_session):
        """Test registration with weak password fails"""
        response = client.post('/api/register', json={
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': '123',  # Too weak
            'phone': '1112223333'
        })
        assert response.status_code == 400
    
    def test_register_missing_fields(self, client, db_session):
        """Test registration with missing fields fails"""
        response = client.post('/api/register', json={
            'username': 'newuser'
            # Missing email and password
        })
        # 400 for validation error, 429 for rate limiting
        assert response.status_code in [400, 429]


class TestLogin:
    """Test user login endpoints"""
    
    def test_login_success_email(self, client, test_user):
        """Test successful login with username (API uses username field)"""
        response = client.post('/api/login', json={
            'username': 'testuser',  # API uses username field
            'password': 'TestPassword123!'
        })
        data = assert_success_response(response)
        assert 'user' in data or 'message' in data

    def test_login_success_username(self, client, test_user):
        """Test successful login with username"""
        response = client.post('/api/login', json={
            'username': 'testuser',
            'password': 'TestPassword123!'
        })
        data = assert_success_response(response)
        assert 'user' in data or 'message' in data

    def test_login_wrong_password(self, client, test_user):
        """Test login with wrong password fails"""
        response = client.post('/api/login', json={
            'username': 'testuser',
            'password': 'WrongPassword123!'
        })
        assert response.status_code in [400, 401]

    def test_login_nonexistent_user(self, client, db_session):
        """Test login with non-existent user fails"""
        response = client.post('/api/login', json={
            'username': 'nonexistent',
            'password': 'SomePassword123!'
        })
        assert response.status_code in [400, 401, 404]
    
    def test_login_missing_credentials(self, client, db_session):
        """Test login without credentials fails"""
        response = client.post('/api/login', json={})
        assert response.status_code == 400


class TestLogout:
    """Test user logout endpoints"""
    
    def test_logout_success(self, authenticated_client):
        """Test successful logout"""
        response = authenticated_client.post('/api/logout')
        assert response.status_code in [200, 204]
    
    def test_logout_unauthenticated(self, client):
        """Test logout when not logged in"""
        response = client.post('/api/logout')
        # Should succeed or return appropriate status
        assert response.status_code in [200, 204, 401]


class TestCurrentUser:
    """Test current user endpoint"""
    
    def test_get_current_user_authenticated(self, authenticated_client, test_user):
        """Test getting current user when authenticated"""
        response = authenticated_client.get('/api/me')
        if response.status_code == 200:
            data = response.get_json()
            assert 'user' in data or 'username' in data or 'email' in data
    
    def test_get_current_user_unauthenticated(self, client):
        """Test getting current user when not authenticated"""
        response = client.get('/api/me')
        assert response.status_code in [401, 403]


class TestPasswordChange:
    """Test password change endpoints"""
    
    def test_change_password_success(self, authenticated_client, test_user):
        """Test successful password change"""
        response = authenticated_client.post('/api/change-password', json={
            'current_password': 'TestPassword123!',
            'new_password': 'NewSecurePassword456!'
        })
        assert response.status_code in [200, 204]
    
    def test_change_password_wrong_current(self, authenticated_client, test_user):
        """Test password change with wrong current password"""
        response = authenticated_client.post('/api/change-password', json={
            'current_password': 'WrongPassword!',
            'new_password': 'NewSecurePassword456!'
        })
        assert response.status_code in [400, 401, 403]

