"""
Model Unit Tests for ZUBID Backend
Tests: User, Auction, Bid, Category models
"""
import pytest
from datetime import datetime, timedelta


class TestUserModel:
    """Test User model"""
    
    def test_create_user(self, db_session):
        """Test creating a user"""
        from app import User
        
        user = User(
            username='modeltest',
            email='model@test.com',
            phone='1234567890',
            created_at=datetime.utcnow()
        )
        user.set_password('TestPassword123!')
        db_session.session.add(user)
        db_session.session.commit()
        
        assert user.id is not None
        assert user.username == 'modeltest'
        assert user.email == 'model@test.com'
    
    def test_password_hashing(self, db_session):
        """Test password is properly hashed"""
        from app import User
        
        user = User(
            username='hashtest',
            email='hash@test.com',
            phone='9876543210'
        )
        user.set_password('MySecretPassword!')
        
        # Password should not be stored in plain text
        assert user.password_hash != 'MySecretPassword!'
        assert user.check_password('MySecretPassword!')
        assert not user.check_password('WrongPassword!')
    
    def test_user_repr(self, test_user):
        """Test user string representation"""
        repr_str = repr(test_user)
        assert 'testuser' in repr_str or str(test_user.id) in repr_str
    
    def test_user_admin_flag(self, admin_user):
        """Test admin user flag"""
        assert admin_user.is_admin is True
    
    def test_user_balance_default(self, db_session):
        """Test user balance defaults to zero"""
        from app import User
        
        user = User(
            username='balancetest',
            email='balance@test.com',
            phone='5556667777'
        )
        user.set_password('Balance123!')
        db_session.session.add(user)
        db_session.session.commit()
        
        assert user.balance == 0 or user.balance is None


class TestAuctionModel:
    """Test Auction model"""
    
    def test_create_auction(self, db_session, test_user, test_category):
        """Test creating an auction"""
        from app import Auction
        
        auction = Auction(
            title='Model Test Auction',
            description='Testing auction model',
            starting_price=100.0,
            current_price=100.0,
            min_increment=10.0,
            end_time=datetime.utcnow() + timedelta(days=7),
            seller_id=test_user.id,
            category_id=test_category.id,
            status='active'
        )
        db_session.session.add(auction)
        db_session.session.commit()
        
        assert auction.id is not None
        assert auction.title == 'Model Test Auction'
        assert auction.starting_price == 100.0
    
    def test_auction_seller_relationship(self, test_auction, test_user):
        """Test auction-seller relationship"""
        assert test_auction.seller_id == test_user.id
    
    def test_auction_category_relationship(self, test_auction, test_category):
        """Test auction-category relationship"""
        assert test_auction.category_id == test_category.id
    
    def test_auction_is_active(self, test_auction):
        """Test auction active status"""
        assert test_auction.status == 'active'
    
    def test_auction_end_time_future(self, test_auction):
        """Test auction end time is in future"""
        assert test_auction.end_time > datetime.utcnow()


class TestBidModel:
    """Test Bid model"""
    
    def test_create_bid(self, db_session, test_auction, test_user):
        """Test creating a bid"""
        from app import Bid, User
        
        # Create a different bidder
        bidder = User(
            username='bidmodeltest',
            email='bidmodel@test.com',
            phone='1112223333',
            is_verified=True
        )
        bidder.set_password('Bidder123!')
        db_session.session.add(bidder)
        db_session.session.commit()
        
        bid = Bid(
            amount=test_auction.current_price + test_auction.min_increment,
            auction_id=test_auction.id,
            bidder_id=bidder.id,
            created_at=datetime.utcnow()
        )
        db_session.session.add(bid)
        db_session.session.commit()
        
        assert bid.id is not None
        assert bid.amount == 110.0
        assert bid.auction_id == test_auction.id


class TestCategoryModel:
    """Test Category model"""
    
    def test_create_category(self, db_session):
        """Test creating a category"""
        from app import Category
        
        category = Category(
            name='Model Test Category',
            description='Testing category model',
            icon='test-icon',
            is_active=True
        )
        db_session.session.add(category)
        db_session.session.commit()
        
        assert category.id is not None
        assert category.name == 'Model Test Category'
    
    def test_category_is_active(self, test_category):
        """Test category active status"""
        assert test_category.is_active is True

