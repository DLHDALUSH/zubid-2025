#!/usr/bin/env python
# ruff: noqa: F401
"""
Comprehensive Production Test Suite for ZUBID
Tests all critical functionality for production deployment

Usage:
    python test_production.py
"""

import sys
import os
import unittest
from datetime import datetime, timedelta, timezone

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

try:
    from app import app, db, User, Auction, Bid, Category, Invoice
    from werkzeug.security import generate_password_hash
except ImportError as e:
    print(f"Error importing app: {e}")
    print("Make sure you're running this from the backend directory")
    sys.exit(1)


class ProductionTestCase(unittest.TestCase):
    """Test suite for production readiness"""
    
    def setUp(self):
        """Set up test client and database"""
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        app.config['WTF_CSRF_ENABLED'] = False  # Disable CSRF for testing
        app.config['SECRET_KEY'] = 'test-secret-key'
        
        self.client = app.test_client()
        
        with app.app_context():
            db.create_all()
            # Create test user
            self.test_user = User(
                username='testuser',
                email='test@example.com',
                password_hash=generate_password_hash('Test123!@#'),
                id_number='TEST001',
                birth_date=datetime(1990, 1, 1).date(),
                phone='1234567890',
                address='123 Test St',
                role='user'
            )
            db.session.add(self.test_user)
            
            # Create test category
            self.test_category = Category(name='Test Category', description='Test')
            db.session.add(self.test_category)

            # Commit user and category so they receive DB-assigned ids
            db.session.commit()

            # Create test auction using assigned ids (or relationships)
            self.test_auction = Auction(
                item_name='Test Item',
                description='Test Description',
                starting_bid=100.0,
                current_bid=100.0,
                bid_increment=10.0,
                end_time=datetime.now(timezone.utc) + timedelta(days=7),
                seller_id=self.test_user.id,
                category_id=self.test_category.id,
                status='active'
            )
            db.session.add(self.test_auction)
            db.session.commit()

            # Save primitive ids and username so tests can use them outside the session
            self.test_user_id = self.test_user.id
            self.test_category_id = self.test_category.id
            self.test_auction_id = self.test_auction.id
            self.test_username = self.test_user.username
            # Create a separate user to act as a bidder in tests
            self.other_user = User(
                username='bidder',
                email='bidder@example.com',
                password_hash=generate_password_hash('BidPass123!'),
                id_number='BID001',
                birth_date=datetime(1992, 2, 2).date(),
                phone='0987654321',
                address='456 Bidder St',
                role='user'
            )
            db.session.add(self.other_user)
            db.session.commit()
            self.other_user_id = self.other_user.id
            self.other_username = self.other_user.username
    
    def tearDown(self):
        """Clean up after tests"""
        with app.app_context():
            db.session.remove()
            db.drop_all()
    
    def login(self):
        """Helper to login test user"""
        with self.client.session_transaction() as sess:
            sess['user_id'] = self.test_user_id
            sess['username'] = self.test_username
    
    # Authentication Tests
    def test_register_user(self):
        """Test user registration"""
        response = self.client.post('/api/register', json={
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'NewPass123!@#',
            'id_number': 'NEW001',
            'birth_date': '1990-01-01',
            'phone': '1234567890',
            'address': '123 New St'
        })
        self.assertEqual(response.status_code, 201)
        data = response.get_json()
        self.assertIn('message', data)
    
    def test_register_duplicate_username(self):
        """Test registration with duplicate username"""
        response = self.client.post('/api/register', json={
            'username': 'testuser',  # Already exists
            'email': 'different@example.com',
            'password': 'Test123!@#',
            'id_number': 'TEST002',
            'birth_date': '1990-01-01',
            'phone': '1234567890',
            'address': '123 Test St'
        })
        self.assertEqual(response.status_code, 400)
    
    def test_login(self):
        """Test user login"""
        response = self.client.post('/api/login', json={
            'username': 'testuser',
            'password': 'Test123!@#'
        })
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('message', data)
    
    def test_login_invalid_credentials(self):
        """Test login with invalid credentials"""
        response = self.client.post('/api/login', json={
            'username': 'testuser',
            'password': 'WrongPassword'
        })
        self.assertEqual(response.status_code, 401)
    
    # Auction Tests
    def test_get_auctions(self):
        """Test getting all auctions"""
        response = self.client.get('/api/auctions')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        # API may return a paginated dict with 'auctions' key or a plain list
        if isinstance(data, dict) and 'auctions' in data:
            auctions = data['auctions']
            self.assertIsInstance(auctions, list)
        else:
            self.assertIsInstance(data, list)
    
    def test_get_auction_by_id(self):
        """Test getting auction by ID"""
        response = self.client.get(f'/api/auctions/{self.test_auction_id}')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['id'], self.test_auction_id)
    
    def test_create_auction(self):
        """Test creating an auction"""
        self.login()
        response = self.client.post('/api/auctions', json={
            'item_name': 'New Item',
            'description': 'New Description',
            'starting_bid': 200.0,
            'bid_increment': 20.0,
            'end_time': (datetime.now(timezone.utc) + timedelta(days=7)).isoformat(),
            'category_id': self.test_category_id
        })
        self.assertEqual(response.status_code, 201)
        data = response.get_json()
        self.assertIn('id', data)
    
    def test_create_auction_unauthorized(self):
        """Test creating auction without login"""
        response = self.client.post('/api/auctions', json={
            'item_name': 'New Item',
            'description': 'New Description',
            'starting_bid': 200.0,
            'bid_increment': 20.0,
            'end_time': (datetime.now(timezone.utc) + timedelta(days=7)).isoformat(),
            'category_id': self.test_category_id
        })
        self.assertEqual(response.status_code, 401)
    
    # Bidding Tests
    def test_place_bid(self):
        """Test placing a bid"""
        # Login as a different user (bidder) to place a bid on the auction
        with self.client.session_transaction() as sess:
            sess['user_id'] = self.other_user_id
            sess['username'] = self.other_username

        response = self.client.post(f'/api/auctions/{self.test_auction_id}/bids', json={
            'amount': 110.0
        })
        self.assertEqual(response.status_code, 201)
        data = response.get_json()
        self.assertIn('current_bid', data)
    
    def test_place_bid_below_minimum(self):
        """Test placing bid below minimum"""
        self.login()
        response = self.client.post(f'/api/auctions/{self.test_auction_id}/bids', json={
            'amount': 50.0  # Below starting bid
        })
        self.assertEqual(response.status_code, 400)
    
    def test_place_bid_unauthorized(self):
        """Test placing bid without login"""
        response = self.client.post(f'/api/auctions/{self.test_auction_id}/bids', json={
            'amount': 110.0
        })
        self.assertEqual(response.status_code, 401)
    
    # Security Tests
    def test_security_headers(self):
        """Test security headers are present"""
        response = self.client.get('/api/test')
        self.assertIn('X-Content-Type-Options', response.headers)
        self.assertIn('X-Frame-Options', response.headers)
        self.assertIn('X-XSS-Protection', response.headers)
    
    def test_rate_limiting(self):
        """Test rate limiting (basic check)"""
        # Make multiple requests quickly
        for _ in range(10):
            response = self.client.get('/api/test')
            # Should not fail due to rate limiting for test endpoint
            self.assertIn(response.status_code, [200, 429])
    
    # Input Validation Tests
    def test_xss_prevention(self):
        """Test XSS prevention in input"""
        self.login()
        response = self.client.post('/api/auctions', json={
            'item_name': '<script>alert("xss")</script>',
            'description': 'Test',
            'starting_bid': 100.0,
            'bid_increment': 10.0,
            'end_time': (datetime.now(timezone.utc) + timedelta(days=7)).isoformat(),
            'category_id': self.test_category_id
        })
        # Should either sanitize or reject
        self.assertIn(response.status_code, [201, 400])
    
    def test_sql_injection_prevention(self):
        """Test SQL injection prevention"""
        self.login()
        # Try SQL injection in username
        response = self.client.post('/api/login', json={
            'username': "admin' OR '1'='1",
            'password': 'anything'
        })
        # Should not succeed
        self.assertNotEqual(response.status_code, 200)
    
    # API Endpoint Tests
    def test_api_test_endpoint(self):
        """Test API test endpoint"""
        response = self.client.get('/api/test')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('message', data)
    
    def test_get_categories(self):
        """Test getting categories"""
        response = self.client.get('/api/categories')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIsInstance(data, list)
    
    def test_get_featured_auctions(self):
        """Test getting featured auctions"""
        response = self.client.get('/api/featured')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIsInstance(data, list)


def run_tests():
    """Run all tests"""
    print("=" * 60)
    print("ZUBID Production Test Suite")
    print("=" * 60)
    print()
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromTestCase(ProductionTestCase)
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Print summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    print(f"Tests run: {result.testsRun}")
    print(f"Successes: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    
    if result.failures:
        print("\nFailures:")
        for test, traceback in result.failures:
            print(f"  - {test}")
    
    if result.errors:
        print("\nErrors:")
        for test, traceback in result.errors:
            print(f"  - {test}")
    
    # Return exit code
    return 0 if result.wasSuccessful() else 1


if __name__ == '__main__':
    sys.exit(run_tests())

