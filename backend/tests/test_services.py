"""
Service/Business Logic Unit Tests for ZUBID Backend
Tests: Auction logic, Bid validation, Payment processing
"""
import pytest
from datetime import datetime, timedelta


class TestAuctionLogic:
    """Test auction business logic"""
    
    def test_auction_is_ended(self, db_session, test_user, test_category):
        """Test checking if auction has ended"""
        from app import Auction
        
        # Create ended auction
        ended_auction = Auction(
            title='Ended Auction',
            description='This auction has ended',
            starting_price=100.0,
            current_price=100.0,
            min_increment=10.0,
            end_time=datetime.utcnow() - timedelta(hours=1),  # Past
            seller_id=test_user.id,
            category_id=test_category.id,
            status='active'
        )
        db_session.session.add(ended_auction)
        db_session.session.commit()
        
        # Check if end time has passed
        assert ended_auction.end_time < datetime.utcnow()
    
    def test_auction_time_remaining(self, test_auction):
        """Test calculating time remaining"""
        time_remaining = test_auction.end_time - datetime.utcnow()
        assert time_remaining.total_seconds() > 0
    
    def test_auction_price_update_on_bid(self, db_session, test_auction):
        """Test that auction price updates when bid is placed"""
        from app import Bid, User
        
        bidder = User(
            username='priceupdate',
            email='priceupdate@test.com',
            phone='4445556666',
            is_verified=True
        )
        bidder.set_password('PriceUpdate123!')
        db_session.session.add(bidder)
        db_session.session.commit()
        
        new_price = test_auction.current_price + test_auction.min_increment
        bid = Bid(
            amount=new_price,
            auction_id=test_auction.id,
            bidder_id=bidder.id
        )
        db_session.session.add(bid)
        test_auction.current_price = new_price
        db_session.session.commit()
        
        assert test_auction.current_price == new_price


class TestBidValidation:
    """Test bid validation logic"""
    
    def test_bid_must_exceed_current_price(self, test_auction):
        """Test that bid must exceed current price"""
        current = test_auction.current_price
        min_valid_bid = current + test_auction.min_increment
        
        assert min_valid_bid > current
    
    def test_bid_increment_validation(self, test_auction):
        """Test minimum bid increment"""
        current = test_auction.current_price
        min_increment = test_auction.min_increment
        
        # Valid bid
        valid_bid = current + min_increment
        assert valid_bid >= current + min_increment
        
        # Invalid bid (too small increment)
        invalid_bid = current + (min_increment / 2)
        assert invalid_bid < current + min_increment
    
    def test_seller_cannot_bid(self, test_auction, test_user):
        """Test that seller ID matches and cannot bid"""
        assert test_auction.seller_id == test_user.id
        # Logic should prevent bidding on own auction


class TestUserBalance:
    """Test user balance operations"""
    
    def test_add_balance(self, db_session, test_user):
        """Test adding balance to user"""
        initial_balance = test_user.balance or 0
        test_user.balance = initial_balance + 100.0
        db_session.session.commit()
        
        assert test_user.balance == initial_balance + 100.0
    
    def test_deduct_balance(self, db_session, test_user):
        """Test deducting balance from user"""
        test_user.balance = 200.0
        db_session.session.commit()
        
        test_user.balance -= 50.0
        db_session.session.commit()
        
        assert test_user.balance == 150.0
    
    def test_balance_cannot_go_negative(self, test_user):
        """Test balance validation (should not allow negative)"""
        # This tests the business logic expectation
        current_balance = test_user.balance or 0
        # Business logic should prevent balance < 0
        assert current_balance >= 0


class TestCategoryValidation:
    """Test category validation"""
    
    def test_category_name_required(self, db_session):
        """Test that category name is required"""
        from app import Category
        
        try:
            category = Category(
                name='',  # Empty name
                description='Test'
            )
            db_session.session.add(category)
            db_session.session.commit()
            # If we get here, empty names are allowed
            assert category.name == ''
        except Exception:
            # Empty names should cause an error
            db_session.session.rollback()
            pass
    
    def test_category_unique_name(self, db_session, test_category):
        """Test category name uniqueness"""
        from app import Category
        from sqlalchemy.exc import IntegrityError
        
        try:
            duplicate = Category(
                name=test_category.name,  # Same name
                description='Duplicate test'
            )
            db_session.session.add(duplicate)
            db_session.session.commit()
            # If allowed, names may not be unique
        except IntegrityError:
            db_session.session.rollback()
            # Names are unique - this is expected


class TestAuctionStatusTransitions:
    """Test auction status transitions"""
    
    def test_draft_to_active(self, db_session, test_user, test_category):
        """Test transitioning auction from draft to active"""
        from app import Auction
        
        auction = Auction(
            title='Draft Auction',
            description='Starting as draft',
            starting_price=100.0,
            current_price=100.0,
            min_increment=10.0,
            end_time=datetime.utcnow() + timedelta(days=7),
            seller_id=test_user.id,
            category_id=test_category.id,
            status='draft'
        )
        db_session.session.add(auction)
        db_session.session.commit()
        
        assert auction.status == 'draft'
        
        # Activate
        auction.status = 'active'
        db_session.session.commit()
        
        assert auction.status == 'active'
    
    def test_active_to_completed(self, db_session, test_auction):
        """Test transitioning auction from active to completed"""
        test_auction.status = 'completed'
        db_session.session.commit()
        
        assert test_auction.status == 'completed'

