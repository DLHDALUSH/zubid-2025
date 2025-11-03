from flask import Flask, request, jsonify, session
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta, date, timezone
from functools import wraps
from sqlalchemy import func
import os
import json

# Load environment variables
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    # python-dotenv not installed, continue without it
    pass

app = Flask(__name__)

# Configuration from environment variables with fallbacks for development
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URI', 'sqlite:///auction.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max request size

db = SQLAlchemy(app)

# CORS configuration - restrict origins in production
cors_origins = os.getenv('CORS_ORIGINS', '*')
if cors_origins == '*':
    # Development mode - allow all origins
    CORS(app, supports_credentials=True, origins="*")
else:
    # Production mode - restrict to specific origins
    allowed_origins = [origin.strip() for origin in cors_origins.split(',')]
    CORS(app, supports_credentials=True, origins=allowed_origins)

# Database Models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    id_number = db.Column(db.String(50), unique=True, nullable=False)  # National ID or Passport
    birth_date = db.Column(db.Date)  # Date of birth
    biometric_data = db.Column(db.Text)  # Stored as JSON or encoded fingerprint/face data
    address = db.Column(db.String(255))
    phone = db.Column(db.String(20))
    role = db.Column(db.String(20), default='user')  # user, admin
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    
    # Explicitly specify foreign_keys to avoid ambiguity
    auctions = db.relationship('Auction', foreign_keys='Auction.seller_id', backref='seller', lazy=True)
    won_auctions = db.relationship('Auction', foreign_keys='Auction.winner_id', backref='winner', lazy=True)
    bids = db.relationship('Bid', backref='bidder', lazy=True)

class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    description = db.Column(db.Text)
    
    auctions = db.relationship('Auction', backref='category', lazy=True)

class Auction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    item_name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    starting_bid = db.Column(db.Float, nullable=False)
    current_bid = db.Column(db.Float, default=0)
    bid_increment = db.Column(db.Float, default=1.0)
    start_time = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    end_time = db.Column(db.DateTime, nullable=False)
    seller_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    winner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
    status = db.Column(db.String(20), default='active')  # active, ended, cancelled
    featured = db.Column(db.Boolean, default=False)
    
    images = db.relationship('Image', backref='auction', lazy=True, cascade='all, delete-orphan')
    bids = db.relationship('Bid', backref='auction', lazy=True, order_by='Bid.timestamp.desc()', cascade='all, delete-orphan')

class Image(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    url = db.Column(db.String(500), nullable=False)
    is_primary = db.Column(db.Boolean, default=False)

class Bid(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    is_auto_bid = db.Column(db.Boolean, default=False)
    max_auto_bid = db.Column(db.Float, nullable=True)

# Authentication decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({'error': 'Authentication required'}), 401
        return f(*args, **kwargs)
    return decorated_function

# Admin decorator
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({'error': 'Authentication required'}), 401
        user = User.query.get(session['user_id'])
        if not user or user.role != 'admin':
            return jsonify({'error': 'Admin access required'}), 403
        return f(*args, **kwargs)
    return decorated_function

# Helper function to ensure datetime is timezone-aware
def ensure_timezone_aware(dt):
    """Ensure datetime is timezone-aware (UTC). If naive, assume UTC."""
    if dt is None:
        return None
    if dt.tzinfo is None:
        # If naive, assume UTC
        return dt.replace(tzinfo=timezone.utc)
    # If already timezone-aware, return as-is
    return dt

# User Management APIs
@app.route('/api/register', methods=['POST'])
def register():
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        
        # Validate required fields
        if not data.get('username'):
            return jsonify({'error': 'Username is required'}), 400
        if not data.get('email'):
            return jsonify({'error': 'Email is required'}), 400
        if not data.get('password'):
            return jsonify({'error': 'Password is required'}), 400
        if not data.get('id_number'):
            return jsonify({'error': 'ID Number is required'}), 400
        if not data.get('birth_date'):
            return jsonify({'error': 'Date of Birth is required'}), 400
        if not data.get('biometric_data'):
            return jsonify({'error': 'Biometric authentication is required'}), 400
        
        # Check if username already exists
        if User.query.filter_by(username=data['username']).first():
            return jsonify({'error': 'Username already exists'}), 400
        
        # Check if email already exists
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'error': 'Email already exists'}), 400
        
        # Check if ID number already exists
        if User.query.filter_by(id_number=data['id_number']).first():
            return jsonify({'error': 'ID Number already registered'}), 400
        
        # Parse birth_date string to Date object
        birth_date_obj = None
        if data.get('birth_date'):
            try:
                # Expecting format YYYY-MM-DD from HTML date input
                birth_date_obj = datetime.strptime(data['birth_date'], '%Y-%m-%d').date()
            except (ValueError, TypeError) as e:
                return jsonify({'error': f'Invalid date format for birth date: {str(e)}'}), 400
        
        # Create user
        user = User(
            username=data['username'],
            email=data['email'],
            password_hash=generate_password_hash(data['password']),
            id_number=data['id_number'],
            birth_date=birth_date_obj,
            biometric_data=data['biometric_data'],
            address=data.get('address', ''),
            phone=data.get('phone', '')
        )
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'message': 'User registered successfully', 
            'user_id': user.id,
            'username': user.username
        }), 201
    except Exception as e:
        db.session.rollback()
        print(f"Registration error: {str(e)}")
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500

@app.route('/api/login', methods=['POST'])
def login():
    if not request.json:
        return jsonify({'error': 'No JSON data received'}), 400
    
    data = request.json
    if not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Username and password are required'}), 400
    
    user = User.query.filter_by(username=data['username']).first()
    if user and check_password_hash(user.password_hash, data['password']):
        session['user_id'] = user.id
        return jsonify({
            'message': 'Login successful',
            'user': {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'role': user.role
            }
        }), 200
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/api/logout', methods=['POST'])
def logout():
    session.pop('user_id', None)
    return jsonify({'message': 'Logout successful'}), 200

@app.route('/api/user/profile', methods=['GET'])
@login_required
def get_profile():
    user = User.query.get(session['user_id'])
    return jsonify({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'id_number': user.id_number,
        'birth_date': user.birth_date.isoformat() if user.birth_date else None,
        'address': user.address,
        'phone': user.phone,
        'role': user.role
    }), 200

@app.route('/api/user/profile', methods=['PUT'])
@login_required
def update_profile():
    user = User.query.get(session['user_id'])
    data = request.json
    if 'email' in data:
        user.email = data['email']
    if 'address' in data:
        user.address = data['address']
    if 'phone' in data:
        user.phone = data['phone']
    db.session.commit()
    return jsonify({'message': 'Profile updated successfully'}), 200

# Category APIs
@app.route('/api/categories', methods=['GET'])
def get_categories():
    categories = Category.query.all()
    return jsonify([{
        'id': cat.id,
        'name': cat.name,
        'description': cat.description
    } for cat in categories]), 200

@app.route('/api/categories', methods=['POST'])
@login_required
def create_category():
    data = request.json
    if Category.query.filter_by(name=data['name']).first():
        return jsonify({'error': 'Category already exists'}), 400
    category = Category(name=data['name'], description=data.get('description', ''))
    db.session.add(category)
    db.session.commit()
    return jsonify({'message': 'Category created', 'id': category.id}), 201

# Auction Management APIs
@app.route('/api/auctions', methods=['GET'])
def get_auctions():
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 12, type=int)
        category_id = request.args.get('category_id', type=int)
        search = request.args.get('search', '')
        sort_by = request.args.get('sort_by', 'end_time')
        featured_only = request.args.get('featured', 'false').lower() == 'true'
        status = request.args.get('status', 'active')
        
        # Build base query
        query = Auction.query
        
        if category_id:
            query = query.filter_by(category_id=category_id)
        if search:
            query = query.filter(Auction.item_name.contains(search) | Auction.description.contains(search))
        if featured_only:
            query = query.filter_by(featured=True)
        if status:
            query = query.filter_by(status=status)
        
        # Update auction status based on end_time (use separate query to avoid modifying main query)
        now = datetime.now(timezone.utc)
        # Check all active auctions and update their status if they've ended
        active_auctions = Auction.query.filter_by(status='active').all()
        for auction in active_auctions:
            # Ensure end_time is timezone-aware for comparison
            end_time = ensure_timezone_aware(auction.end_time)
            if end_time and end_time < now:
                auction.status = 'ended'
                if auction.bids:
                    highest_bid = max(auction.bids, key=lambda b: b.amount)
                    auction.winner_id = highest_bid.user_id
                    auction.current_bid = highest_bid.amount
        db.session.commit()
        
        # Rebuild query with all filters (status may have changed after update)
        query = Auction.query
        
        if category_id:
            query = query.filter_by(category_id=category_id)
        if search:
            query = query.filter(Auction.item_name.contains(search) | Auction.description.contains(search))
        if featured_only:
            query = query.filter_by(featured=True)
        if status:
            query = query.filter_by(status=status)
        
        # Sorting
        if sort_by == 'price':
            query = query.order_by(Auction.current_bid.desc())
        elif sort_by == 'time_left':
            query = query.order_by(Auction.end_time.asc())
        elif sort_by == 'bids':
            # Sort by bid count using subquery
            query = query.outerjoin(Bid).group_by(Auction.id).order_by(func.count(Bid.id).desc())
        else:
            query = query.order_by(Auction.end_time.asc())
        
        pagination = query.paginate(page=page, per_page=per_page, error_out=False)
        
        auctions = []
        for auction in pagination.items:
            # Ensure end_time is timezone-aware for calculation
            end_time = ensure_timezone_aware(auction.end_time)
            time_left = (end_time - now).total_seconds() if end_time else 0
            
            # Count unique bidders (users who have placed bids)
            unique_bidders = set()
            if auction.bids:
                unique_bidders = {bid.user_id for bid in auction.bids}
            
            auctions.append({
                'id': auction.id,
                'item_name': auction.item_name,
                'description': auction.description[:100] + '...' if len(auction.description) > 100 else auction.description,
                'starting_bid': auction.starting_bid,
                'current_bid': auction.current_bid or auction.starting_bid,
                'bid_increment': auction.bid_increment,
                'start_time': ensure_timezone_aware(auction.start_time).isoformat() if auction.start_time else None,
                'end_time': end_time.isoformat() if end_time else None,
                'time_left': max(0, int(time_left)),
                'seller_id': auction.seller_id,
                'seller_name': auction.seller.username,
                'category_id': auction.category_id,
                'category_name': auction.category.name if auction.category else None,
                'status': auction.status,
                'featured': auction.featured,
                'image_url': auction.images[0].url if auction.images else None,
                'bid_count': len(unique_bidders)  # Count unique bidders, not total bids
            })
        
        return jsonify({
            'auctions': auctions,
            'total': pagination.total,
            'page': page,
            'per_page': per_page,
            'pages': pagination.pages
        }), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"Error in get_auctions: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to fetch auctions: {str(e)}'}), 500

@app.route('/api/auctions/<int:auction_id>', methods=['GET'])
def get_auction(auction_id):
    try:
        auction = Auction.query.get_or_404(auction_id)
        now = datetime.now(timezone.utc)
        # Ensure end_time is timezone-aware for comparison
        end_time = ensure_timezone_aware(auction.end_time)
        time_left = (end_time - now).total_seconds() if end_time else 0
        
        # Update status if ended
        if end_time and end_time < now and auction.status == 'active':
            auction.status = 'ended'
            if auction.bids:
                highest_bid = max(auction.bids, key=lambda b: b.amount)
                auction.winner_id = highest_bid.user_id
                auction.current_bid = highest_bid.amount
            db.session.commit()
        
        # Count unique bidders (users who have placed bids)
        unique_bidders = set()
        if auction.bids:
            unique_bidders = {bid.user_id for bid in auction.bids}
        
        return jsonify({
            'id': auction.id,
            'item_name': auction.item_name,
            'description': auction.description,
            'starting_bid': auction.starting_bid,
            'current_bid': auction.current_bid or auction.starting_bid,
            'bid_increment': auction.bid_increment,
            'start_time': ensure_timezone_aware(auction.start_time).isoformat() if auction.start_time else None,
            'end_time': end_time.isoformat() if end_time else None,
            'time_left': max(0, int(time_left)),
            'seller_id': auction.seller_id,
            'seller_name': auction.seller.username,
            'seller_email': auction.seller.email,
            'category_id': auction.category_id,
            'category_name': auction.category.name if auction.category else None,
            'status': auction.status,
            'featured': auction.featured,
            'images': [{'id': img.id, 'url': img.url, 'is_primary': img.is_primary} for img in auction.images],
            'bid_count': len(unique_bidders),  # Count unique bidders, not total bids
            'winner_id': auction.winner_id
        }), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error in get_auction: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to fetch auction: {str(e)}'}), 500

@app.route('/api/auctions', methods=['POST'])
@login_required
def create_auction():
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        
        # Validate required fields
        if not data.get('item_name'):
            return jsonify({'error': 'Item name is required'}), 400
        if not data.get('description'):
            return jsonify({'error': 'Description is required'}), 400
        if not data.get('starting_bid'):
            return jsonify({'error': 'Starting bid is required'}), 400
        if not data.get('end_time'):
            return jsonify({'error': 'End time is required'}), 400
        
        # Validate starting bid
        try:
            starting_bid = float(data['starting_bid'])
            if starting_bid <= 0:
                return jsonify({'error': 'Starting bid must be greater than 0'}), 400
        except (ValueError, TypeError):
            return jsonify({'error': 'Invalid starting bid value'}), 400
        
        # Validate bid increment
        try:
            bid_increment = float(data.get('bid_increment', 1.0))
            if bid_increment <= 0:
                return jsonify({'error': 'Bid increment must be greater than 0'}), 400
        except (ValueError, TypeError):
            return jsonify({'error': 'Invalid bid increment value'}), 400
        
        # Parse end_time with better error handling
        try:
            end_time_str = data['end_time']
            # Handle different datetime formats
            if end_time_str.endswith('Z'):
                end_time_str = end_time_str[:-1] + '+00:00'
            elif 'Z' in end_time_str:
                end_time_str = end_time_str.replace('Z', '+00:00')
            # If no timezone info, check if it's a datetime string and add UTC
            elif '+' not in end_time_str and len(end_time_str) > 10 and end_time_str[10] == 'T':
                # Check if it ends with timezone offset (format: YYYY-MM-DDTHH:MM:SS+HH:MM)
                # If not, assume UTC
                if end_time_str[-6] not in ['+', '-']:
                    end_time_str += '+00:00'
            
            end_time = datetime.fromisoformat(end_time_str)
            # Ensure timezone aware
            if end_time.tzinfo is None:
                end_time = end_time.replace(tzinfo=timezone.utc)
            else:
                end_time = end_time.astimezone(timezone.utc)
        except (ValueError, KeyError) as e:
            return jsonify({'error': f'Invalid end time format. Expected ISO 8601 format (e.g., 2024-12-31T23:59:59Z). Error: {str(e)}'}), 400
        
        # Validate end_time is in the future
        now = datetime.now(timezone.utc)
        if end_time <= now:
            return jsonify({'error': 'End time must be in the future'}), 400
        
        # Validate category exists if provided
        category_id = data.get('category_id')
        if category_id:
            try:
                category_id = int(category_id)
                category = Category.query.get(category_id)
                if not category:
                    return jsonify({'error': 'Category not found'}), 404
            except (ValueError, TypeError):
                return jsonify({'error': 'Invalid category ID'}), 400
        
        # Create auction
        auction = Auction(
            item_name=data['item_name'],
            description=data['description'],
            starting_bid=starting_bid,
            bid_increment=bid_increment,
            end_time=end_time,
            seller_id=session['user_id'],
            category_id=category_id,
            featured=bool(data.get('featured', False)),
            current_bid=starting_bid
        )
        db.session.add(auction)
        db.session.flush()
        
        # Add images
        images = data.get('images', [])
        if images:
            for idx, img_url in enumerate(images):
                if img_url:  # Only add non-empty image URLs
                    image = Image(
                        auction_id=auction.id,
                        url=str(img_url),
                        is_primary=(idx == 0)  # First image is primary
                    )
                    db.session.add(image)
        
        db.session.commit()
        return jsonify({'message': 'Auction created', 'id': auction.id}), 201
    
    except Exception as e:
        db.session.rollback()
        print(f"Error creating auction: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to create auction: {str(e)}'}), 500

@app.route('/api/auctions/<int:auction_id>', methods=['PUT'])
@login_required
def update_auction(auction_id):
    try:
        auction = Auction.query.get_or_404(auction_id)
        if auction.seller_id != session['user_id']:
            return jsonify({'error': 'Not authorized'}), 403
        
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        
        # Validate and update fields
        if 'item_name' in data:
            if not data['item_name']:
                return jsonify({'error': 'Item name cannot be empty'}), 400
            auction.item_name = data['item_name']
        
        if 'description' in data:
            auction.description = data['description']
        
        if 'category_id' in data:
            if data['category_id']:
                category = Category.query.get(data['category_id'])
                if not category:
                    return jsonify({'error': 'Category not found'}), 404
                auction.category_id = data['category_id']
            else:
                auction.category_id = None
        
        if 'featured' in data:
            auction.featured = bool(data['featured'])
        
        db.session.commit()
        return jsonify({'message': 'Auction updated'}), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"Error updating auction: {str(e)}")
        return jsonify({'error': f'Failed to update auction: {str(e)}'}), 500

# Bidding APIs
@app.route('/api/auctions/<int:auction_id>/bids', methods=['GET'])
def get_bids(auction_id):
    try:
        auction = Auction.query.get_or_404(auction_id)
        bids = Bid.query.filter_by(auction_id=auction_id).order_by(Bid.amount.desc(), Bid.timestamp.desc()).limit(50).all()
        
        # Find the highest bid amount
        highest_bid_amount = max([bid.amount for bid in bids]) if bids else 0
        current_bid = auction.current_bid or auction.starting_bid
        
        return jsonify([{
            'id': bid.id,
            'user_id': bid.user_id,
            'username': bid.bidder.username,
            'amount': bid.amount,
            'timestamp': bid.timestamp.isoformat(),
            'is_auto_bid': bid.is_auto_bid,
            'is_winning': bid.amount == highest_bid_amount and bid.amount == current_bid and auction.status == 'active',
            'is_highest': bid.amount == highest_bid_amount
        } for bid in bids]), 200
    except Exception as e:
        print(f"Error in get_bids: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to get bids: {str(e)}'}), 500

@app.route('/api/auctions/<int:auction_id>/bids', methods=['POST'])
@login_required
def place_bid(auction_id):
    try:
        auction = Auction.query.get_or_404(auction_id)
        
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        user_id = session['user_id']
        
        if auction.status != 'active':
            return jsonify({'error': 'Auction is not active'}), 400
        
        now = datetime.now(timezone.utc)
        # Ensure end_time is timezone-aware for comparison
        end_time = ensure_timezone_aware(auction.end_time)
        if end_time and end_time < now:
            auction.status = 'ended'
            db.session.commit()
            return jsonify({'error': 'Auction has ended'}), 400
        
        if auction.seller_id == user_id:
            return jsonify({'error': 'Cannot bid on your own auction'}), 400
        
        # Validate bid amount
        if 'amount' not in data:
            return jsonify({'error': 'Bid amount is required'}), 400
        
        try:
            bid_amount = float(data['amount'])
            if bid_amount <= 0:
                return jsonify({'error': 'Bid amount must be greater than 0'}), 400
        except (ValueError, TypeError):
            return jsonify({'error': 'Invalid bid amount'}), 400
        
        min_bid = (auction.current_bid or auction.starting_bid) + auction.bid_increment
        
        if bid_amount < min_bid:
            return jsonify({'error': f'Bid must be at least ${min_bid:.2f}'}), 400
        
        # Check auto-bid logic
        auto_bid_amount = data.get('auto_bid_amount')
        if auto_bid_amount:
            try:
                auto_bid_amount = float(auto_bid_amount)
                if auto_bid_amount < bid_amount:
                    return jsonify({'error': 'Auto-bid limit must be higher than initial bid'}), 400
                if auto_bid_amount <= 0:
                    return jsonify({'error': 'Auto-bid limit must be greater than 0'}), 400
            except (ValueError, TypeError):
                return jsonify({'error': 'Invalid auto-bid amount'}), 400
        
        bid = Bid(
            auction_id=auction_id,
            user_id=user_id,
            amount=bid_amount,
            is_auto_bid=bool(auto_bid_amount),
            max_auto_bid=auto_bid_amount if auto_bid_amount else None
        )
        db.session.add(bid)
        
        auction.current_bid = bid_amount
        
        # Check for auto-bids from other users
        other_auto_bids = Bid.query.filter(
            Bid.auction_id == auction_id,
            Bid.user_id != user_id,
            Bid.is_auto_bid == True,
            Bid.max_auto_bid >= bid_amount + auction.bid_increment
        ).all()
        
        for auto_bid in other_auto_bids:
            new_amount = min(bid_amount + auction.bid_increment, auto_bid.max_auto_bid)
            if new_amount > auction.current_bid:
                counter_bid = Bid(
                    auction_id=auction_id,
                    user_id=auto_bid.user_id,
                    amount=new_amount,
                    is_auto_bid=True,
                    max_auto_bid=auto_bid.max_auto_bid
                )
                db.session.add(counter_bid)
                auction.current_bid = new_amount
                bid_amount = new_amount
        
        db.session.commit()
        return jsonify({
            'message': 'Bid placed successfully',
            'current_bid': auction.current_bid,
            'bid_id': bid.id
        }), 201
    
    except Exception as e:
        db.session.rollback()
        print(f"Error placing bid: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to place bid: {str(e)}'}), 500

@app.route('/api/user/bids', methods=['GET'])
@login_required
def get_user_bids():
    bids = Bid.query.filter_by(user_id=session['user_id']).order_by(Bid.timestamp.desc()).all()
    
    result = []
    for bid in bids:
        auction = bid.auction
        if not auction:
            continue
            
        # Get all bids for this auction
        all_bids = auction.bids if auction.bids else []
        highest_bid_amount = max([b.amount for b in all_bids]) if all_bids else 0
        current_bid = auction.current_bid or auction.starting_bid
        
        # Get user's bids for this auction
        user_bids = [b for b in all_bids if b.user_id == session['user_id']]
        user_highest_bid = max([b.amount for b in user_bids]) if user_bids else 0
        
        # Find the highest bidder (user with highest bid)
        highest_bidder_id = None
        if all_bids:
            highest_bid = max(all_bids, key=lambda b: b.amount)
            highest_bidder_id = highest_bid.user_id
        
        # Determine if user is winning or won
        if auction.status == 'active':
            # For active auctions, check if user is the current highest bidder
            # The winning bid is the one that matches the auction's current_bid
            # Check if this bid amount equals the current_bid (within small tolerance for floating point)
            bid_matches_current = abs(bid.amount - current_bid) <= 0.01
            
            # Also check if user is the highest bidder (their highest bid equals the highest bid)
            user_is_highest_bidder = (
                highest_bidder_id == session['user_id'] and 
                abs(user_highest_bid - highest_bid_amount) <= 0.01
            )
            
            # Mark as winning if:
            # 1. This bid matches the current_bid (user is winning with this bid), OR
            # 2. User is the highest bidder and this is their highest bid
            is_winning = bid_matches_current or (user_is_highest_bidder and abs(bid.amount - user_highest_bid) <= 0.01)
            is_winner = False
        elif auction.status == 'ended':
            # For ended auctions, check if user is the winner
            is_winning = False
            is_winner = auction.winner_id == session['user_id']
        else:
            # For cancelled or other statuses
            is_winning = False
            is_winner = False
        
        result.append({
            'id': bid.id,
            'auction_id': bid.auction_id,
            'auction_name': auction.item_name,
            'amount': bid.amount,
            'timestamp': bid.timestamp.isoformat(),
            'is_auto_bid': bid.is_auto_bid,
            'is_winning': is_winning,
            'is_winner': is_winner,  # True when auction ended and user won
            'auction_status': auction.status,
            'current_bid': current_bid,
            'winner_id': auction.winner_id
        })
    
    return jsonify(result), 200

@app.route('/api/user/auctions', methods=['GET'])
@login_required
def get_user_auctions():
    auctions = Auction.query.filter_by(seller_id=session['user_id']).all()
    result = []
    for auction in auctions:
        # Count unique bidders (users who have placed bids)
        unique_bidders = set()
        if auction.bids:
            unique_bidders = {bid.user_id for bid in auction.bids}
        
        result.append({
            'id': auction.id,
            'item_name': auction.item_name,
            'current_bid': auction.current_bid or auction.starting_bid,
            'status': auction.status,
            'end_time': auction.end_time.isoformat(),
            'bid_count': len(unique_bidders)  # Count unique bidders, not total bids
        })
    return jsonify(result), 200

@app.route('/api/featured', methods=['GET'])
def get_featured():
    try:
        auctions = Auction.query.filter_by(featured=True, status='active').limit(5).all()
        now = datetime.now(timezone.utc)
        featured_list = []
        for auction in auctions:
            # Ensure end_time is timezone-aware for calculation
            end_time = ensure_timezone_aware(auction.end_time)
            time_left = (end_time - now).total_seconds() if end_time else 0
            featured_list.append({
                'id': auction.id,
                'item_name': auction.item_name,
                'current_bid': auction.current_bid or auction.starting_bid,
                'time_left': max(0, int(time_left)),
                'image_url': auction.images[0].url if auction.images else None
            })
        return jsonify(featured_list), 200
    except Exception as e:
        print(f"Error in get_featured: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to fetch featured auctions: {str(e)}'}), 500

# Test endpoint to verify server is running
@app.route('/api/test', methods=['GET'])
def test_endpoint():
    return jsonify({'message': 'Backend server is running!', 'status': 'ok'}), 200

# Admin APIs
@app.route('/api/admin/users', methods=['GET'])
@admin_required
def get_all_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    search = request.args.get('search', '')
    
    query = User.query
    
    if search:
        query = query.filter(
            (User.username.contains(search)) |
            (User.email.contains(search))
        )
    
    pagination = query.order_by(User.created_at.desc()).paginate(page=page, per_page=per_page, error_out=False)
    
    # Build user list with biometric verification status
    users_list = []
    for user in pagination.items:
        has_biometric = False
        biometric_type = None
        
        if user.biometric_data:
            try:
                biometric_json = json.loads(user.biometric_data)
                has_biometric = True
                biometric_type = biometric_json.get('type', 'unknown')
            except (json.JSONDecodeError, TypeError):
                has_biometric = True  # Legacy format
                biometric_type = 'legacy'
        
        users_list.append({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role,
            'created_at': user.created_at.isoformat(),
            'auction_count': len(user.auctions),
            'bid_count': len(user.bids),
            'has_biometric': has_biometric,
            'biometric_type': biometric_type
        })
    
    return jsonify({
        'users': users_list,
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages
    }), 200

@app.route('/api/admin/users/<int:user_id>', methods=['PUT'])
@admin_required
def update_user(user_id):
    data = request.json
    user = User.query.get_or_404(user_id)
    
    if 'role' in data:
        user.role = data['role']
    if 'email' in data:
        user.email = data['email']
    
    db.session.commit()
    return jsonify({'message': 'User updated successfully'}), 200

@app.route('/api/admin/users/<int:user_id>', methods=['GET'])
@admin_required
def get_user_details(user_id):
    """Get detailed user information including biometric data"""
    user = User.query.get_or_404(user_id)
    
    # Parse biometric data if it exists
    biometric_info = None
    if user.biometric_data:
        try:
            biometric_json = json.loads(user.biometric_data)
            biometric_info = {
                'has_biometric': True,
                'type': biometric_json.get('type', 'unknown'),
                'has_id_front': 'id_card_front_image' in biometric_json or 'id_card_image' in biometric_json,
                'has_id_back': 'id_card_back_image' in biometric_json,
                'has_selfie': 'selfie_image' in biometric_json,
                'timestamp': biometric_json.get('timestamp'),
                'device': biometric_json.get('device'),
                # Include images for display
                'id_card_front_image': biometric_json.get('id_card_front_image') or biometric_json.get('id_card_image'),
                'id_card_back_image': biometric_json.get('id_card_back_image'),
                'selfie_image': biometric_json.get('selfie_image')
            }
        except (json.JSONDecodeError, TypeError):
            # If it's not JSON, it might be old format (hashed)
            biometric_info = {
                'has_biometric': True,
                'type': 'legacy',
                'data_length': len(user.biometric_data) if user.biometric_data else 0
            }
    
    return jsonify({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'id_number': user.id_number,
        'birth_date': user.birth_date.isoformat() if user.birth_date else None,
        'address': user.address,
        'phone': user.phone,
        'role': user.role,
        'created_at': user.created_at.isoformat(),
        'auction_count': len(user.auctions),
        'bid_count': len(user.bids),
        'biometric_data': biometric_info
    }), 200

@app.route('/api/admin/users/<int:user_id>', methods=['DELETE'])
@admin_required
def delete_user(user_id):
    user = User.query.get_or_404(user_id)
    db.session.delete(user)
    db.session.commit()
    return jsonify({'message': 'User deleted successfully'}), 200

@app.route('/api/admin/auctions', methods=['GET'])
@admin_required
def get_all_auctions_admin():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    status = request.args.get('status', '')
    
    query = Auction.query
    
    if status:
        query = query.filter_by(status=status)
    
    pagination = query.order_by(Auction.start_time.desc()).paginate(page=page, per_page=per_page, error_out=False)
    
    # Build auction list with unique bidder counts
    auctions_list = []
    for auction in pagination.items:
        # Count unique bidders (users who have placed bids)
        unique_bidders = set()
        if auction.bids:
            unique_bidders = {bid.user_id for bid in auction.bids}
        
        auctions_list.append({
            'id': auction.id,
            'item_name': auction.item_name,
            'seller': auction.seller.username,
            'current_bid': auction.current_bid,
            'status': auction.status,
            'end_time': auction.end_time.isoformat(),
            'bid_count': len(unique_bidders),  # Count unique bidders, not total bids
            'featured': auction.featured
        })
    
    return jsonify({
        'auctions': auctions_list,
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages
    }), 200

@app.route('/api/admin/auctions/<int:auction_id>', methods=['PUT'])
@admin_required
def update_auction_admin(auction_id):
    data = request.json
    auction = Auction.query.get_or_404(auction_id)
    
    if 'status' in data:
        auction.status = data['status']
    if 'featured' in data:
        auction.featured = data['featured']
    
    db.session.commit()
    return jsonify({'message': 'Auction updated successfully'}), 200

@app.route('/api/admin/auctions/<int:auction_id>', methods=['DELETE'])
@admin_required
def delete_auction_admin(auction_id):
    try:
        auction = Auction.query.get_or_404(auction_id)
        
        # Delete all related bids first (cascade should handle this, but explicit deletion ensures it works)
        Bid.query.filter_by(auction_id=auction_id).delete()
        
        # Delete the auction
        db.session.delete(auction)
        db.session.commit()
        return jsonify({'message': 'Auction deleted successfully'}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to delete auction: {str(e)}'}), 500

@app.route('/api/admin/stats', methods=['GET'])
@admin_required
def get_admin_stats():
    total_users = User.query.count()
    total_admins = User.query.filter_by(role='admin').count()
    total_auctions = Auction.query.count()
    active_auctions = Auction.query.filter_by(status='active').count()
    ended_auctions = Auction.query.filter_by(status='ended').count()
    total_bids = Bid.query.count()
    
    week_ago = datetime.now(timezone.utc) - timedelta(days=7)
    recent_users = User.query.filter(User.created_at >= week_ago).count()
    
    return jsonify({
        'total_users': total_users,
        'total_admins': total_admins,
        'total_auctions': total_auctions,
        'active_auctions': active_auctions,
        'ended_auctions': ended_auctions,
        'total_bids': total_bids,
        'recent_users': recent_users
    }), 200

@app.route('/api/admin/categories', methods=['POST'])
@admin_required
def create_category_admin():
    data = request.json
    if Category.query.filter_by(name=data['name']).first():
        return jsonify({'error': 'Category already exists'}), 400
    
    category = Category(name=data['name'], description=data.get('description', ''))
    db.session.add(category)
    db.session.commit()
    return jsonify({'message': 'Category created', 'id': category.id}), 201

@app.route('/api/admin/categories/<int:category_id>', methods=['PUT'])
@admin_required
def update_category_admin(category_id):
    data = request.json
    category = Category.query.get_or_404(category_id)
    
    if 'name' in data:
        category.name = data['name']
    if 'description' in data:
        category.description = data['description']
    
    db.session.commit()
    return jsonify({'message': 'Category updated successfully'}), 200

@app.route('/api/admin/categories/<int:category_id>', methods=['DELETE'])
@admin_required
def delete_category_admin(category_id):
    category = Category.query.get_or_404(category_id)
    db.session.delete(category)
    db.session.commit()
    return jsonify({'message': 'Category deleted successfully'}), 200

# Initialize database
def init_db():
    with app.app_context():
        db.create_all()
        # Create default categories
        if Category.query.count() == 0:
            categories = [
                Category(name='Electronics', description='Electronic devices and gadgets'),
                Category(name='Art & Collectibles', description='Artwork and collectible items'),
                Category(name='Jewelry', description='Precious jewelry and watches'),
                Category(name='Vehicles', description='Cars, motorcycles, and other vehicles'),
                Category(name='Real Estate', description='Properties and land'),
                Category(name='Fashion', description='Clothing and accessories'),
                Category(name='Sports', description='Sports equipment and memorabilia'),
                Category(name='Other', description='Other miscellaneous items')
            ]
            for cat in categories:
                db.session.add(cat)
            db.session.commit()
        
        # Create default admin user if doesn't exist
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                email='admin@zubid.com',
                password_hash=generate_password_hash('admin123'),
                id_number='ADMIN001',
                birth_date=date(1990, 1, 1),  # Default birth date for admin
                biometric_data=generate_password_hash('admin_biometric_default'),
                role='admin'
            )
            db.session.add(admin)
            db.session.commit()
            # Security: Don't log credentials in production
            if os.getenv('FLASK_ENV') != 'production':
                print("Default admin user created: username='admin', password='admin123'")
            else:
                print("Default admin user created. Please change the default password immediately.")
        
        # Create sample auctions if none exist
        if Auction.query.count() == 0 and admin:
            # Get categories for sample auctions
            electronics_cat = Category.query.filter_by(name='Electronics').first()
            jewelry_cat = Category.query.filter_by(name='Jewelry').first()
            vehicles_cat = Category.query.filter_by(name='Vehicles').first()
            art_cat = Category.query.filter_by(name='Art & Collectibles').first()
            
            # Sample auction 1: Vintage Rolex Watch
            if jewelry_cat:
                auction1 = Auction(
                    item_name='Vintage Rolex Submariner 1969',
                    description='Authentic vintage Rolex Submariner from 1969. Excellent condition with original box and papers. Rare collector\'s item.',
                    starting_bid=15000.00,
                    current_bid=15000.00,
                    bid_increment=500.00,
                    end_time=datetime.now(timezone.utc) + timedelta(days=7),
                    seller_id=admin.id,
                    category_id=jewelry_cat.id,
                    status='active',
                    featured=True
                )
                db.session.add(auction1)
                db.session.flush()
                db.session.add(Image(auction_id=auction1.id, url='https://images.unsplash.com/photo-1523275335684-37898b6baf30', is_primary=True))
            
            # Sample auction 2: Tesla Model S
            if vehicles_cat:
                auction2 = Auction(
                    item_name='2019 Tesla Model S Performance',
                    description='2019 Tesla Model S Performance in perfect condition. All-wheel drive, Ludicrous Mode enabled. Only 15,000 miles. Fully serviced and certified.',
                    starting_bid=45000.00,
                    current_bid=45000.00,
                    bid_increment=1000.00,
                    end_time=datetime.now(timezone.utc) + timedelta(days=5),
                    seller_id=admin.id,
                    category_id=vehicles_cat.id,
                    status='active',
                    featured=True
                )
                db.session.add(auction2)
                db.session.flush()
                db.session.add(Image(auction_id=auction2.id, url='https://images.unsplash.com/photo-1617788138017-80ad40651399', is_primary=True))
            
            # Sample auction 3: Rare Collectible Art
            if art_cat:
                auction3 = Auction(
                    item_name='Original Banksy Limited Edition Print',
                    description='Authentic Banksy screen print, "Girl with Balloon" - limited edition of 600. Includes certificate of authenticity from Pest Control.',
                    starting_bid=25000.00,
                    current_bid=25000.00,
                    bid_increment=1000.00,
                    end_time=datetime.now(timezone.utc) + timedelta(days=10),
                    seller_id=admin.id,
                    category_id=art_cat.id,
                    status='active',
                    featured=True
                )
                db.session.add(auction3)
                db.session.flush()
                db.session.add(Image(auction_id=auction3.id, url='https://images.unsplash.com/photo-1541961017774-22349e4a1262', is_primary=True))
            
            # Sample auction 4: MacBook Pro
            if electronics_cat:
                auction4 = Auction(
                    item_name='MacBook Pro 16" M1 Max 2021',
                    description='Brand new MacBook Pro 16-inch with M1 Max chip, 32GB RAM, 1TB SSD. Sealed in original box with Apple warranty.',
                    starting_bid=2500.00,
                    current_bid=2500.00,
                    bid_increment=50.00,
                    end_time=datetime.now(timezone.utc) + timedelta(days=3),
                    seller_id=admin.id,
                    category_id=electronics_cat.id,
                    status='active',
                    featured=False
                )
                db.session.add(auction4)
                db.session.flush()
                db.session.add(Image(auction_id=auction4.id, url='https://images.unsplash.com/photo-1541807084-5c52b6b3adef', is_primary=True))
            
            # Sample auction 5: Vintage Guitar
            if electronics_cat:
                auction5 = Auction(
                    item_name='1960s Fender Stratocaster',
                    description='Original 1960s Fender Stratocaster electric guitar. Sunburst finish. All original hardware and pickups. Excellent playing condition.',
                    starting_bid=8000.00,
                    current_bid=8000.00,
                    bid_increment=200.00,
                    end_time=datetime.now(timezone.utc) + timedelta(days=6),
                    seller_id=admin.id,
                    category_id=electronics_cat.id,
                    status='active',
                    featured=False
                )
                db.session.add(auction5)
                db.session.flush()
                db.session.add(Image(auction_id=auction5.id, url='https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f', is_primary=True))
            
            db.session.commit()
            print("Sample auctions created successfully!")
        
        print("Database initialized successfully!")

if __name__ == '__main__':
    init_db()
    
    # Configuration from environment variables
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    port = int(os.getenv('PORT', '5000'))
    host = os.getenv('HOST', '127.0.0.1')
    
    print("\n" + "="*50)
    print("ZUBID Backend Server Starting...")
    print("="*50)
    print(f"Server will run on: http://{host}:{port}")
    print(f"API Test: http://{host}:{port}/api/test")
    print(f"Debug mode: {'ON' if debug_mode else 'OFF'}")
    print(f"Environment: {os.getenv('FLASK_ENV', 'development')}")
    print("="*50 + "\n")
    
    try:
        app.run(debug=debug_mode, port=port, host=host)
    except Exception as e:
        print(f"\n[ERROR] Failed to start server: {e}")
        print("\nPossible issues:")
        print("1. Port 5000 is already in use")
        print("2. Firewall blocking the port")
        print("3. Another Flask app is running")
        print("\nSolutions:")
        print("- Close other programs using port 5000")
        print("- Or change the port number in app.py")
        raise

