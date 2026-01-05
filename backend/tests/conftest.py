"""
Pytest Configuration and Fixtures for ZUBID Backend Tests
"""
import os
import sys
import pytest
import tempfile
from datetime import datetime, timedelta

# Add backend directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, db, User, Auction, Bid, Category


@pytest.fixture(scope='session')
def test_app():
    """Create application for testing"""
    app.config['TESTING'] = True
    app.config['WTF_CSRF_ENABLED'] = False
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    app.config['SECRET_KEY'] = 'test-secret-key'
    
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()


@pytest.fixture(scope='function')
def client(test_app):
    """Create test client"""
    return test_app.test_client()


@pytest.fixture(scope='function')
def db_session(test_app):
    """Create database session for testing"""
    with test_app.app_context():
        db.create_all()
        yield db
        db.session.rollback()
        # Clean up tables
        for table in reversed(db.metadata.sorted_tables):
            db.session.execute(table.delete())
        db.session.commit()


@pytest.fixture
def test_user(db_session):
    """Create a test user"""
    from datetime import timezone, date
    from werkzeug.security import generate_password_hash
    user = User(
        username='testuser',
        email='test@example.com',
        phone='1234567890',
        id_number='TEST123456',
        password_hash=generate_password_hash('TestPassword123!'),
        birth_date=date(1990, 1, 1),
        address='Test Address',
        email_verified=True,
        phone_verified=True,
        is_active=True,
        created_at=datetime.now(timezone.utc)
    )
    db_session.session.add(user)
    db_session.session.commit()
    # Store the id before returning to avoid detached instance issues
    user_id = user.id
    db_session.session.refresh(user)
    return user


@pytest.fixture
def admin_user(db_session):
    """Create an admin user"""
    from datetime import timezone, date
    from werkzeug.security import generate_password_hash
    admin = User(
        username='adminuser',
        email='admin@example.com',
        phone='0987654321',
        id_number='ADMIN123456',
        password_hash=generate_password_hash('AdminPassword123!'),
        birth_date=date(1990, 1, 1),
        address='Admin Address',
        role='admin',
        email_verified=True,
        phone_verified=True,
        is_active=True,
        created_at=datetime.now(timezone.utc)
    )
    db_session.session.add(admin)
    db_session.session.commit()
    db_session.session.refresh(admin)
    return admin


@pytest.fixture
def test_category(db_session):
    """Create a test category"""
    category = Category(
        name='Test Category',
        description='A test category',
        icon='test-icon',
        is_active=True
    )
    db_session.session.add(category)
    db_session.session.commit()
    return category


@pytest.fixture
def test_auction(db_session, test_user, test_category):
    """Create a test auction"""
    from datetime import timezone
    auction = Auction(
        title='Test Auction',
        description='A test auction item',
        starting_price=100.0,
        current_price=100.0,
        min_increment=10.0,
        end_time=datetime.now(timezone.utc) + timedelta(days=7),
        seller_id=test_user.id,
        category_id=test_category.id,
        status='active',
        created_at=datetime.now(timezone.utc)
    )
    db_session.session.add(auction)
    db_session.session.commit()
    return auction


@pytest.fixture
def authenticated_client(client, test_user, db_session):
    """Create an authenticated test client"""
    # Refresh the user to ensure it's attached to the session
    user_id = test_user.id
    with client.session_transaction() as sess:
        sess['user_id'] = user_id  # App uses 'user_id' not '_user_id'
    return client


@pytest.fixture
def admin_client(client, admin_user, db_session):
    """Create an authenticated admin client"""
    # Refresh the user to ensure it's attached to the session
    user_id = admin_user.id
    with client.session_transaction() as sess:
        sess['user_id'] = user_id  # App uses 'user_id' not '_user_id'
    return client


# API Response helpers
def assert_success_response(response, status_code=200):
    """Assert response is successful"""
    assert response.status_code == status_code
    return response.get_json()


def assert_error_response(response, status_code=400):
    """Assert response is an error"""
    assert response.status_code == status_code
    data = response.get_json()
    assert 'error' in data or 'message' in data
    return data

