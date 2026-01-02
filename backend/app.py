from flask import Flask, request, jsonify, session, abort, send_from_directory, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_wtf.csrf import CSRFProtect, generate_csrf
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_migrate import Migrate
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from werkzeug.exceptions import HTTPException
from datetime import datetime, timedelta, date, timezone
from functools import wraps, lru_cache
from sqlalchemy import func, text, Index
from sqlalchemy.orm import joinedload, selectinload
import os
import json
import logging
from logging.handlers import RotatingFileHandler
from PIL import Image as PILImage
import qrcode
import html
import re

# Import image storage service
import image_storage

# Load environment variables
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    # python-dotenv not installed, continue without it
    pass

# Get frontend directory path for serving static files
frontend_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'frontend')

app = Flask(__name__, static_folder=frontend_dir, static_url_path='')

# Configuration from environment variables with fallbacks for development
# SECURITY: Require SECRET_KEY in production, fail if not set
secret_key = os.getenv('SECRET_KEY')
is_production = os.getenv('FLASK_ENV', '').lower() == 'production'

if not secret_key:
    if is_production:
        raise ValueError(
            "SECRET_KEY environment variable is required in production! "
            "Generate one with: python -c \"import secrets; print(secrets.token_hex(32))\""
        )
    else:
        # Development fallback with warning
        secret_key = 'your-secret-key-change-in-production'
        import warnings
        warnings.warn(
            "Using default SECRET_KEY. This is insecure for production! "
            "Set SECRET_KEY environment variable.",
            UserWarning
        )

app.config['SECRET_KEY'] = secret_key

# Database configuration - convert postgresql:// to postgresql+psycopg:// for psycopg3
database_uri = os.getenv('DATABASE_URI', 'sqlite:///auction.db')
if database_uri.startswith('postgresql://'):
    database_uri = database_uri.replace('postgresql://', 'postgresql+psycopg://', 1)
elif database_uri.startswith('postgres://'):
    database_uri = database_uri.replace('postgres://', 'postgresql+psycopg://', 1)

app.config['SQLALCHEMY_DATABASE_URI'] = database_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Session configuration for proper cookie handling
https_enabled = os.getenv('HTTPS_ENABLED', 'false').lower() == 'true'
# Auto-detect HTTPS if running on production domains
hostname = os.getenv('RENDER_EXTERNAL_HOSTNAME', '')
if not https_enabled and ('onrender.com' in hostname or 'duckdns.org' in hostname):
    https_enabled = True

app.config['SESSION_COOKIE_NAME'] = 'zubid_session'  # Explicit session cookie name
app.config['SESSION_COOKIE_SECURE'] = https_enabled
app.config['SESSION_COOKIE_HTTPONLY'] = True
# Use 'Lax' for same-origin requests (frontend served from Flask on port 5000)
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['PERMANENT_SESSION_LIFETIME'] = 86400  # 24 hours
# Database connection pooling (only for non-SQLite databases)
# For serverless environments like Render.com, use NullPool to avoid connection limits
if 'sqlite' not in app.config['SQLALCHEMY_DATABASE_URI'].lower():
    from sqlalchemy.pool import NullPool, QueuePool

    # Check if we should use NullPool (recommended for Render.com free tier)
    use_nullpool = os.getenv('DB_USE_NULLPOOL', 'true').lower() == 'true'

    if use_nullpool:
        # NullPool: Opens a new connection for each request, closes immediately after
        # Best for serverless/free tier with limited connections
        app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
            'poolclass': NullPool,
            'pool_pre_ping': True,  # Verify connections before using
        }
        print("[DB] Using NullPool - no connection pooling (best for Render.com free tier)")
    else:
        # QueuePool: Traditional connection pooling with conservative settings
        app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
            'poolclass': QueuePool,
            'pool_pre_ping': True,
            'pool_recycle': int(os.getenv('DB_POOL_RECYCLE', '1800')),  # 30 minutes
            'pool_size': int(os.getenv('DB_POOL_SIZE', '3')),           # Small pool
            'max_overflow': int(os.getenv('DB_MAX_OVERFLOW', '5')),     # Limited overflow
            'pool_timeout': int(os.getenv('DB_POOL_TIMEOUT', '30')),    # 30 second timeout
        }
        print(f"[DB] Using QueuePool - pool_size={os.getenv('DB_POOL_SIZE', '3')}, max_overflow={os.getenv('DB_MAX_OVERFLOW', '5')}")
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max request size

# CSRF Protection Configuration
# SECURITY: Enable CSRF in production by default, allow override via env
csrf_enabled_env = os.getenv('CSRF_ENABLED', '').lower()
if csrf_enabled_env:
    # Explicitly set via environment variable
    app.config['WTF_CSRF_ENABLED'] = csrf_enabled_env == 'true'
else:
    # Default: enable in production, disable in development
    app.config['WTF_CSRF_ENABLED'] = is_production

if is_production and not app.config['WTF_CSRF_ENABLED']:
    import warnings
    warnings.warn(
        "CSRF protection is disabled in production. This is a security risk! "
        "Set CSRF_ENABLED=true in your environment variables.",
        UserWarning
    )

app.config['WTF_CSRF_TIME_LIMIT'] = None  # No time limit for API tokens

db = SQLAlchemy(app)

# Initialize Flask-Migrate for database migrations
migrate = Migrate(app, db)

# =============================================================================
# CRITICAL: Run database migrations BEFORE models are used
# This fixes "column does not exist" errors on production
# =============================================================================
def run_pre_model_migrations():
    """Run critical migrations before any ORM operations"""
    try:
        with app.app_context():
            # Check if we're using PostgreSQL
            db_url = str(db.engine.url)
            if 'postgresql' not in db_url and 'postgres' not in db_url:
                return  # Skip for SQLite

            with db.engine.connect() as conn:
                # Check if category table exists
                result = conn.execute(text(
                    "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'category')"
                ))
                table_exists = result.scalar()

                if not table_exists:
                    print("[MIGRATION] Category table doesn't exist yet, skipping pre-migration")
                    return

                # Check and add missing columns to category table
                migrations = [
                    ("parent_id", "ALTER TABLE category ADD COLUMN IF NOT EXISTS parent_id INTEGER"),
                    ("icon_url", "ALTER TABLE category ADD COLUMN IF NOT EXISTS icon_url VARCHAR(500)"),
                    ("image_url", "ALTER TABLE category ADD COLUMN IF NOT EXISTS image_url VARCHAR(500)"),
                    ("is_active", "ALTER TABLE category ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE"),
                    ("sort_order", "ALTER TABLE category ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0"),
                    ("created_at", "ALTER TABLE category ADD COLUMN IF NOT EXISTS created_at TIMESTAMP"),
                    ("updated_at", "ALTER TABLE category ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP"),
                ]

                for col_name, sql in migrations:
                    try:
                        conn.execute(text(sql))
                        conn.commit()
                    except Exception as e:
                        if "already exists" not in str(e).lower():
                            print(f"[MIGRATION] Note: {col_name}: {e}")

                # Set defaults for NULL values
                try:
                    conn.execute(text("UPDATE category SET is_active = TRUE WHERE is_active IS NULL"))
                    conn.execute(text("UPDATE category SET sort_order = id WHERE sort_order IS NULL"))
                    conn.commit()
                except:
                    pass

                print("[MIGRATION] Category table columns verified/updated")
    except Exception as e:
        print(f"[MIGRATION] Pre-model migration note: {e}")

# Run migrations immediately
run_pre_model_migrations()

# Initialize CSRF Protection (optional, can be enabled for specific endpoints)
# Only initialize if CSRF is enabled, otherwise create a mock object
csrf_enabled = os.getenv('CSRF_ENABLED', 'false').lower() == 'true'
if csrf_enabled:
    csrf = CSRFProtect(app)
else:
    # Create a mock CSRF object that allows exempt decorator but does nothing
    class MockCSRF:
        def exempt(self, f):
            return f
    csrf = MockCSRF()

# Initialize Rate Limiter
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["1000 per day", "200 per hour"],
    storage_uri=os.getenv('RATELIMIT_STORAGE_URL', 'memory://'),  # Use Redis in production
    enabled=os.getenv('RATE_LIMIT_ENABLED', 'true').lower() == 'true'
)

# CORS configuration - restrict origins in production
cors_origins = os.getenv('CORS_ORIGINS', '*')
if cors_origins == '*':
    # Development/default mode - allow all origins for API access (mobile apps, web)
    # For APIs that need to be accessed from mobile apps, we use permissive CORS
    CORS(app,
         supports_credentials=True,  # Allow credentials even with * (modern browsers require specific origin for this though)
         origins="*",  # Allow any origin (required for mobile apps)
         allow_headers=['Content-Type', 'X-CSRFToken', 'Authorization'],
         expose_headers=['Set-Cookie'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'])
else:
    # Production mode with specific origins - restrict to specific origins
    allowed_origins = [origin.strip() for origin in cors_origins.split(',')]
    CORS(app,
         supports_credentials=True,
         origins=allowed_origins,
         allow_headers=['Content-Type', 'X-CSRFToken', 'Authorization'],
         expose_headers=['Set-Cookie'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'])

# Session cleanup to prevent connection leaks
@app.teardown_appcontext
def shutdown_session(exception=None):
    """Ensure database sessions are properly cleaned up after each request.

    This prevents connection leaks by returning connections to the pool.
    Critical for avoiding 'QueuePool limit reached' errors.
    """
    try:
        if exception:
            db.session.rollback()
        # Force close any remaining connections
        db.session.close()
        db.session.remove()
    except Exception as e:
        # Log cleanup errors for debugging
        try:
            app.logger.warning(f"Session cleanup error: {e}")
        except:
            pass  # Ignore logging errors during cleanup


# Additional cleanup for request teardown
@app.teardown_request
def teardown_request(exception=None):
    """Additional request cleanup to ensure no lingering sessions"""
    try:
        if exception:
            db.session.rollback()
        db.session.close()
    except Exception:
        pass


# Security Headers Middleware
@app.after_request
def add_security_headers(response):
    """Add comprehensive security headers to all responses"""
    # Prevent clickjacking
    response.headers['X-Frame-Options'] = 'DENY'
    # Prevent MIME type sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
    # Enable XSS protection
    response.headers['X-XSS-Protection'] = '1; mode=block'
    # Strict Transport Security (HTTPS only)
    if request.is_secure:
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    # Content Security Policy - Updated for Google Fonts, YouTube, and external resources
    response.headers['Content-Security-Policy'] = (
        "default-src 'self'; "
        "script-src 'self' 'unsafe-inline' 'unsafe-eval' blob:; "
        "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; "
        "img-src 'self' data: blob: https: http:; "
        "font-src 'self' https://fonts.gstatic.com https://fonts.googleapis.com https:; "
        "connect-src 'self' https: wss:; "
        "frame-src 'self' https://www.youtube.com https://youtube.com https://www.youtube-nocookie.com https://player.vimeo.com; "
        "media-src 'self' https: blob: data:; "
        "frame-ancestors 'self';"
    )
    # Referrer Policy
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    # Permissions Policy
    response.headers['Permissions-Policy'] = (
        "geolocation=(), microphone=(), camera=(), "
        "payment=(), usb=(), magnetometer=(), gyroscope=()"
    )
    return response

# Input Validation and Sanitization Helpers
def sanitize_string(value, max_length=None, allow_html=False):
    """
    Sanitize string input to prevent XSS attacks
    
    Args:
        value: String to sanitize
        max_length: Maximum allowed length (None = no limit)
        allow_html: If True, allow HTML (not recommended for user input)
    
    Returns:
        Sanitized string
    """
    if not isinstance(value, str):
        return str(value) if value is not None else ''
    
    # Strip whitespace
    value = value.strip()
    
    # Encode HTML entities to prevent XSS (unless HTML is explicitly allowed)
    if not allow_html:
        value = html.escape(value)
    
    # Enforce max length
    if max_length and len(value) > max_length:
        value = value[:max_length]
    
    return value

def validate_email(email):
    """Validate email format"""
    if not email or not isinstance(email, str):
        return False
    # Basic email regex
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email.strip()))

def validate_phone(phone):
    """Validate phone number format"""
    if not phone or not isinstance(phone, str):
        return False
    # Remove common separators and spaces
    cleaned = re.sub(r'[\s\-\(\)]', '', phone)
    # Allow international format with + prefix
    if cleaned.startswith('+'):
        cleaned = cleaned[1:]  # Remove the + sign
    # Check if it's all digits and reasonable length (8-20 digits)
    return cleaned.isdigit() and 8 <= len(cleaned) <= 20

def sanitize_filename(filename):
    """Sanitize filename to prevent path traversal"""
    # Use werkzeug's secure_filename
    safe = secure_filename(filename)
    # Additional check: remove any remaining path separators
    safe = safe.replace('/', '').replace('\\', '')
    return safe

# ==========================================
# EMAIL & SMS SENDING FUNCTIONS
# ==========================================

def send_email(to_email, subject, body):
    """
    Send email using SMTP
    Requires environment variables:
    - SMTP_HOST: SMTP server hostname
    - SMTP_PORT: SMTP server port (usually 587 for TLS)
    - SMTP_USER: SMTP username/email
    - SMTP_PASSWORD: SMTP password
    - SMTP_FROM: From email address
    """
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    smtp_host = os.getenv('SMTP_HOST')
    smtp_port = int(os.getenv('SMTP_PORT', '587'))
    smtp_user = os.getenv('SMTP_USER')
    smtp_password = os.getenv('SMTP_PASSWORD')
    smtp_from = os.getenv('SMTP_FROM', smtp_user)

    if not all([smtp_host, smtp_user, smtp_password]):
        app.logger.warning("SMTP not configured. Email not sent.")
        return False

    try:
        # Create message
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = f"ZUBID Auction <{smtp_from}>"
        msg['To'] = to_email

        # Plain text version
        text_part = MIMEText(body, 'plain')

        # HTML version
        html_body = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #f97316, #ea580c); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
                .content {{ background: #f8fafc; padding: 30px; border-radius: 0 0 8px 8px; }}
                .code {{ font-size: 32px; font-weight: bold; color: #f97316; letter-spacing: 8px; text-align: center; padding: 20px; background: white; border-radius: 8px; margin: 20px 0; }}
                .footer {{ text-align: center; color: #64748b; font-size: 12px; margin-top: 20px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔐 ZUBID Auction</h1>
                </div>
                <div class="content">
                    {body.replace(chr(10), '<br>')}
                </div>
                <div class="footer">
                    <p>This is an automated message from ZUBID Auction Platform.</p>
                    <p>If you didn't request this, please ignore this email.</p>
                </div>
            </div>
        </body>
        </html>
        """
        html_part = MIMEText(html_body, 'html')

        msg.attach(text_part)
        msg.attach(html_part)

        # Connect and send
        with smtplib.SMTP(smtp_host, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.send_message(msg)

        app.logger.info(f"Email sent successfully to {to_email}")
        return True

    except Exception as e:
        app.logger.error(f"Failed to send email to {to_email}: {str(e)}")
        return False


def send_sms(to_phone, message):
    """
    Send SMS using Twilio
    Requires environment variables:
    - TWILIO_ACCOUNT_SID: Twilio Account SID
    - TWILIO_AUTH_TOKEN: Twilio Auth Token
    - TWILIO_PHONE_NUMBER: Twilio phone number (from)
    """
    account_sid = os.getenv('TWILIO_ACCOUNT_SID')
    auth_token = os.getenv('TWILIO_AUTH_TOKEN')
    from_phone = os.getenv('TWILIO_PHONE_NUMBER')

    if not all([account_sid, auth_token, from_phone]):
        app.logger.warning("Twilio not configured. SMS not sent.")
        return False

    try:
        from twilio.rest import Client
        client = Client(account_sid, auth_token)

        # Ensure phone number has country code
        if not to_phone.startswith('+'):
            # Default to Iraq country code if not provided
            to_phone = '+964' + to_phone.lstrip('0')

        sms = client.messages.create(
            body=message,
            from_=from_phone,
            to=to_phone
        )

        app.logger.info(f"SMS sent successfully to {to_phone}, SID: {sms.sid}")
        return True

    except ImportError:
        app.logger.warning("Twilio library not installed. Run: pip install twilio")
        return False
    except Exception as e:
        app.logger.error(f"Failed to send SMS to {to_phone}: {str(e)}")
        return False


def send_verification_code(user, code, method='email'):
    """
    Send verification code via email or SMS

    Args:
        user: User object
        code: 6-digit verification code
        method: 'email' or 'phone'

    Returns:
        bool: True if sent successfully
    """
    if method == 'email' and user.email:
        subject = "🔐 ZUBID - Password Reset Code"
        body = f"""Hello {user.username},

You requested to reset your password for your ZUBID Auction account.

Your verification code is:

{code}

This code will expire in 15 minutes.

If you didn't request this, please ignore this email and your password will remain unchanged.

Best regards,
ZUBID Auction Team"""

        return send_email(user.email, subject, body)

    elif method == 'phone' and user.phone:
        message = f"ZUBID: Your password reset code is {code}. This code expires in 15 minutes."
        return send_sms(user.phone, message)

    return False


# Security Headers Middleware
@app.after_request
def set_security_headers(response):
    """Add security headers to all responses"""
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    
    # Only add HSTS if HTTPS is enabled
    if os.getenv('HTTPS_ENABLED', 'false').lower() == 'true':
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    
    return response

# Global Error Handlers
@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Resource not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    db.session.rollback()
    app.logger.error(f'Internal server error: {str(error)}', exc_info=True)
    # Don't expose internal errors in production
    if is_production:
        return jsonify({'error': 'An internal error occurred. Please try again later.'}), 500
    else:
        return jsonify({'error': f'Internal server error: {str(error)}'}), 500

@app.errorhandler(400)
def bad_request(error):
    """Handle 400 errors"""
    return jsonify({'error': 'Bad request'}), 400

@app.errorhandler(403)
def forbidden(error):
    """Handle 403 errors"""
    return jsonify({'error': 'Forbidden'}), 403

@app.errorhandler(429)
def rate_limit_exceeded(error):
    """Handle rate limit errors"""
    return jsonify({'error': 'Rate limit exceeded. Please try again later.'}), 429

# Configure Logging
def setup_logging():
    """Configure application logging"""
    log_level = os.getenv('LOG_LEVEL', 'INFO').upper()
    log_dir = os.getenv('LOG_DIR', 'logs')
    
    # Create logs directory if it doesn't exist
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    # Configure file handler with rotation
    file_handler = RotatingFileHandler(
        os.path.join(log_dir, 'zubid.log'),
        maxBytes=10240000,  # 10MB
        backupCount=10
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(getattr(logging, log_level))
    
    # Configure console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s'
    ))
    console_handler.setLevel(getattr(logging, log_level))
    
    # Set app logger
    app.logger.addHandler(file_handler)
    app.logger.addHandler(console_handler)
    app.logger.setLevel(getattr(logging, log_level))
    
    # Suppress Flask default logging
    logging.getLogger('werkzeug').setLevel(logging.WARNING)

# Initialize logging
setup_logging()

# Database Models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    id_number = db.Column(db.String(50), unique=True, nullable=False)  # National ID or Passport
    birth_date = db.Column(db.Date)  # Date of birth
    biometric_data = db.Column(db.Text, nullable=True)  # Deprecated: kept for backward compatibility
    profile_photo = db.Column(db.String(500), nullable=True)  # Profile photo URL
    address = db.Column(db.String(255))
    phone = db.Column(db.String(20), unique=True, nullable=False)  # Made unique for OTP recovery
    role = db.Column(db.String(20), default='user')  # user, admin
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    # Enhanced profile fields
    first_name = db.Column(db.String(50), nullable=True)
    last_name = db.Column(db.String(50), nullable=True)
    bio = db.Column(db.Text, nullable=True)  # User biography
    company = db.Column(db.String(100), nullable=True)  # Company name
    website = db.Column(db.String(255), nullable=True)  # Personal/company website
    city = db.Column(db.String(100), nullable=True)
    country = db.Column(db.String(100), nullable=True)
    postal_code = db.Column(db.String(20), nullable=True)
    phone_verified = db.Column(db.Boolean, default=False)
    email_verified = db.Column(db.Boolean, default=False)
    is_active = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime, nullable=True)
    login_count = db.Column(db.Integer, default=0)

    # Financial fields
    balance = db.Column(db.Float, default=0.0, nullable=False)  # User account balance

    # Mobile app fields
    fcm_token = db.Column(db.String(255), nullable=True)  # Firebase Cloud Messaging token for push notifications

    # Explicitly specify foreign_keys to avoid ambiguity
    auctions = db.relationship('Auction', foreign_keys='Auction.seller_id', backref='seller', lazy=True)
    won_auctions = db.relationship('Auction', foreign_keys='Auction.winner_id', backref='winner', lazy=True)
    bids = db.relationship('Bid', backref='bidder', lazy=True)

    # Database indexes for performance optimization
    __table_args__ = (
        Index('idx_user_role_created', 'role', 'created_at'),
        Index('idx_user_email_verified', 'email_verified'),
        Index('idx_user_active', 'is_active'),
    )

class PasswordResetToken(db.Model):
    """Store password reset tokens"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    token = db.Column(db.String(6), nullable=False)  # 6-digit code
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    expires_at = db.Column(db.DateTime, nullable=False)
    used = db.Column(db.Boolean, default=False)

    user = db.relationship('User', backref=db.backref('reset_tokens', lazy=True))

    def is_valid(self):
        """Check if token is valid (not expired and not used)"""
        return not self.used and datetime.now(timezone.utc) < self.expires_at

class Category(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    description = db.Column(db.Text)
    parent_id = db.Column(db.Integer, db.ForeignKey('category.id'), nullable=True)  # For subcategories
    icon_url = db.Column(db.String(500), nullable=True)  # Icon URL
    image_url = db.Column(db.String(500), nullable=True)  # Category image URL
    is_active = db.Column(db.Boolean, default=True, nullable=False)  # Active status
    sort_order = db.Column(db.Integer, default=0, nullable=False)  # Display order
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    auctions = db.relationship('Auction', backref='category', lazy=True)
    # Note: subcategories relationship commented out for backward compatibility
    # subcategories = db.relationship('Category', backref=db.backref('parent', remote_side=[id]), lazy=True)

    # Note: Indexes commented out to avoid errors on databases without these columns yet
    # __table_args__ = (
    #     Index('idx_category_parent', 'parent_id'),
    #     Index('idx_category_active_sort', 'is_active', 'sort_order'),
    # )

    @property
    def auction_count(self):
        """Get count of active auctions in this category"""
        return Auction.query.filter_by(category_id=self.id, status='active').count()

class Auction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    item_name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    item_condition = db.Column(db.String(50), nullable=True)  # new, used, refurbished, for_parts
    starting_bid = db.Column(db.Float, nullable=False)
    current_bid = db.Column(db.Float, default=0)
    bid_increment = db.Column(db.Float, default=1.0)
    market_price = db.Column(db.Float, nullable=True)  # Market/retail price of the item
    real_price = db.Column(db.Float, nullable=True)  # Buy It Now / Real Price - fixed price to purchase immediately
    start_time = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    end_time = db.Column(db.DateTime, nullable=False)
    seller_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    winner_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
    status = db.Column(db.String(20), default='active')  # active, ended, cancelled
    featured = db.Column(db.Boolean, default=False)
    featured_image_url = db.Column(db.String(500), nullable=True)  # Separate image for featured display (carousel/homepage)
    qr_code_url = db.Column(db.String(500), nullable=True)  # QR code image URL
    video_url = db.Column(db.String(500), nullable=True)  # Video URL (YouTube, Vimeo, or direct video link)
    
    images = db.relationship('Image', backref='auction', lazy=True, cascade='all, delete-orphan')
    bids = db.relationship('Bid', backref='auction', lazy=True, order_by='Bid.timestamp.desc()', cascade='all, delete-orphan')
    
    # Database indexes for performance optimization
    __table_args__ = (
        Index('idx_auction_status_end_time', 'status', 'end_time'),
        Index('idx_auction_category_status', 'category_id', 'status'),
        Index('idx_auction_featured_status', 'featured', 'status'),
        Index('idx_auction_seller', 'seller_id'),
        Index('idx_auction_end_time', 'end_time'),
    )

class Image(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    url = db.Column(db.Text, nullable=False)  # Changed from String(500) to Text to support long data URIs
    is_primary = db.Column(db.Boolean, default=False)
    
    # Database index for performance optimization
    __table_args__ = (
        Index('idx_image_auction_primary', 'auction_id', 'is_primary'),
    )

class Bid(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    is_auto_bid = db.Column(db.Boolean, default=False)
    max_auto_bid = db.Column(db.Float, nullable=True)
    
    # Database indexes for performance optimization
    __table_args__ = (
        Index('idx_bid_auction_timestamp', 'auction_id', 'timestamp'),
        Index('idx_bid_user_timestamp', 'user_id', 'timestamp'),
        Index('idx_bid_auction_amount', 'auction_id', 'amount'),
    )

class Invoice(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    item_price = db.Column(db.Float, nullable=False)  # Winning bid amount
    bid_fee = db.Column(db.Float, nullable=False)  # 1% of item price
    delivery_fee = db.Column(db.Float, nullable=False, default=0.0)
    cashback_amount = db.Column(db.Float, nullable=False, default=0.0)  # Cashback discount applied
    total_amount = db.Column(db.Float, nullable=False)
    payment_method = db.Column(db.String(50))  # 'cash_on_delivery' or 'fib'
    payment_status = db.Column(db.String(50), default='pending')  # pending, paid, failed, cancelled
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    paid_at = db.Column(db.DateTime, nullable=True)

    auction = db.relationship('Auction', backref='invoice', lazy=True)
    user = db.relationship('User', backref='invoices', lazy=True)

class ReturnRequest(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    invoice_id = db.Column(db.Integer, db.ForeignKey('invoice.id'), nullable=False)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    reason = db.Column(db.Text, nullable=False)  # Reason for return
    description = db.Column(db.Text)  # Additional details
    status = db.Column(db.String(50), default='pending')  # pending, approved, rejected, processing, completed, cancelled
    admin_notes = db.Column(db.Text)  # Admin notes/response
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    processed_at = db.Column(db.DateTime, nullable=True)  # When admin processed the request
    
    invoice = db.relationship('Invoice', backref='return_requests', lazy=True)
    auction = db.relationship('Auction', backref='return_requests', lazy=True)
    user = db.relationship('User', backref='return_requests', lazy=True)

class SocialShare(db.Model):
    """Track social media shares for cashback rewards"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=True)  # Nullable for general shares
    platform = db.Column(db.String(50), nullable=False)  # facebook, twitter, linkedin, etc.
    shared_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    verified = db.Column(db.Boolean, default=False)  # Whether the share was verified
    
    user = db.relationship('User', backref='social_shares', lazy=True)
    auction = db.relationship('Auction', backref='social_shares', lazy=True)
    
    # Unique constraint: one share per platform per user per auction
    __table_args__ = (
        db.UniqueConstraint('user_id', 'auction_id', 'platform', name='unique_user_auction_platform'),
    )

class Cashback(db.Model):
    """Track cashback rewards for social sharing"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=True)
    amount = db.Column(db.Float, nullable=False, default=5.0)  # Cashback amount ($5)
    status = db.Column(db.String(50), default='pending')  # pending, processed, cancelled
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    processed_at = db.Column(db.DateTime, nullable=True)

    user = db.relationship('User', backref='cashbacks', lazy=True)
    auction = db.relationship('Auction', backref='cashbacks', lazy=True)

class NavigationMenu(db.Model):
    """Dynamic navigation menu configuration"""
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    label = db.Column(db.String(100), nullable=False)  # Display label
    url = db.Column(db.String(500), nullable=True)  # URL for direct links
    icon = db.Column(db.String(100), nullable=True)  # Icon name or SVG path
    parent_id = db.Column(db.Integer, db.ForeignKey('navigation_menu.id'), nullable=True)  # For nested menus
    order = db.Column(db.Integer, default=0)  # Display order
    is_active = db.Column(db.Boolean, default=True)
    requires_auth = db.Column(db.Boolean, default=False)  # Show only when logged in
    requires_role = db.Column(db.String(20), nullable=True)  # Required role (admin, user, etc.)
    target = db.Column(db.String(20), default='_self')  # _self, _blank, etc.
    css_class = db.Column(db.String(100), nullable=True)  # Custom CSS class
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Self-referential relationship for nested menus
    children = db.relationship('NavigationMenu', backref=db.backref('parent', remote_side=[id]), lazy=True)

    # Database indexes for performance
    __table_args__ = (
        Index('idx_nav_parent_order', 'parent_id', 'order'),
        Index('idx_nav_active', 'is_active'),
    )

class UserPreference(db.Model):
    """Store user preferences and settings"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False, unique=True)
    theme = db.Column(db.String(20), default='light')  # light, dark, auto
    language = db.Column(db.String(10), default='en')  # en, ku, ar
    notifications_enabled = db.Column(db.Boolean, default=True)
    email_notifications = db.Column(db.Boolean, default=True)
    bid_alerts = db.Column(db.Boolean, default=True)
    auction_reminders = db.Column(db.Boolean, default=True)
    newsletter_subscribed = db.Column(db.Boolean, default=False)
    currency = db.Column(db.String(10), default='USD')
    timezone = db.Column(db.String(50), default='UTC')
    items_per_page = db.Column(db.Integer, default=20)
    default_view = db.Column(db.String(20), default='grid')  # grid, list
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = db.relationship('User', backref=db.backref('preferences', uselist=False, lazy=True))

    # Database index
    __table_args__ = (
        Index('idx_user_pref_user_id', 'user_id'),
    )

class Wishlist(db.Model):
    """User wishlist for favorite auctions"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('User', backref=db.backref('wishlist_items', lazy=True))
    auction = db.relationship('Auction', backref=db.backref('wishlisted_by', lazy=True))

    __table_args__ = (
        db.UniqueConstraint('user_id', 'auction_id', name='unique_wishlist_item'),
        Index('idx_wishlist_user', 'user_id'),
    )

class Notification(db.Model):
    """User notifications"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    type = db.Column(db.String(50), default='info')  # outbid, ending, won, new, info
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    auction_id = db.Column(db.Integer, db.ForeignKey('auction.id'), nullable=True)

    user = db.relationship('User', backref=db.backref('notifications', lazy=True))
    auction = db.relationship('Auction', backref=db.backref('notifications', lazy=True))

    __table_args__ = (
        Index('idx_notification_user_read', 'user_id', 'is_read'),
        Index('idx_notification_created', 'created_at'),
    )

# Authentication decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        app.logger.info(f"[AUTH_CHECK] Session data: {dict(session)}")
        app.logger.info(f"[AUTH_CHECK] Session keys: {list(session.keys())}")
        if 'user_id' not in session:
            app.logger.warning(f"[AUTH_CHECK] No user_id in session, returning 401")
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

def get_full_image_url(image_url):
    """Convert relative image URL to full URL"""
    if not image_url:
        return None
    # Already a full URL or data URL
    if image_url.startswith(('http://', 'https://', 'data:')):
        return image_url
    # Relative URL - convert to full URL
    base_url = os.getenv('BASE_URL', 'http://localhost:5000')
    return f"{base_url}{image_url}" if image_url.startswith('/') else f"{base_url}/{image_url}"

def calculate_delivery_fee(user_id):
    """Calculate delivery fee based on user's address"""
    user = User.query.get(user_id)
    if not user or not user.address:
        return 10.0  # Default delivery fee
    
    # Simple calculation based on address length/complexity
    # In production, you'd use a geocoding service or postal code lookup
    address = user.address.lower()
    
    # Basic delivery fee calculation
    base_fee = 10.0
    
    # Add distance-based fees (simplified)
    if any(keyword in address for keyword in ['remote', 'rural', 'village']):
        base_fee += 15.0
    elif any(keyword in address for keyword in ['city', 'urban', 'downtown']):
        base_fee += 5.0
    
    return round(base_fee, 2)

# Health Check Endpoint (for monitoring)
@app.route('/api/health', methods=['GET'])
@csrf.exempt
def health_check():
    """Health check endpoint for monitoring"""
    try:
        # Check database connection
        db.session.execute(text('SELECT 1'))
        
        # Check upload directory
        upload_dir = os.getenv('UPLOAD_FOLDER', 'uploads')
        upload_dir_exists = os.path.exists(upload_dir)
        
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'database': 'connected',
            'upload_directory': 'exists' if upload_dir_exists else 'missing',
            'version': '1.0.0'
        }), 200
    except Exception as e:
        app.logger.error(f'Health check failed: {str(e)}')
        return jsonify({
            'status': 'unhealthy',
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'error': str(e) if not is_production else 'Service unavailable'
        }), 503

# CSRF Token Endpoint
@app.route('/api/csrf-token', methods=['GET'])
@csrf.exempt  # Must be exempt to allow clients to fetch initial token
def get_csrf_token():
    """Get CSRF token for forms"""
    return jsonify({'csrf_token': generate_csrf()}), 200

# Image Upload Configuration - use absolute path based on this file's location
UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'uploads'))
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
ALLOWED_VIDEO_EXTENSIONS = {'mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'm4v'}
MAX_IMAGE_SIZE = 5 * 1024 * 1024  # 5MB
MAX_VIDEO_SIZE = 100 * 1024 * 1024  # 100MB

# Create upload directory if it doesn't exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def allowed_video_file(filename):
    """Check if video file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_VIDEO_EXTENSIONS

def resize_image(image_path, max_size=(1920, 1920), quality=85, is_featured=False):
    """Resize image if it's too large"""
    try:
        # Check if file exists
        if not os.path.exists(image_path):
            app.logger.error(f"Image file not found: {image_path}")
            return False
        
        # Check if file is readable
        if not os.access(image_path, os.R_OK):
            app.logger.error(f"Image file is not readable: {image_path}")
            return False
        
        # Open and verify image
        try:
            with PILImage.open(image_path) as img:
                # Verify image is valid (this will raise an exception if corrupted)
                img.verify()
        except Exception as verify_error:
            # Be more tolerant: log a warning but try to process the image anyway.
            app.logger.warning(f"Image verification failed for {image_path}: {str(verify_error)}")
            # Do not return here; a second open below may still succeed for some images.

        # Reopen image after verification (verify() closes the file)
        with PILImage.open(image_path) as img:
            original_format = img.format
            original_mode = img.mode
            needs_resize = img.size[0] > max_size[0] or img.size[1] > max_size[1]
            needs_conversion = original_mode == 'RGBA' or original_mode == 'LA' or original_mode == 'P'
            
            # Convert to RGB if necessary
            if needs_conversion:
                if original_mode == 'RGBA':
                    background = PILImage.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[3] if len(img.split()) > 3 else None)
                    else:
                        background.paste(img)
                    img = background
                elif original_mode == 'LA':
                    background = PILImage.new('RGB', img.size, (255, 255, 255))
                    background.paste(img)
                    img = background
                elif original_mode == 'P':
                    # Convert palette mode to RGB
                    img = img.convert('RGB')
            
            # Resize if image is larger than max_size
            if needs_resize:
                # Use LANCZOS if available, otherwise use ANTIALIAS (for older Pillow versions)
                try:
                    img.thumbnail(max_size, PILImage.Resampling.LANCZOS)
                except AttributeError:
                    # Fallback for older Pillow versions
                    img.thumbnail(max_size, PILImage.LANCZOS)
            
            # For featured images, resize to optimal dimensions first
            if is_featured:
                # Featured images: 1920x600 (16:5 aspect ratio) for carousel
                target_size = (1920, 600)  # Wide format for carousel
                # Always resize featured images to optimal dimensions
                img.thumbnail(target_size, PILImage.Resampling.LANCZOS)
                needs_resize = True  # Mark as resized so it gets saved
            
            # Save if resize or conversion occurred, preserving original format when possible
            if needs_resize or needs_conversion:
                # For featured images, use higher quality
                if is_featured:
                    # Use high quality for featured images
                    featured_quality = 95  # Higher quality for featured images
                    if needs_conversion or not original_format or original_format in ['JPEG', 'JPG']:
                        img.save(image_path, 'JPEG', quality=featured_quality, optimize=True, progressive=True)
                    elif original_format == 'PNG':
                        if not needs_conversion:
                            img.save(image_path, 'PNG', optimize=True, compress_level=6)
                        else:
                            img.save(image_path, 'JPEG', quality=featured_quality, optimize=True, progressive=True)
                    else:
                        try:
                            img.save(image_path, original_format, optimize=True)
                        except Exception:
                            img.save(image_path, 'JPEG', quality=featured_quality, optimize=True, progressive=True)
                else:
                    # Regular images: standard quality
                    if needs_conversion or not original_format or original_format in ['JPEG', 'JPG']:
                        img.save(image_path, 'JPEG', quality=quality, optimize=True)
                    elif original_format == 'PNG':
                        if not needs_conversion:
                            img.save(image_path, 'PNG', optimize=True)
                        else:
                            img.save(image_path, 'JPEG', quality=quality, optimize=True)
                    else:
                        try:
                            img.save(image_path, original_format, optimize=True)
                        except Exception:
                            img.save(image_path, 'JPEG', quality=quality, optimize=True)
            
            return True
    except IOError as e:
        app.logger.error(f"IOError resizing image {image_path}: {str(e)}")
        import traceback
        traceback.print_exc()
        return False
    except Exception as e:
        app.logger.error(f"Error resizing image {image_path}: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def generate_qr_code(auction_id, item_name, item_price=None):
    """Generate QR code for an auction item"""
    try:
        base_url = os.getenv('BASE_URL', 'http://localhost:5000').rstrip('/')
        
        # Create QR code data (JSON format with auction info)
        qr_data = {
            'auction_id': auction_id,
            'item_name': item_name,
            'type': 'auction_item',
            'url': f'{base_url}/auctions/{auction_id}',
            'timestamp': datetime.now(timezone.utc).isoformat()
        }
        
        if item_price:
            qr_data['price'] = item_price
        
        # Convert to JSON string
        qr_json = json.dumps(qr_data)
        
        # Create QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(qr_json)
        qr.make(fit=True)
        
        # Create QR code image
        qr_img = qr.make_image(fill_color="black", back_color="white")
        
        # Save QR code to file
        timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
        qr_filename = f"qr_auction_{auction_id}_{timestamp}.png"
        qr_filepath = os.path.join(UPLOAD_FOLDER, qr_filename)
        
        # Ensure upload directory exists
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)
        
        qr_img.save(qr_filepath)
        
        # Store relative URL (frontend will construct full URL)
        qr_url = f"/uploads/{qr_filename}"
        
        return qr_url
    except Exception as e:
        app.logger.error(f"Error generating QR code: {str(e)}")
        import traceback
        traceback.print_exc()
        return None

@app.route('/api/upload/image', methods=['POST'])
@login_required
@limiter.limit("20 per minute")  # Rate limit image uploads
def upload_image():
    """Upload and process auction images - supports Cloudinary for production"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'}), 400

        file = request.files['image']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Allowed types: PNG, JPG, JPEG, GIF, WEBP'}), 400

        # Check file size - handle both file-like objects and werkzeug FileStorage
        try:
            if hasattr(file, 'content_length') and file.content_length:
                file_size = file.content_length
            else:
                # Fallback: seek to end and get position
                file.seek(0, os.SEEK_END)
                file_size = file.tell()
                file.seek(0)
        except (AttributeError, OSError, IOError) as e:
            app.logger.warning(f"Could not determine file size: {str(e)}")
            file_size = MAX_IMAGE_SIZE + 1  # Force validation to fail

        if file_size > MAX_IMAGE_SIZE:
            return jsonify({'error': f'File too large. Maximum size: {MAX_IMAGE_SIZE / 1024 / 1024}MB'}), 400

        # Check if filename is valid
        filename = secure_filename(file.filename)
        if not filename:
            return jsonify({'error': 'Invalid filename'}), 400

        # Check if this is a featured image upload
        is_featured = request.form.get('is_featured', 'false').lower() == 'true'

        # Use image_storage service for upload (supports both local and Cloudinary)
        upload_result = image_storage.upload_image(
            file,
            session['user_id'],
            folder='auctions',
            is_featured=is_featured
        )

        if not upload_result:
            return jsonify({'error': 'Failed to upload image'}), 500

        # If using local storage, also resize the image
        if upload_result.get('storage') == 'local':
            filepath = upload_result.get('filepath')
            if filepath:
                if is_featured:
                    resize_result = resize_image(filepath, max_size=(1920, 600), quality=95, is_featured=True)
                else:
                    resize_result = resize_image(filepath)
                if not resize_result:
                    try:
                        os.remove(filepath)
                    except OSError:
                        pass
                    return jsonify({'error': 'Failed to process image'}), 500

        image_url = upload_result['url']
        app.logger.info(f"Image uploaded ({upload_result.get('storage', 'unknown')}): {image_url} by user {session['user_id']}")

        return jsonify({
            'message': 'Image uploaded successfully',
            'url': image_url,
            'filename': upload_result.get('filename', ''),
            'storage': upload_result.get('storage', 'local')
        }), 200

    except Exception as e:
        app.logger.error(f"Error uploading image: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to upload image: {str(e)}'}), 500

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    """Serve uploaded images and videos"""
    try:
        # Security: ensure filename is safe
        safe_filename = secure_filename(filename)
        if not safe_filename:
            app.logger.warning(f"Invalid filename requested: {filename}")
            abort(404)

        filepath = os.path.join(UPLOAD_FOLDER, safe_filename)

        # Additional security: prevent path traversal
        abs_filepath = os.path.abspath(filepath)
        abs_upload_folder = os.path.abspath(UPLOAD_FOLDER)

        if not abs_filepath.startswith(abs_upload_folder):
            app.logger.warning(f"Path traversal attempt: {filename}")
            abort(404)

        # Check if file exists
        if not os.path.exists(filepath):
            app.logger.warning(f"File not found: {safe_filename} (requested: {filename})")
            abort(404)

        # Determine content type based on file extension
        file_ext = safe_filename.rsplit('.', 1)[1].lower() if '.' in safe_filename else ''
        content_type = None

        if file_ext in ALLOWED_EXTENSIONS:
            # Image files
            content_type_map = {
                'jpg': 'image/jpeg',
                'jpeg': 'image/jpeg',
                'png': 'image/png',
                'gif': 'image/gif',
                'webp': 'image/webp'
            }
            content_type = content_type_map.get(file_ext, 'application/octet-stream')
        elif file_ext in ALLOWED_VIDEO_EXTENSIONS:
            # Video files
            content_type_map = {
                'mp4': 'video/mp4',
                'webm': 'video/webm',
                'ogg': 'video/ogg',
                'mov': 'video/quicktime',
                'avi': 'video/x-msvideo',
                'mkv': 'video/x-matroska',
                'm4v': 'video/mp4'
            }
            content_type = content_type_map.get(file_ext, 'video/mp4')

        if content_type:
            return send_from_directory(UPLOAD_FOLDER, safe_filename, mimetype=content_type)
        else:
            return send_from_directory(UPLOAD_FOLDER, safe_filename)
    except HTTPException:
        # Re-raise HTTP exceptions (like abort(404))
        raise
    except Exception as e:
        app.logger.error(f"Error serving file {filename}: {str(e)}")
        abort(404)  # Return 404 instead of 500 for any unexpected errors

# User Management APIs
@app.route('/api/register', methods=['POST'])
@csrf.exempt  # Allow registration without CSRF token for API clients
@limiter.limit("5 per minute")  # Rate limit registration
def register():
    try:
        # Handle both JSON and form-data for backward compatibility
        if request.is_json:
            # JSON format (legacy)
            data = request.json
            form_data = data
            profile_photo_file = None
        else:
            # Form-data format (with photo upload)
            form_data = request.form.to_dict()
            profile_photo_file = request.files.get('profile_photo')
        
        # Sanitize and validate required fields
        username = sanitize_string(form_data.get('username', ''), max_length=80)
        if not username:
            return jsonify({'error': 'Username is required'}), 400
        
        email = sanitize_string(form_data.get('email', ''), max_length=255).lower()
        if not email:
            return jsonify({'error': 'Email is required'}), 400
        if not validate_email(email):
            return jsonify({'error': 'Invalid email format'}), 400
        
        password = form_data.get('password', '')
        if not password:
            return jsonify({'error': 'Password is required'}), 400
        
        # Validate password meets standard requirements
        password_errors = []
        if len(password) < 8:
            password_errors.append('Password must be at least 8 characters long')
        if not any(c.islower() for c in password):
            password_errors.append('Password must contain at least one lowercase letter')
        if not any(c.isupper() for c in password):
            password_errors.append('Password must contain at least one uppercase letter')
        if not any(c.isdigit() for c in password):
            password_errors.append('Password must contain at least one number')
        if not any(c in '!@#$%^&*()_+-=[]{}|;:,.<>?' for c in password):
            password_errors.append('Password must contain at least one special character')
        
        if password_errors:
            return jsonify({'error': 'Password does not meet requirements: ' + '; '.join(password_errors)}), 400
        
        id_number = sanitize_string(form_data.get('id_number', ''), max_length=50)
        if not id_number:
            return jsonify({'error': 'ID Number is required'}), 400
        
        if not form_data.get('birth_date'):
            return jsonify({'error': 'Date of Birth is required'}), 400
        
        phone = sanitize_string(form_data.get('phone', ''), max_length=20)
        if not phone:
            return jsonify({'error': 'Phone number is required'}), 400
        if not validate_phone(phone):
            return jsonify({'error': 'Invalid phone number format'}), 400
        
        address = sanitize_string(form_data.get('address', ''), max_length=255)
        if not address:
            return jsonify({'error': 'Address is required'}), 400
        if len(address) < 5:
            return jsonify({'error': 'Address must be at least 5 characters long'}), 400
        
        # Check if username already exists
        if User.query.filter_by(username=username).first():
            return jsonify({'error': 'Username already exists'}), 400
        
        # Check if email already exists
        if User.query.filter_by(email=email).first():
            return jsonify({'error': 'Email already exists'}), 400
        
        # Check if ID number already exists
        if User.query.filter_by(id_number=id_number).first():
            return jsonify({'error': 'ID Number already registered'}), 400

        # Check if phone number already exists
        if User.query.filter_by(phone=phone).first():
            return jsonify({'error': 'Phone number already registered'}), 400

        # Parse birth_date string to Date object
        birth_date_obj = None
        if form_data.get('birth_date'):
            try:
                # Expecting format YYYY-MM-DD from HTML date input
                birth_date_obj = datetime.strptime(form_data['birth_date'], '%Y-%m-%d').date()
            except (ValueError, TypeError) as e:
                return jsonify({'error': f'Invalid date format for birth date: {str(e)}'}), 400
        
        # Handle profile photo upload
        profile_photo_url = None
        if profile_photo_file and profile_photo_file.filename:
            if not allowed_file(profile_photo_file.filename):
                return jsonify({'error': 'Invalid photo file type. Allowed types: PNG, JPG, JPEG, GIF, WEBP'}), 400
            
            # Check file size
            try:
                if hasattr(profile_photo_file, 'content_length') and profile_photo_file.content_length:
                    file_size = profile_photo_file.content_length
                else:
                    profile_photo_file.seek(0, os.SEEK_END)
                    file_size = profile_photo_file.tell()
                    profile_photo_file.seek(0)
            except (AttributeError, OSError, IOError) as e:
                app.logger.warning(f"Could not determine file size: {str(e)}")
                file_size = MAX_IMAGE_SIZE + 1
            
            if file_size > MAX_IMAGE_SIZE:
                return jsonify({'error': f'Photo too large. Maximum size: {MAX_IMAGE_SIZE / 1024 / 1024}MB'}), 400
            
            # Generate secure filename
            filename = secure_filename(profile_photo_file.filename)
            if not filename:
                return jsonify({'error': 'Invalid filename'}), 400
            
            timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
            unique_filename = f"profile_{timestamp}_{filename}"
            filepath = os.path.join(UPLOAD_FOLDER, unique_filename)
            
            # Additional security: prevent path traversal
            if not os.path.abspath(filepath).startswith(os.path.abspath(UPLOAD_FOLDER)):
                return jsonify({'error': 'Invalid file path'}), 400
            
            # Save file
            profile_photo_file.save(filepath)
            
            # Resize if needed
            resize_result = resize_image(filepath, max_size=(400, 400), quality=85)
            if not resize_result:
                try:
                    os.remove(filepath)
                except OSError:
                    pass
                return jsonify({'error': 'Failed to process profile photo'}), 500
            
            # Store relative URL (frontend will construct full URL)
            profile_photo_url = f"/uploads/{unique_filename}"
        
        # Create user (using sanitized values)
        user = User(
            username=username,  # Already sanitized
            email=email,  # Already sanitized and validated
            password_hash=generate_password_hash(password),
            id_number=id_number,  # Already sanitized
            birth_date=birth_date_obj,
            biometric_data=form_data.get('biometric_data'),  # Optional - deprecated
            profile_photo=profile_photo_url,  # Profile photo URL
            address=address,  # Already sanitized
            phone=phone  # Already sanitized and validated
        )
        db.session.add(user)
        db.session.commit()
        
        app.logger.info(f"User registered: {user.username} (ID: {user.id})")
        
        # Create a personalized welcome message
        welcome_message = (
            f"Welcome to ZUBID, {username}! 🎉\n\n"
            f"We're thrilled to have you join our auction community. "
            f"Your account has been successfully created and you're all set to start bidding on amazing items.\n\n"
            f"Here's what you can do:\n"
            f"• Browse and discover exciting auctions\n"
            f"• Place bids on items you love\n"
            f"• Create your own auctions\n"
            f"• Track your bids and wins\n\n"
            f"Happy bidding! 🚀"
        )
        
        # Return response compatible with Android app's AuthResponse model
        return jsonify({
            'message': 'User registered successfully',
            'welcome_message': welcome_message,
            'user': {
                'id': str(user.id),
                'username': user.username,
                'email': user.email,
                'role': user.role,
                'profile_photo': profile_photo_url,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'balance': 0.0
            }
        }), 201
    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Registration error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500

@app.route('/api/login', methods=['POST'])
@csrf.exempt  # Allow login without CSRF token for API clients
@limiter.limit("10 per minute")  # Rate limit login attempts
def login():
    if not request.json:
        return jsonify({'error': 'No JSON data received'}), 400
    
    data = request.json
    if not data.get('username') or not data.get('password'):
        return jsonify({'error': 'Username and password are required'}), 400
    
    user = User.query.filter_by(username=data['username']).first()
    if user and check_password_hash(user.password_hash, data['password']):
        # Check if user is active
        if not user.is_active:
            app.logger.warning(f"Login attempt for inactive user: {user.username}")
            return jsonify({'error': 'Account is deactivated. Please contact support.'}), 403

        # Update login tracking
        user.last_login = datetime.now(timezone.utc)
        user.login_count = (user.login_count or 0) + 1
        db.session.commit()

        session.permanent = True
        session['user_id'] = user.id
        session.modified = True  # Force Flask to send the Set-Cookie header
        app.logger.info(f"User {user.username} (ID: {user.id}) logged in. Session ID: {session.get('user_id')}")

        # Create default preferences if they don't exist
        if not user.preferences:
            preferences = UserPreference(user_id=user.id)
            db.session.add(preferences)
            db.session.commit()

        return jsonify({
            'message': 'Login successful',
            'user': {
                'id': str(user.id),
                'username': user.username,
                'email': user.email,
                'role': user.role,
                'profile_photo': get_full_image_url(user.profile_photo),
                'first_name': user.first_name,
                'last_name': user.last_name,
                'balance': float(user.balance) if user.balance is not None else 0.0
            }
        }), 200
    app.logger.warning(f"Failed login attempt for user: {data.get('username')}")
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/api/logout', methods=['POST'])
@csrf.exempt  # Allow logout without CSRF token for API clients
def logout():
    session.pop('user_id', None)
    return jsonify({'message': 'Logout successful'}), 200

@app.route('/api/me', methods=['GET'])
@login_required
def get_current_user():
    """Get current logged-in user's profile"""
    user = User.query.get(session['user_id'])
    if not user:
        return jsonify({'error': 'User not found'}), 404

    return jsonify({
        'id': str(user.id),
        'username': user.username,
        'email': user.email,
        'role': user.role,
        'profile_photo': get_full_image_url(user.profile_photo),
        'first_name': user.first_name,
        'last_name': user.last_name,
        'balance': float(user.balance) if user.balance is not None else 0.0,
        'phone': user.phone,
        'address': user.address,
        'city': user.city,
        'country': user.country,
        'bio': user.bio,
        'company': user.company,
        'website': user.website,
        'email_verified': user.email_verified,
        'phone_verified': user.phone_verified,
        'created_at': user.created_at.isoformat() if user.created_at else None,
        'last_login': user.last_login.isoformat() if user.last_login else None
    }), 200

# ==========================================
# WISHLIST ENDPOINTS
# ==========================================

def get_auction_image(auction):
    """Get primary image URL for an auction"""
    if auction.images:
        primary = next((img for img in auction.images if img.is_primary), None)
        if primary:
            return primary.url
        return auction.images[0].url if auction.images else None
    return auction.featured_image_url

@app.route('/api/wishlist', methods=['GET'])
@login_required
def get_wishlist():
    """Get user's wishlist"""
    user_id = session['user_id']
    wishlist_items = Wishlist.query.filter_by(user_id=user_id).all()

    auctions = []
    for item in wishlist_items:
        auction = item.auction
        if auction:
            end_time = ensure_timezone_aware(auction.end_time) if auction.end_time else None
            end_time_ms = int(end_time.timestamp() * 1000) if end_time else 0
            auctions.append({
                # Android-compatible field names
                'id': str(auction.id),
                'title': auction.item_name,
                'description': auction.description,
                'imageUrl': get_auction_image(auction),
                'currentPrice': auction.current_bid or auction.starting_bid,
                'startingPrice': auction.starting_bid,
                'endTime': end_time_ms,
                'categoryId': str(auction.category_id) if auction.category_id else '',
                'sellerId': str(auction.seller_id),
                'bidCount': len(auction.bids) if auction.bids else 0,
                'isWishlisted': True,
                'realPrice': auction.real_price,
                'marketPrice': auction.market_price
            })

    return jsonify(auctions), 200

@app.route('/api/wishlist/<int:auction_id>', methods=['POST'])
@login_required
def add_to_wishlist(auction_id):
    """Add auction to wishlist"""
    user_id = session['user_id']

    # Check if auction exists
    auction = Auction.query.get(auction_id)
    if not auction:
        return jsonify({'error': 'Auction not found'}), 404

    # Check if already in wishlist
    existing = Wishlist.query.filter_by(user_id=user_id, auction_id=auction_id).first()
    if existing:
        return jsonify({'message': 'Already in wishlist'}), 200

    wishlist_item = Wishlist(user_id=user_id, auction_id=auction_id)
    db.session.add(wishlist_item)
    db.session.commit()

    return jsonify({'message': 'Added to wishlist'}), 201

@app.route('/api/wishlist/<int:auction_id>', methods=['DELETE'])
@login_required
def remove_from_wishlist(auction_id):
    """Remove auction from wishlist"""
    user_id = session['user_id']

    wishlist_item = Wishlist.query.filter_by(user_id=user_id, auction_id=auction_id).first()
    if wishlist_item:
        db.session.delete(wishlist_item)
        db.session.commit()

    return jsonify({'message': 'Removed from wishlist'}), 200

# ==========================================
# MY BIDS & MY AUCTIONS ENDPOINTS
# ==========================================

@app.route('/api/my-bids', methods=['GET'])
@login_required
def get_my_bids():
    """Get auctions the user has bid on"""
    user_id = session['user_id']

    # Get all auctions where user has placed bids
    user_bids = Bid.query.filter_by(user_id=user_id).all()
    auction_ids = list(set([bid.auction_id for bid in user_bids]))

    auctions = Auction.query.filter(Auction.id.in_(auction_ids)).all()

    result = []
    for auction in auctions:
        end_time = ensure_timezone_aware(auction.end_time) if auction.end_time else None
        end_time_ms = int(end_time.timestamp() * 1000) if end_time else 0
        result.append({
            # Android-compatible field names
            'id': str(auction.id),
            'title': auction.item_name,
            'description': auction.description,
            'imageUrl': get_auction_image(auction),
            'currentPrice': auction.current_bid or auction.starting_bid,
            'startingPrice': auction.starting_bid,
            'endTime': end_time_ms,
            'categoryId': str(auction.category_id) if auction.category_id else '',
            'sellerId': str(auction.seller_id),
            'bidCount': len(auction.bids) if auction.bids else 0,
            'isWishlisted': False,
            'realPrice': auction.real_price,
            'marketPrice': auction.market_price
        })

    return jsonify(result), 200

@app.route('/api/my-auctions', methods=['GET'])
@login_required
def get_my_auctions():
    """Get auctions the user has won"""
    user_id = session['user_id']

    # Get all auctions where user is the winner
    won_auctions = Auction.query.filter_by(winner_id=user_id, status='ended').all()

    result = []
    for auction in won_auctions:
        end_time = ensure_timezone_aware(auction.end_time) if auction.end_time else None
        end_time_ms = int(end_time.timestamp() * 1000) if end_time else 0
        result.append({
            # Android-compatible field names
            'id': str(auction.id),
            'title': auction.item_name,
            'description': auction.description,
            'imageUrl': get_auction_image(auction),
            'currentPrice': auction.current_bid or auction.starting_bid,
            'startingPrice': auction.starting_bid,
            'endTime': end_time_ms,
            'categoryId': str(auction.category_id) if auction.category_id else '',
            'sellerId': str(auction.seller_id),
            'bidCount': len(auction.bids) if auction.bids else 0,
            'isWishlisted': False,
            'realPrice': auction.real_price,
            'marketPrice': auction.market_price
        })

    return jsonify(result), 200

# ==========================================
# NOTIFICATIONS ENDPOINTS
# ==========================================

@app.route('/api/notifications', methods=['GET'])
@login_required
def get_notifications():
    """Get user's notifications"""
    user_id = session['user_id']

    notifications = Notification.query.filter_by(user_id=user_id)\
        .order_by(Notification.created_at.desc())\
        .limit(50).all()

    result = []
    for notif in notifications:
        result.append({
            'id': str(notif.id),
            'title': notif.title,
            'message': notif.message,
            'timestamp': int(notif.created_at.timestamp() * 1000) if notif.created_at else 0,
            'type': notif.type,
            'isRead': notif.is_read
        })

    return jsonify(result), 200

@app.route('/api/notifications/<int:notification_id>/read', methods=['PUT'])
@login_required
def mark_notification_read(notification_id):
    """Mark notification as read"""
    user_id = session['user_id']

    notification = Notification.query.filter_by(id=notification_id, user_id=user_id).first()
    if not notification:
        return jsonify({'error': 'Notification not found'}), 404

    notification.is_read = True
    db.session.commit()

    return jsonify({'message': 'Notification marked as read'}), 200

@app.route('/api/notifications/read-all', methods=['PUT'])
@login_required
def mark_all_notifications_read():
    """Mark all notifications as read for current user"""
    user_id = session['user_id']

    Notification.query.filter_by(user_id=user_id, is_read=False).update({'is_read': True})
    db.session.commit()

    return jsonify({'message': 'All notifications marked as read'}), 200

@app.route('/api/notifications/unread-count', methods=['GET'])
@login_required
def get_unread_notification_count():
    """Get count of unread notifications"""
    user_id = session['user_id']

    count = Notification.query.filter_by(user_id=user_id, is_read=False).count()

    return jsonify({'count': count}), 200

@app.route('/api/notifications/<int:notification_id>', methods=['DELETE'])
@login_required
def delete_notification(notification_id):
    """Delete a notification"""
    user_id = session['user_id']

    notification = Notification.query.filter_by(id=notification_id, user_id=user_id).first()
    if not notification:
        return jsonify({'error': 'Notification not found'}), 404

    db.session.delete(notification)
    db.session.commit()

    return jsonify({'message': 'Notification deleted'}), 200

# Helper function to create notifications
def create_notification(user_id, title, message, notification_type='info', auction_id=None):
    """Helper function to create a notification for a user"""
    try:
        notification = Notification(
            user_id=user_id,
            title=title,
            message=message,
            type=notification_type,
            auction_id=auction_id
        )
        db.session.add(notification)
        db.session.commit()
        return notification
    except Exception as e:
        app.logger.error(f"Failed to create notification: {e}")
        db.session.rollback()
        return None

# ==========================================
# PASSWORD MANAGEMENT ENDPOINTS
# ==========================================

@app.route('/api/forgot-password', methods=['POST'])
@limiter.limit("5 per minute")
def forgot_password():
    """Request password reset - accepts email OR phone"""
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400

        email = request.json.get('email', '').strip().lower()
        phone = request.json.get('phone', '').strip()
        method = request.json.get('method', 'email')  # 'email' or 'phone'

        # Must provide either email or phone
        if not email and not phone:
            return jsonify({'error': 'Email or phone number is required'}), 400

        # Ensure PasswordResetToken table exists
        try:
            db.create_all()
        except Exception as e:
            app.logger.warning(f"Could not create tables: {e}")

        # Find user by email or phone
        user = None
        if email:
            user = User.query.filter_by(email=email).first()
            method = 'email'
        elif phone:
            # Normalize phone number (remove spaces, dashes)
            phone = ''.join(filter(lambda x: x.isdigit() or x == '+', phone))
            user = User.query.filter_by(phone=phone).first()
            method = 'phone'

        if not user:
            # Don't reveal if user exists for security
            return jsonify({'message': 'If an account exists with this information, a reset code will be sent'}), 200

        if not user.is_active:
            return jsonify({'error': 'Account is deactivated. Please contact support.'}), 403

        # Generate 6-digit reset code
        import random
        reset_code = ''.join([str(random.randint(0, 9)) for _ in range(6)])

        # Delete any existing unused tokens for this user
        try:
            PasswordResetToken.query.filter_by(user_id=user.id, used=False).delete()
        except Exception as e:
            app.logger.warning(f"Could not delete old tokens: {e}")
            db.session.rollback()

        # Create new token (expires in 15 minutes)
        token = PasswordResetToken(
            user_id=user.id,
            token=reset_code,
            expires_at=datetime.now(timezone.utc) + timedelta(minutes=15)
        )
        db.session.add(token)
        db.session.commit()

        # Send verification code via email or SMS
        sent = send_verification_code(user, reset_code, method)

        if sent:
            app.logger.info(f"Password reset code sent to user {user.username} via {method}")
            return jsonify({
                'message': f'Reset code sent successfully via {method}',
                'method': method,
                'expires_in': 15  # minutes
            }), 200
        else:
            # If sending failed, still log it but don't expose the code
            app.logger.warning(f"Failed to send reset code to {user.username} via {method}")
            # For development/testing: include code if SMTP/Twilio not configured
            if not is_production:
                return jsonify({
                    'message': 'Reset code generated (email/SMS not configured)',
                    'reset_code': reset_code,  # Only for development
                    'method': method,
                    'expires_in': 15
                }), 200
            else:
                return jsonify({
                    'message': 'Reset code sent successfully',
                    'method': method,
                    'expires_in': 15
                }), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Forgot password error: {str(e)}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/api/reset-password', methods=['POST'])
@limiter.limit("5 per minute")
def reset_password():
    """Reset password using token"""
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400

        email = request.json.get('email', '').strip().lower()
        phone = request.json.get('phone', '').strip()
        token = request.json.get('token', '').strip()
        new_password = request.json.get('new_password', '')

        if not token:
            return jsonify({'error': 'Reset code is required'}), 400

        if not new_password:
            return jsonify({'error': 'New password is required'}), 400

        if len(new_password) < 8:
            return jsonify({'error': 'Password must be at least 8 characters'}), 400

        # Find user by email or phone
        user = None
        if email:
            user = User.query.filter_by(email=email).first()
        elif phone:
            phone = ''.join(filter(lambda x: x.isdigit() or x == '+', phone))
            user = User.query.filter_by(phone=phone).first()

        if not user:
            return jsonify({'error': 'Invalid reset request'}), 400

        # Find valid token
        reset_token = PasswordResetToken.query.filter_by(
            user_id=user.id,
            token=token,
            used=False
        ).first()

        if not reset_token or not reset_token.is_valid():
            return jsonify({'error': 'Invalid or expired reset code'}), 400

        # Update password
        user.password_hash = generate_password_hash(new_password)
        reset_token.used = True
        db.session.commit()

        app.logger.info(f"Password reset successful for user {user.username}")

        return jsonify({'message': 'Password reset successful'}), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Reset password error: {str(e)}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/api/change-password', methods=['POST'])
@login_required
def change_password():
    """Change password for logged-in user"""
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400

        current_password = request.json.get('current_password', '')
        new_password = request.json.get('new_password', '')

        if not current_password:
            return jsonify({'error': 'Current password is required'}), 400

        if not new_password:
            return jsonify({'error': 'New password is required'}), 400

        if len(new_password) < 8:
            return jsonify({'error': 'New password must be at least 8 characters'}), 400

        user = User.query.get(session['user_id'])
        if not user:
            return jsonify({'error': 'User not found'}), 404

        # Verify current password
        if not check_password_hash(user.password_hash, current_password):
            return jsonify({'error': 'Current password is incorrect'}), 400

        # Update password
        user.password_hash = generate_password_hash(new_password)
        db.session.commit()

        app.logger.info(f"Password changed for user {user.username}")

        return jsonify({'message': 'Password changed successfully'}), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Change password error: {str(e)}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@app.route('/api/user/profile', methods=['GET'])
@login_required
def get_profile():
    user_id = session.get('user_id')
    app.logger.info(f"get_profile called. Session user_id: {user_id}")
    user = User.query.get(user_id)

    if not user:
        app.logger.error(f"User not found for ID: {user_id}")
        return jsonify({'error': 'User not found'}), 404

    # Get user preferences
    preferences = user.preferences

    # Count user stats
    total_bids = len(user.bids) if hasattr(user, 'bids') and user.bids else 0
    total_wins = Auction.query.filter_by(winner_id=user.id).count()

    # Return profile wrapped in 'profile' key (expected by Flutter app)
    return jsonify({
        'profile': {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'id_number': user.id_number,
            'date_of_birth': user.birth_date.isoformat() if user.birth_date else None,  # Flutter expects date_of_birth
            'birth_date': user.birth_date.isoformat() if user.birth_date else None,  # Also keep original
            'address': user.address,
            'phone': user.phone,
            'phone_number': user.phone,  # Flutter expects phone_number
            'role': user.role,
            'profile_photo': get_full_image_url(user.profile_photo),
            'profile_photo_url': get_full_image_url(user.profile_photo),  # Flutter expects profile_photo_url
            # Enhanced profile fields
            'first_name': user.first_name,
            'last_name': user.last_name,
            'bio': user.bio,
            'company': user.company,
            'website': user.website,
            'city': user.city,
            'country': user.country,
            'postal_code': user.postal_code,
            'phone_verified': user.phone_verified,
            'email_verified': user.email_verified,
            'is_active': user.is_active,
            'profile_completed': bool(user.first_name and user.last_name and user.phone),
            'last_login': user.last_login.isoformat() if user.last_login else None,
            'last_active': user.last_login.isoformat() if user.last_login else None,  # Flutter expects last_active
            'login_count': user.login_count,
            'created_at': user.created_at.isoformat() if user.created_at else None,
            'member_since': user.created_at.isoformat() if user.created_at else None,  # Flutter expects member_since
            'updated_at': user.created_at.isoformat() if user.created_at else None,  # Add updated_at
            # User stats
            'total_bids': total_bids,
            'total_wins': total_wins,
            'total_spent': 0.0,  # TODO: Calculate from invoices
            'rating': 5.0,  # TODO: Implement rating system
            # User preferences
            'preferences': {
                'theme': preferences.theme if preferences else 'light',
                'language': preferences.language if preferences else 'en',
                'notifications_enabled': preferences.notifications_enabled if preferences else True,
                'email_notifications': preferences.email_notifications if preferences else True,
                'bid_alerts': preferences.bid_alerts if preferences else True,
                'auction_reminders': preferences.auction_reminders if preferences else True,
                'newsletter_subscribed': preferences.newsletter_subscribed if preferences else False,
                'currency': preferences.currency if preferences else 'USD',
                'timezone': preferences.timezone if preferences else 'UTC',
                'items_per_page': preferences.items_per_page if preferences else 20,
                'default_view': preferences.default_view if preferences else 'grid'
            } if preferences else None,
            'preferred_language': preferences.language if preferences else 'en',
            'timezone': preferences.timezone if preferences else 'UTC',
        }
    }), 200

@app.route('/api/user/profile', methods=['PUT'])
@login_required
def update_profile():
    try:
        user = User.query.get(session['user_id'])
        
        # Handle both JSON and form-data for profile photo upload
        if request.is_json:
            data = request.json
            profile_photo_file = None
        else:
            # Form-data format (with photo upload)
            data = request.form.to_dict()
            profile_photo_file = request.files.get('profile_photo')
        
        # Update email with validation and sanitization
        if 'email' in data:
            email = sanitize_string(data.get('email', ''), max_length=255).lower()
            if not email:
                return jsonify({'error': 'Email cannot be empty'}), 400
            if not validate_email(email):
                return jsonify({'error': 'Invalid email format'}), 400
            # Check if email is already taken by another user
            existing_user = User.query.filter(User.email == email, User.id != user.id).first()
            if existing_user:
                return jsonify({'error': 'Email is already registered'}), 400
            user.email = email
        
        # Update address with validation and sanitization
        if 'address' in data:
            address = sanitize_string(data.get('address', ''), max_length=255)
            if address and len(address) < 5:
                return jsonify({'error': 'Address must be at least 5 characters long'}), 400
            user.address = address
        
        # Update phone with validation and sanitization
        if 'phone' in data:
            phone = sanitize_string(data.get('phone', ''), max_length=20)
            if phone and not validate_phone(phone):
                return jsonify({'error': 'Invalid phone number format'}), 400
            user.phone = phone

        # Update enhanced profile fields
        if 'first_name' in data:
            user.first_name = sanitize_string(data.get('first_name', ''), max_length=50)
        if 'last_name' in data:
            user.last_name = sanitize_string(data.get('last_name', ''), max_length=50)
        if 'bio' in data:
            user.bio = sanitize_string(data.get('bio', ''), max_length=1000)
        if 'company' in data:
            user.company = sanitize_string(data.get('company', ''), max_length=100)
        if 'website' in data:
            website = sanitize_string(data.get('website', ''), max_length=255)
            if website and not (website.startswith('http://') or website.startswith('https://')):
                return jsonify({'error': 'Website must start with http:// or https://'}), 400
            user.website = website
        if 'city' in data:
            user.city = sanitize_string(data.get('city', ''), max_length=100)
        if 'country' in data:
            user.country = sanitize_string(data.get('country', ''), max_length=100)
        if 'postal_code' in data:
            user.postal_code = sanitize_string(data.get('postal_code', ''), max_length=20)

        # Handle profile photo upload
        if profile_photo_file and profile_photo_file.filename:
            if not allowed_file(profile_photo_file.filename):
                return jsonify({'error': 'Invalid photo file type. Allowed types: PNG, JPG, JPEG, GIF, WEBP'}), 400
            
            # Check file size
            try:
                if hasattr(profile_photo_file, 'content_length') and profile_photo_file.content_length:
                    file_size = profile_photo_file.content_length
                else:
                    profile_photo_file.seek(0, os.SEEK_END)
                    file_size = profile_photo_file.tell()
                    profile_photo_file.seek(0)
            except (AttributeError, OSError, IOError) as e:
                app.logger.warning(f"Could not determine file size: {str(e)}")
                file_size = MAX_IMAGE_SIZE + 1
            
            if file_size > MAX_IMAGE_SIZE:
                return jsonify({'error': f'Photo too large. Maximum size: {MAX_IMAGE_SIZE / 1024 / 1024}MB'}), 400
            
            # Generate secure filename
            filename = secure_filename(profile_photo_file.filename)
            if not filename:
                return jsonify({'error': 'Invalid filename'}), 400
            
            timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
            unique_filename = f"profile_{timestamp}_{session['user_id']}_{filename}"
            filepath = os.path.join(UPLOAD_FOLDER, unique_filename)
            
            # Additional security: prevent path traversal
            if not os.path.abspath(filepath).startswith(os.path.abspath(UPLOAD_FOLDER)):
                return jsonify({'error': 'Invalid file path'}), 400
            
            # Delete old profile photo if exists
            if user.profile_photo:
                try:
                    old_filename = user.profile_photo.split('/')[-1]
                    old_filepath = os.path.join(UPLOAD_FOLDER, old_filename)
                    if os.path.exists(old_filepath) and os.path.abspath(old_filepath).startswith(os.path.abspath(UPLOAD_FOLDER)):
                        os.remove(old_filepath)
                except Exception as e:
                    app.logger.warning(f"Could not delete old profile photo: {str(e)}")
            
            # Save file
            profile_photo_file.save(filepath)
            
            # Resize if needed (profile photos should be smaller)
            try:
                resize_result = resize_image(filepath, max_size=(400, 400), quality=85)
                if not resize_result:
                    try:
                        os.remove(filepath)
                    except OSError:
                        pass
                    return jsonify({'error': 'Failed to process profile photo. The image may be corrupted or in an unsupported format.'}), 500
            except Exception as resize_error:
                app.logger.error(f"Error in resize_image for profile photo: {str(resize_error)}")
                import traceback
                traceback.print_exc()
                try:
                    os.remove(filepath)
                except OSError:
                    pass
                return jsonify({'error': f'Failed to process profile photo: {str(resize_error)}'}), 500
            
            # Store relative URL (frontend will construct full URL)
            profile_photo_url = f"/uploads/{unique_filename}"
            user.profile_photo = profile_photo_url
        
        # Also allow updating profile_photo via JSON (URL) with validation
        elif 'profile_photo' in data and data['profile_photo']:
            photo_url = data['profile_photo'].strip() if isinstance(data['profile_photo'], str) else str(data['profile_photo']).strip()
            if photo_url:
                # Validate URL format
                if not (photo_url.startswith('http://') or photo_url.startswith('https://')):
                    return jsonify({'error': 'Invalid profile photo URL. Must start with http:// or https://'}), 400
                # Check URL length (max 500 characters)
                if len(photo_url) > 500:
                    return jsonify({'error': 'Profile photo URL is too long (max 500 characters)'}), 400
                # Additional security: check for javascript: or data: schemes
                if photo_url.lower().startswith(('javascript:', 'data:', 'vbscript:')):
                    return jsonify({'error': 'Invalid profile photo URL scheme'}), 400
                user.profile_photo = photo_url
            else:
                # Empty string means remove photo
                user.profile_photo = None
        
        db.session.commit()
        return jsonify({
            'message': 'Profile updated successfully',
            'profile_photo': user.profile_photo
        }), 200
    
    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error updating profile: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to update profile: {str(e)}'}), 500

@app.route('/api/user/profile/photo', methods=['POST'])
@login_required
@limiter.limit("10 per minute")
def upload_profile_photo():
    """Upload profile photo - supports Cloudinary for production"""
    try:
        if 'photo' not in request.files:
            return jsonify({'error': 'No photo file provided'}), 400

        file = request.files['photo']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Allowed types: PNG, JPG, JPEG, GIF, WEBP'}), 400

        # Check file size
        try:
            if hasattr(file, 'content_length') and file.content_length:
                file_size = file.content_length
            else:
                file.seek(0, os.SEEK_END)
                file_size = file.tell()
                file.seek(0)
        except (AttributeError, OSError, IOError):
            file_size = MAX_IMAGE_SIZE + 1

        if file_size > MAX_IMAGE_SIZE:
            return jsonify({'error': f'Photo too large. Maximum size: {MAX_IMAGE_SIZE / 1024 / 1024}MB'}), 400

        # Check if filename is valid
        filename = secure_filename(file.filename)
        if not filename:
            return jsonify({'error': 'Invalid filename'}), 400

        # Get user and delete old photo
        user = User.query.get(session['user_id'])
        if user.profile_photo:
            try:
                # Delete from appropriate storage (Cloudinary or local)
                image_storage.delete_image(user.profile_photo)
            except Exception as e:
                app.logger.warning(f"Could not delete old profile photo: {str(e)}")

        # Use image_storage service for upload (supports both local and Cloudinary)
        upload_result = image_storage.upload_image(
            file,
            session['user_id'],
            folder='profiles',
            is_profile=True
        )

        if not upload_result:
            return jsonify({'error': 'Failed to upload photo'}), 500

        # If using local storage, also resize the image
        if upload_result.get('storage') == 'local':
            filepath = upload_result.get('filepath')
            if filepath:
                resize_result = resize_image(filepath, max_size=(400, 400), quality=85)
                if not resize_result:
                    try:
                        os.remove(filepath)
                    except OSError:
                        pass
                    return jsonify({'error': 'Failed to process photo'}), 500

        # Update user
        profile_photo_url = upload_result['url']
        user.profile_photo = profile_photo_url
        db.session.commit()

        app.logger.info(f"Profile photo uploaded ({upload_result.get('storage', 'unknown')}): {profile_photo_url}")

        return jsonify({
            'message': 'Profile photo uploaded successfully',
            'profile_photo': profile_photo_url,
            'storage': upload_result.get('storage', 'local')
        }), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error uploading profile photo: {str(e)}")
        return jsonify({'error': f'Failed to upload photo: {str(e)}'}), 500

@app.route('/api/user/fcm-token', methods=['POST'])
@login_required
@limiter.limit("20 per minute")
def update_fcm_token():
    """Update user's FCM token for push notifications"""
    try:
        data = request.get_json()
        if not data or 'fcm_token' not in data:
            return jsonify({'error': 'FCM token is required'}), 400

        fcm_token = data.get('fcm_token', '').strip()
        if not fcm_token:
            return jsonify({'error': 'FCM token cannot be empty'}), 400

        # Validate token format (basic check)
        if len(fcm_token) < 50 or len(fcm_token) > 500:
            return jsonify({'error': 'Invalid FCM token format'}), 400

        # Update user's FCM token
        user = User.query.get(session['user_id'])
        if not user:
            return jsonify({'error': 'User not found'}), 404

        user.fcm_token = fcm_token
        db.session.commit()

        app.logger.info(f"FCM token updated for user {user.username} (ID: {user.id})")

        return jsonify({
            'message': 'FCM token updated successfully',
            'success': True
        }), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error updating FCM token: {str(e)}")
        return jsonify({'error': f'Failed to update FCM token: {str(e)}'}), 500

@app.route('/api/user/fcm-token', methods=['DELETE'])
@login_required
@limiter.limit("20 per minute")
def delete_fcm_token():
    """Delete user's FCM token (e.g., on logout)"""
    try:
        user = User.query.get(session['user_id'])
        if not user:
            return jsonify({'error': 'User not found'}), 404

        user.fcm_token = None
        db.session.commit()

        app.logger.info(f"FCM token deleted for user {user.username} (ID: {user.id})")

        return jsonify({
            'message': 'FCM token deleted successfully',
            'success': True
        }), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error deleting FCM token: {str(e)}")
        return jsonify({'error': f'Failed to delete FCM token: {str(e)}'}), 500

# Category APIs
# Note: Caching disabled for now to ensure compatibility during migration
# @lru_cache(maxsize=1)
# def _get_cached_categories():
#     """Internal function to get categories - cached"""
#     # This function is deprecated - use get_categories() directly

@app.route('/api/categories', methods=['GET'])
def get_categories():
    """
    Get all categories with backward compatibility for old schema.
    Handles both old (3 fields) and new (10 fields) database schemas.
    """
    try:
        # Try to get all categories, handling both old and new schemas
        categories = Category.query.all()

        # Check if new fields exist by trying to access them
        has_new_fields = hasattr(Category, 'is_active') and hasattr(Category, 'sort_order')

        if has_new_fields:
            # New schema - filter by is_active and sort
            categories = Category.query.filter_by(is_active=True).order_by(Category.sort_order, Category.name).all()
        else:
            # Old schema - just get all and sort by name
            categories = Category.query.order_by(Category.name).all()

        result = []
        for cat in categories:
            cat_dict = {
                'id': cat.id,
                'name': cat.name,
                'description': cat.description,
            }

            # Add new fields if they exist
            if has_new_fields:
                cat_dict.update({
                    'parent_id': getattr(cat, 'parent_id', None),
                    'icon_url': getattr(cat, 'icon_url', None),
                    'image_url': getattr(cat, 'image_url', None),
                    'auction_count': getattr(cat, 'auction_count', 0),
                    'is_active': getattr(cat, 'is_active', True),
                    'sort_order': getattr(cat, 'sort_order', 0),
                    'created_at': cat.created_at.isoformat() if hasattr(cat, 'created_at') and cat.created_at else None,
                    'updated_at': cat.updated_at.isoformat() if hasattr(cat, 'updated_at') and cat.updated_at else None,
                    'subcategories': []
                })

                # Add subcategories if parent_id exists
                if hasattr(cat, 'subcategories'):
                    cat_dict['subcategories'] = [{
                        'id': sub.id,
                        'name': sub.name,
                        'description': sub.description,
                        'parent_id': getattr(sub, 'parent_id', None),
                        'icon_url': getattr(sub, 'icon_url', None),
                        'image_url': getattr(sub, 'image_url', None),
                        'auction_count': getattr(sub, 'auction_count', 0),
                        'is_active': getattr(sub, 'is_active', True),
                        'sort_order': getattr(sub, 'sort_order', 0),
                        'created_at': sub.created_at.isoformat() if hasattr(sub, 'created_at') and sub.created_at else None,
                        'updated_at': sub.updated_at.isoformat() if hasattr(sub, 'updated_at') and sub.updated_at else None,
                    } for sub in cat.subcategories if getattr(sub, 'is_active', True)]

            result.append(cat_dict)

        return jsonify(result), 200

    except Exception as e:
        print(f"Error fetching categories: {str(e)}")
        import traceback
        traceback.print_exc()
        # Fallback to simple query
        try:
            categories = Category.query.all()
            return jsonify([{
                'id': cat.id,
                'name': cat.name,
                'description': cat.description
            } for cat in categories]), 200
        except Exception as e2:
            print(f"Fallback also failed: {str(e2)}")
            return jsonify({'error': 'Failed to fetch categories'}), 500

@app.route('/api/categories', methods=['POST'])
@login_required
def create_category():
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        category_name = sanitize_string(data.get('name', ''), max_length=100)
        if not category_name:
            return jsonify({'error': 'Category name is required'}), 400
        
        if Category.query.filter_by(name=category_name).first():
            return jsonify({'error': 'Category already exists'}), 400
        
        category_description = sanitize_string(data.get('description', ''), max_length=500)
        category = Category(name=category_name, description=category_description)
        db.session.add(category)
        db.session.commit()
        return jsonify({'message': 'Category created', 'id': category.id}), 201
    except Exception as e:
        db.session.rollback()
        print(f"Error creating category: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to create category: {str(e)}'}), 500

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
        
        # Update auction status based on end_time
        # Use database-level update to avoid race conditions
        now = datetime.now(timezone.utc)
        from sqlalchemy import and_
        # Update ended auctions atomically - optimize with eager loading
        ended_auctions = Auction.query.filter(
            and_(Auction.status == 'active', Auction.end_time < now)
        ).options(selectinload(Auction.bids)).all()
        
        for auction in ended_auctions:
            # Ensure end_time is timezone-aware for comparison
            end_time = ensure_timezone_aware(auction.end_time)
            if end_time and end_time < now and auction.status == 'active':
                auction.status = 'ended'
                if auction.bids:
                    highest_bid = max(auction.bids, key=lambda b: b.amount)
                    auction.winner_id = highest_bid.user_id
                    auction.current_bid = highest_bid.amount
                    
                    # Create invoice for the winner (check if doesn't exist to avoid duplicates)
                    user_id = highest_bid.user_id
                    existing_invoice = Invoice.query.filter_by(auction_id=auction.id, user_id=user_id).first()
                    if not existing_invoice:
                        item_price = auction.current_bid
                        bid_fee = item_price * 0.01
                        delivery_fee = calculate_delivery_fee(user_id)
                        total_amount = item_price + bid_fee + delivery_fee
                        
                        # Generate QR code if auction doesn't have one
                        if not auction.qr_code_url:
                            qr_code_url = generate_qr_code(auction.id, auction.item_name, item_price)
                            if qr_code_url:
                                auction.qr_code_url = qr_code_url
                                db.session.flush()
                        
                        invoice = Invoice(
                            auction_id=auction.id,
                            user_id=user_id,
                            item_price=item_price,
                            bid_fee=bid_fee,
                            delivery_fee=delivery_fee,
                            total_amount=total_amount,
                            payment_status='pending'
                        )
                        db.session.add(invoice)

                    # Create winner notification
                    try:
                        create_notification(
                            user_id=highest_bid.user_id,
                            title='🎉 Congratulations! You Won!',
                            message=f'You won the auction for "{auction.item_name}" with a bid of ${auction.current_bid:.2f}. Please complete your payment.',
                            notification_type='won',
                            auction_id=auction.id
                        )
                    except Exception as notif_error:
                        app.logger.warning(f"Failed to create winner notification: {notif_error}")

        if ended_auctions:
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
            # Sort by bid count using subquery to avoid conflicts with eager loading
            from sqlalchemy import select
            bid_count_subq = select(
                Bid.auction_id,
                func.count(Bid.id).label('bid_count')
            ).group_by(Bid.auction_id).subquery()
            
            query = query.outerjoin(bid_count_subq, Auction.id == bid_count_subq.c.auction_id)
            query = query.order_by(bid_count_subq.c.bid_count.desc().nullslast())
            # For bid sorting, we can't use selectinload for bids since we're already joining
            # Apply eager loading for other relationships
            query = query.options(
                joinedload(Auction.seller),
                joinedload(Auction.category),
                selectinload(Auction.images)
            )
        else:
            query = query.order_by(Auction.end_time.asc())
        
        # Optimize query with eager loading to prevent N+1 queries (for non-bid-sorting)
        if sort_by != 'bids':
            query = query.options(
                joinedload(Auction.seller),
                joinedload(Auction.category),
                selectinload(Auction.images),
                selectinload(Auction.bids)
            )
        
        pagination = query.paginate(page=page, per_page=per_page, error_out=False)
        
        auctions = []
        for auction in pagination.items:
            # Ensure end_time is timezone-aware for calculation
            end_time = ensure_timezone_aware(auction.end_time)
            time_left = (end_time - now).total_seconds() if end_time else 0
            
            # Count unique bidders (users who have placed bids) - optimized
            unique_bidders = set()
            try:
                if auction.bids:
                    unique_bidders = {bid.user_id for bid in auction.bids}
            except Exception:
                # If bids relationship fails to load, query directly
                try:
                    bid_user_ids = db.session.query(Bid.user_id).filter_by(auction_id=auction.id).distinct().all()
                    unique_bidders = {bid[0] for bid in bid_user_ids}
                except Exception:
                    unique_bidders = set()
            
            # Return both old field names (for web) and new field names (for Android)
            end_time_ms = int(end_time.timestamp() * 1000) if end_time else 0
            auctions.append({
                # Android-compatible field names
                'id': str(auction.id),
                'title': auction.item_name,
                'description': auction.description[:100] + '...' if len(auction.description) > 100 else auction.description,
                'imageUrl': auction.images[0].url if auction.images else None,
                'currentPrice': auction.current_bid or auction.starting_bid,
                'startingPrice': auction.starting_bid,
                'endTime': end_time_ms,
                'categoryId': str(auction.category_id) if auction.category_id else '',
                'sellerId': str(auction.seller_id),
                'bidCount': len(unique_bidders),
                'isWishlisted': False,  # TODO: Check if user has wishlisted
                'realPrice': auction.real_price,
                'marketPrice': auction.market_price,
                # Legacy field names (for web compatibility)
                'item_name': auction.item_name,
                'item_condition': auction.item_condition,
                'starting_bid': auction.starting_bid,
                'current_bid': auction.current_bid or auction.starting_bid,
                'bid_increment': auction.bid_increment,
                'market_price': auction.market_price,
                'real_price': auction.real_price,
                'start_time': ensure_timezone_aware(auction.start_time).isoformat() if auction.start_time else None,
                'end_time': end_time.isoformat() if end_time else None,
                'time_left': max(0, int(time_left)),
                'seller_id': auction.seller_id,
                'seller_name': auction.seller.username if auction.seller else None,
                'category_id': auction.category_id,
                'category_name': auction.category.name if auction.category else None,
                'status': auction.status,
                'featured': auction.featured,
                'image_url': auction.images[0].url if auction.images else None,
                'featured_image_url': auction.featured_image_url,
                'bid_count': len(unique_bidders),
                'qr_code_url': auction.qr_code_url,
                'video_url': auction.video_url
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
        app.logger.error(f"Error in get_auctions: {str(e)}", exc_info=True)
        import traceback
        traceback.print_exc()
        # Return a more user-friendly error message
        error_msg = str(e)
        if 'no such table' in error_msg.lower() or 'relation' in error_msg.lower():
            return jsonify({'error': 'Database tables not initialized. Please restart the backend server to create tables.'}), 500
        return jsonify({'error': f'Failed to fetch auctions: {error_msg}'}), 500

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
            'item_condition': auction.item_condition,
            'starting_bid': auction.starting_bid,
            'current_bid': auction.current_bid or auction.starting_bid,
            'bid_increment': auction.bid_increment,
            'market_price': auction.market_price,
            'real_price': auction.real_price,  # Buy It Now / Real Price
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
            'featured_image_url': auction.featured_image_url,  # Separate featured image
            'bid_count': len(unique_bidders),  # Count unique bidders, not total bids
            'winner_id': auction.winner_id,
            'qr_code_url': auction.qr_code_url,
            'video_url': auction.video_url
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
        
        # Sanitize and validate required fields
        item_name = sanitize_string(data.get('item_name', ''), max_length=200)
        if not item_name:
            return jsonify({'error': 'Item name is required'}), 400
        
        description = sanitize_string(data.get('description', ''), max_length=5000, allow_html=False)
        if not description:
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
        
        # Sanitize optional fields
        item_condition = sanitize_string(data.get('item_condition', ''), max_length=50) if data.get('item_condition') else None
        video_url = sanitize_string(data.get('video_url', ''), max_length=500) if data.get('video_url') else None
        featured_image_url = sanitize_string(data.get('featured_image_url', ''), max_length=500) if data.get('featured_image_url') else None
        
        # Validate market price if provided
        market_price = None
        if data.get('market_price'):
            try:
                market_price = float(data['market_price'])
                if market_price < 0:
                    return jsonify({'error': 'Market price cannot be negative'}), 400
            except (ValueError, TypeError):
                return jsonify({'error': 'Invalid market price value'}), 400
        
        # Validate real price (Buy It Now) if provided
        real_price = None
        if data.get('real_price'):
            try:
                real_price = float(data['real_price'])
                if real_price < 0:
                    return jsonify({'error': 'Real price cannot be negative'}), 400
                if real_price <= starting_bid:
                    return jsonify({'error': 'Real price must be higher than starting bid'}), 400
            except (ValueError, TypeError):
                return jsonify({'error': 'Invalid real price value'}), 400
        
        # Create auction
        auction = Auction(
            item_name=item_name,
            description=description,
            item_condition=item_condition,
            starting_bid=starting_bid,
            bid_increment=bid_increment,
            market_price=market_price,
            real_price=real_price,  # Buy It Now / Real Price
            end_time=end_time,
            seller_id=session['user_id'],
            category_id=category_id,
            featured=bool(data.get('featured', False)),
            current_bid=starting_bid,
            video_url=video_url,  # Optional video URL
            featured_image_url=featured_image_url  # Optional featured image URL
        )
        db.session.add(auction)
        db.session.flush()
        
        # Add images (sanitize URLs)
        images = data.get('images', [])
        if images:
            for idx, img_url in enumerate(images):
                if img_url:  # Only add non-empty image URLs
                    # For data URIs, don't truncate - they can be very long
                    # For regular URLs, sanitize normally
                    if str(img_url).startswith('data:image/'):
                        # Data URI - store as-is (no truncation)
                        sanitized_url = str(img_url)
                    else:
                        # Regular URL - sanitize with reasonable limit
                        sanitized_url = sanitize_string(str(img_url), max_length=500, allow_html=False)
                    
                    image = Image(
                        auction_id=auction.id,
                        url=sanitized_url,
                        is_primary=(idx == 0)  # First image is primary
                    )
                    db.session.add(image)
        
        # Generate QR code for the auction
        qr_code_url = generate_qr_code(auction.id, auction.item_name, auction.starting_bid)
        if qr_code_url:
            auction.qr_code_url = qr_code_url
        
        db.session.commit()
        return jsonify({'message': 'Auction created', 'id': auction.id, 'qr_code_url': qr_code_url}), 201
    
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
        
        if 'item_condition' in data:
            auction.item_condition = data['item_condition']
        
        if 'market_price' in data:
            if data['market_price'] is not None:
                try:
                    market_price = float(data['market_price'])
                    if market_price < 0:
                        return jsonify({'error': 'Market price cannot be negative'}), 400
                    auction.market_price = market_price
                except (ValueError, TypeError):
                    return jsonify({'error': 'Invalid market price value'}), 400
            else:
                auction.market_price = None
        
        if 'real_price' in data:
            if data['real_price'] is not None:
                try:
                    real_price = float(data['real_price'])
                    if real_price < 0:
                        return jsonify({'error': 'Real price cannot be negative'}), 400
                    if real_price <= auction.starting_bid:
                        return jsonify({'error': 'Real price must be higher than starting bid'}), 400
                    auction.real_price = real_price
                except (ValueError, TypeError):
                    return jsonify({'error': 'Invalid real price value'}), 400
            else:
                auction.real_price = None
        
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
        
        if 'video_url' in data:
            auction.video_url = data['video_url'] if data['video_url'] else None
        
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
        # Optimize query with eager loading
        bids = Bid.query.filter_by(auction_id=auction_id).options(
            joinedload(Bid.bidder)
        ).order_by(Bid.amount.desc(), Bid.timestamp.desc()).limit(50).all()
        
        # Find the highest bid amount
        highest_bid_amount = max([bid.amount for bid in bids]) if bids else 0
        current_bid = auction.current_bid or auction.starting_bid
        
        # Determine winning logic based on auction status
        result = []
        for bid in bids:
            is_winning = False
            
            if auction.status == 'active':
                # For active auctions, check if this is the current highest bid
                is_winning = bid.amount == highest_bid_amount and bid.amount == current_bid
            elif auction.status == 'ended':
                # For ended auctions, check if this user is the winner
                is_winning = auction.winner_id is not None and bid.user_id == auction.winner_id and bid.amount == highest_bid_amount
            
            result.append({
                'id': bid.id,
                'user_id': bid.user_id,
                'username': bid.bidder.username,
                'amount': bid.amount,
                'timestamp': bid.timestamp.isoformat(),
                'is_auto_bid': bid.is_auto_bid,
                'is_winning': is_winning,
                'is_highest': bid.amount == highest_bid_amount,
                'auction_status': auction.status,
                'winner_id': auction.winner_id
            })
        
        return jsonify(result), 200
    except Exception as e:
        print(f"Error in get_bids: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to get bids: {str(e)}'}), 500

@app.route('/api/auctions/<int:auction_id>/bids', methods=['POST'])
@login_required
@limiter.limit("30 per minute")  # Rate limit bid placement
def place_bid(auction_id):
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        user_id = session['user_id']
        
        # Use database lock to prevent race conditions
        # Lock the auction row for update to prevent concurrent modifications
        # Start transaction with row-level locking
        auction = db.session.query(Auction).filter_by(id=auction_id).with_for_update().first()
        if not auction:
            return jsonify({'error': 'Auction not found'}), 404
        
        if auction.status != 'active':
            db.session.rollback()
            return jsonify({'error': 'Auction is not active'}), 400
        
        now = datetime.now(timezone.utc)
        # Ensure end_time is timezone-aware for comparison
        end_time = ensure_timezone_aware(auction.end_time)
        if end_time and end_time < now:
            auction.status = 'ended'
            db.session.commit()
            return jsonify({'error': 'Auction has ended'}), 400
        
        if auction.seller_id == user_id:
            db.session.rollback()
            return jsonify({'error': 'Cannot bid on your own auction'}), 400
        
        # Validate bid amount
        if 'amount' not in data:
            db.session.rollback()
            return jsonify({'error': 'Bid amount is required'}), 400
        
        try:
            bid_amount = float(data['amount'])
            if bid_amount <= 0:
                db.session.rollback()
                return jsonify({'error': 'Bid amount must be greater than 0'}), 400
        except (ValueError, TypeError):
            db.session.rollback()
            return jsonify({'error': 'Invalid bid amount'}), 400
        
        # Re-check current bid after lock (may have changed)
        min_bid = (auction.current_bid or auction.starting_bid) + auction.bid_increment
        
        if bid_amount < min_bid:
            db.session.rollback()
            return jsonify({'error': f'Bid must be at least ${min_bid:.2f}'}), 400
        
        # Check auto-bid logic
        auto_bid_amount = data.get('auto_bid_amount')
        if auto_bid_amount:
            try:
                auto_bid_amount = float(auto_bid_amount)
                if auto_bid_amount < bid_amount:
                    db.session.rollback()
                    return jsonify({'error': 'Auto-bid limit must be higher than initial bid'}), 400
                if auto_bid_amount <= 0:
                    db.session.rollback()
                    return jsonify({'error': 'Auto-bid limit must be greater than 0'}), 400
            except (ValueError, TypeError):
                db.session.rollback()
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
        
        # ANTI-SNIPE: Only extend if bid is placed in the last 2 minutes
        # This prevents last-second bids from winning without giving others a chance to respond
        end_time = ensure_timezone_aware(auction.end_time)
        time_until_end = (end_time - now).total_seconds() if end_time else 0

        # Only extend if less than 2 minutes (120 seconds) remaining
        # This prevents extending auctions that have plenty of time left
        ANTI_SNIPE_THRESHOLD = 120  # 2 minutes
        EXTENSION_AMOUNT = 120  # 2 minutes

        time_extended = False
        if 0 < time_until_end < ANTI_SNIPE_THRESHOLD:
            new_end_time = now + timedelta(seconds=EXTENSION_AMOUNT)  # Set to 2 minutes from now
            auction.end_time = new_end_time
            time_extended = True
        
        # Check for auto-bids from other users that should counter-bid
        # Only check active auto-bids that can still bid higher
        other_auto_bids = Bid.query.filter(
            Bid.auction_id == auction_id,
            Bid.user_id != user_id,
            Bid.is_auto_bid,
            Bid.max_auto_bid >= bid_amount + auction.bid_increment
        ).order_by(Bid.max_auto_bid.desc()).all()
        
        # Process auto-bids to create counter-bids
        # Only the highest auto-bid should counter, then process recursively
        current_bid_amount = bid_amount
        for auto_bid in other_auto_bids:
            # Calculate counter-bid amount
            new_amount = min(current_bid_amount + auction.bid_increment, auto_bid.max_auto_bid)
            
            # Only create counter-bid if it's higher than current bid
            if new_amount > auction.current_bid and new_amount <= auto_bid.max_auto_bid:
                counter_bid = Bid(
                    auction_id=auction_id,
                    user_id=auto_bid.user_id,
                    amount=new_amount,
                    is_auto_bid=True,
                    max_auto_bid=auto_bid.max_auto_bid
                )
                db.session.add(counter_bid)
                auction.current_bid = new_amount
                current_bid_amount = new_amount
                
                # Only process first counter-bid in this iteration to avoid infinite loops
                # Other auto-bids will be processed on next bid
                break
        
        # Find previous highest bidder to notify them they've been outbid
        previous_bid = Bid.query.filter(
            Bid.auction_id == auction_id,
            Bid.user_id != user_id
        ).order_by(Bid.amount.desc()).first()

        previous_bidder_id = previous_bid.user_id if previous_bid else None

        db.session.commit()

        # Create notification for outbid user (after commit to ensure bid is saved)
        if previous_bidder_id:
            try:
                create_notification(
                    user_id=previous_bidder_id,
                    title='You\'ve been outbid! 🔔',
                    message=f'Someone placed a higher bid of ${bid_amount:.2f} on "{auction.item_name}". Place a new bid to stay in the lead!',
                    notification_type='outbid',
                    auction_id=auction_id
                )
            except Exception as notif_error:
                app.logger.warning(f"Failed to create outbid notification: {notif_error}")

        # Calculate updated time_left for response
        updated_end_time = ensure_timezone_aware(auction.end_time)
        updated_time_left = max(0, int((updated_end_time - datetime.now(timezone.utc)).total_seconds()))

        # Get user info for the bid response
        user = User.query.get(user_id)

        return jsonify({
            'message': 'Bid placed successfully',
            'current_bid': auction.current_bid,
            'bid_id': bid.id,
            'time_extended': time_extended,
            'new_end_time': updated_end_time.isoformat(),
            'time_left': updated_time_left,
            # Return full bid object for Flutter app compatibility
            'bid': {
                'id': bid.id,
                'auction_id': auction_id,
                'user_id': user_id,
                'amount': bid.amount,
                'created_at': bid.timestamp.isoformat() if bid.timestamp else datetime.now(timezone.utc).isoformat(),
                'updated_at': bid.timestamp.isoformat() if bid.timestamp else datetime.now(timezone.utc).isoformat(),
                'is_winning': True,  # New bid is always the winning bid
                'is_auto_bid': bid.is_auto_bid or False,
                'max_bid_amount': bid.max_auto_bid,
                'user_username': user.username if user else 'Unknown',
                'user_avatar': user.profile_photo if user else None,
                'user_rating': user.rating if user and hasattr(user, 'rating') else None
            }
        }), 201

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error placing bid: {str(e)}", exc_info=True)
        # Don't expose internal error details in production
        error_message = 'Failed to place bid' if is_production else f'Failed to place bid: {str(e)}'
        return jsonify({'error': error_message}), 500

@app.route('/api/auctions/<int:auction_id>/buy-now', methods=['POST'])
@login_required
def buy_now(auction_id):
    """Buy It Now - Purchase item at real price instantly"""
    try:
        user_id = session['user_id']

        # Lock the auction row to prevent race conditions
        auction = db.session.query(Auction).filter_by(id=auction_id).with_for_update().first()
        if not auction:
            return jsonify({'error': 'Auction not found'}), 404

        if auction.status != 'active':
            db.session.rollback()
            return jsonify({'error': 'Auction is not active'}), 400

        # Check if auction has a real price (Buy It Now price)
        if not auction.real_price or auction.real_price <= 0:
            db.session.rollback()
            return jsonify({'error': 'This auction does not have a Buy It Now option'}), 400

        now = datetime.now(timezone.utc)
        end_time = ensure_timezone_aware(auction.end_time)
        if end_time and end_time < now:
            auction.status = 'ended'
            db.session.commit()
            return jsonify({'error': 'Auction has ended'}), 400

        if auction.seller_id == user_id:
            db.session.rollback()
            return jsonify({'error': 'Cannot buy your own auction item'}), 400

        # Create a bid at the real price
        buy_now_bid = Bid(
            auction_id=auction_id,
            user_id=user_id,
            amount=auction.real_price,
            is_auto_bid=False,
            max_auto_bid=None
        )
        db.session.add(buy_now_bid)

        # Update auction - end it immediately with buyer as winner
        auction.current_bid = auction.real_price
        auction.status = 'ended'
        auction.winner_id = user_id
        auction.end_time = now  # End immediately

        # Create invoice for the purchase
        bid_fee = auction.real_price * 0.01  # 1% fee
        delivery_fee = calculate_delivery_fee(user_id)
        total_amount = auction.real_price + bid_fee + delivery_fee

        # Check if invoice already exists
        existing_invoice = Invoice.query.filter_by(auction_id=auction.id, user_id=user_id).first()
        if not existing_invoice:
            invoice = Invoice(
                auction_id=auction.id,
                user_id=user_id,
                item_price=auction.real_price,
                bid_fee=bid_fee,
                delivery_fee=delivery_fee,
                total_amount=total_amount,
                payment_status='pending'
            )
            db.session.add(invoice)

        db.session.commit()

        # Create notification for buyer
        try:
            create_notification(
                user_id=user_id,
                title='Purchase Complete! 🎉',
                message=f'Congratulations! You purchased "{auction.item_name}" for ${auction.real_price:.2f}.',
                notification_type='won',
                auction_id=auction_id
            )
        except Exception as notif_error:
            app.logger.warning(f"Failed to create purchase notification: {notif_error}")

        return jsonify({
            'message': 'Purchase successful! You bought this item.',
            'auction_id': auction.id,
            'purchase_price': auction.real_price,
            'total_with_fees': total_amount
        }), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error in buy now: {str(e)}", exc_info=True)
        error_message = 'Failed to process purchase' if is_production else f'Failed to process purchase: {str(e)}'
        return jsonify({'error': error_message}), 500

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
    # Optimize query with eager loading
    auctions = Auction.query.filter_by(seller_id=session['user_id']).options(
        selectinload(Auction.bids)
    ).all()
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
        # Optimize query with eager loading
        auctions = Auction.query.filter_by(featured=True, status='active').options(
            selectinload(Auction.images)
        ).limit(5).all()
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
                'image_url': auction.images[0].url if auction.images else None,
                'featured_image_url': auction.featured_image_url  # Separate featured image
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
    
    # Build user list
    users_list = []
    for user in pagination.items:
        users_list.append({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role,
            'created_at': user.created_at.isoformat(),
            'auction_count': len(user.auctions),
            'bid_count': len(user.bids)
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
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        user = User.query.get_or_404(user_id)
        
        if 'role' in data:
            if data['role'] not in ['user', 'admin']:
                return jsonify({'error': 'Invalid role. Must be "user" or "admin"'}), 400
            user.role = data['role']
        
        if 'email' in data:
            if not data['email'] or not data['email'].strip():
                return jsonify({'error': 'Email cannot be empty'}), 400
            # Check if email already exists for another user
            existing = User.query.filter_by(email=data['email'].strip()).first()
            if existing and existing.id != user_id:
                return jsonify({'error': 'Email already in use by another user'}), 400
            user.email = data['email'].strip()
        
        db.session.commit()
        return jsonify({'message': 'User updated successfully'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error updating user: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to update user: {str(e)}'}), 500

@app.route('/api/admin/users/<int:user_id>', methods=['GET'])
@admin_required
def get_user_details(user_id):
    """Get detailed user information"""
    user = User.query.get_or_404(user_id)
    
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
        'bid_count': len(user.bids)
    }), 200

@app.route('/api/admin/users/<int:user_id>', methods=['DELETE'])
@admin_required
def delete_user(user_id):
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Prevent deleting admin users
        if user.role == 'admin':
            return jsonify({'error': 'Cannot delete admin users'}), 403
        
        # Step 1: Delete all bids made by this user (must be done first to avoid foreign key constraint)
        # This includes bids on auctions they created and bids on other auctions
        bids = Bid.query.filter_by(user_id=user_id).all()
        for bid in bids:
            db.session.delete(bid)
        
        # Step 2: Handle auctions where user is the seller
        # Delete images and auctions they created
        # Optimize: Use eager loading to avoid N+1 queries
        auctions_as_seller = Auction.query.filter_by(seller_id=user_id).options(
            selectinload(Auction.images)
        ).all()
        for seller_auction in auctions_as_seller:
            # Delete all images for these auctions (already loaded via eager loading)
            for image in seller_auction.images:
                db.session.delete(image)
            # Delete the auction
            db.session.delete(seller_auction)
        
        # Step 3: Handle auctions where user is the winner (set winner_id to None)
        auctions_as_winner = Auction.query.filter_by(winner_id=user_id).all()
        for auction in auctions_as_winner:
            auction.winner_id = None
        
        # Now delete the user
        db.session.delete(user)
        db.session.commit()
        return jsonify({'message': 'User deleted successfully'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error deleting user: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to delete user: {str(e)}'}), 500

# Admin Return Request APIs
@app.route('/api/admin/return-requests', methods=['GET'])
@admin_required
def get_all_return_requests():
    """Get all return requests (admin only)"""
    try:
        status = request.args.get('status', '')
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        query = ReturnRequest.query
        
        if status:
            query = query.filter_by(status=status)
        
        pagination = query.order_by(ReturnRequest.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        requests_data = []
        for req in pagination.items:
            requests_data.append({
                'id': req.id,
                'invoice_id': req.invoice_id,
                'auction_id': req.auction_id,
                'auction_name': req.auction.item_name if req.auction else None,
                'user_id': req.user_id,
                'username': req.user.username if req.user else None,
                'reason': req.reason,
                'description': req.description,
                'status': req.status,
                'admin_notes': req.admin_notes,
                'created_at': req.created_at.isoformat(),
                'updated_at': req.updated_at.isoformat(),
                'processed_at': req.processed_at.isoformat() if req.processed_at else None
            })
        
        return jsonify({
            'return_requests': requests_data,
            'total': pagination.total,
            'page': page,
            'per_page': per_page,
            'pages': pagination.pages
        }), 200
    except Exception as e:
        print(f"Error in get_all_return_requests: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to get return requests: {str(e)}'}), 500

@app.route('/api/admin/return-requests/<int:request_id>', methods=['PUT'])
@admin_required
def update_return_request(request_id):
    """Update return request status (admin only)"""
    try:
        return_request = ReturnRequest.query.get_or_404(request_id)
        
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        status = data.get('status')
        admin_notes = sanitize_string(data.get('admin_notes', ''), max_length=2000) if data.get('admin_notes') else None
        
        if status:
            valid_statuses = ['pending', 'approved', 'rejected', 'processing', 'completed', 'cancelled']
            if status not in valid_statuses:
                return jsonify({'error': f'Invalid status. Valid statuses: {", ".join(valid_statuses)}'}), 400
            
            return_request.status = status
            return_request.updated_at = datetime.now(timezone.utc)
            
            # Set processed_at if status changed from pending
            if return_request.status != 'pending' and not return_request.processed_at:
                return_request.processed_at = datetime.now(timezone.utc)
        
        if admin_notes is not None:
            return_request.admin_notes = admin_notes
        
        db.session.commit()
        
        return jsonify({
            'message': 'Return request updated successfully',
            'id': return_request.id,
            'status': return_request.status,
            'admin_notes': return_request.admin_notes
        }), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error in update_return_request: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to update return request: {str(e)}'}), 500

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
        
        # Get winner name if auction has ended and has a winner
        winner_name = None
        if auction.winner_id and auction.winner:
            winner_name = auction.winner.username
        
        # Use auction ID as item code if item_code field doesn't exist
        # Format: ZUBID-{auction_id}
        item_code = f"ZUBID-{auction.id:06d}"
        
        auctions_list.append({
            'id': auction.id,
            'item_name': auction.item_name,
            'item_code': item_code,
            'seller': auction.seller.username,
            'current_bid': auction.current_bid,
            'status': auction.status,
            'end_time': auction.end_time.isoformat(),
            'bid_count': len(unique_bidders),  # Count unique bidders, not total bids
            'featured': auction.featured,
            'winner_name': winner_name
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
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        auction = Auction.query.get_or_404(auction_id)
        
        if 'status' in data:
            if data['status'] not in ['active', 'ended', 'cancelled']:
                return jsonify({'error': 'Invalid status. Must be "active", "ended", or "cancelled"'}), 400
            auction.status = data['status']
        
        if 'featured' in data:
            auction.featured = bool(data['featured'])
        
        db.session.commit()
        return jsonify({'message': 'Auction updated successfully'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error updating auction: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to update auction: {str(e)}'}), 500

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

# ==========================================
# ADMIN NOTIFICATIONS ENDPOINTS
# ==========================================

@app.route('/api/admin/notifications', methods=['GET'])
@admin_required
def get_admin_notifications():
    """Get all notifications (admin view)"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 50, type=int)

    notifications = Notification.query.order_by(Notification.created_at.desc()).paginate(page=page, per_page=per_page)

    result = []
    for notif in notifications.items:
        user = User.query.get(notif.user_id)
        result.append({
            'id': str(notif.id),
            'user_id': notif.user_id,
            'user_name': user.username if user else 'Unknown',
            'title': notif.title,
            'message': notif.message,
            'type': notif.type,
            'is_read': notif.is_read,
            'auction_id': notif.auction_id,
            'created_at': notif.created_at.isoformat() if notif.created_at else None
        })

    return jsonify({
        'notifications': result,
        'total': notifications.total,
        'pages': notifications.pages,
        'current_page': page
    }), 200

@app.route('/api/admin/notifications/send', methods=['POST'])
@admin_required
def send_admin_notification():
    """Send notification to specific user or all users"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400

        title = data.get('title', '').strip()
        message = data.get('message', '').strip()
        notification_type = data.get('type', 'info')
        user_id = data.get('user_id')  # None means all users

        if not title or not message:
            return jsonify({'error': 'Title and message are required'}), 400

        if user_id:
            # Send to specific user
            user = User.query.get(user_id)
            if not user:
                return jsonify({'error': 'User not found'}), 404

            create_notification(
                user_id=user_id,
                title=title,
                message=message,
                notification_type=notification_type
            )
            return jsonify({'message': f'Notification sent to {user.username}'}), 200
        else:
            # Send to all users
            users = User.query.filter_by(role='user').all()
            count = 0
            for user in users:
                create_notification(
                    user_id=user.id,
                    title=title,
                    message=message,
                    notification_type=notification_type
                )
                count += 1

            return jsonify({'message': f'Notification sent to {count} users'}), 200

    except Exception as e:
        app.logger.error(f"Error sending notification: {e}")
        return jsonify({'error': 'Failed to send notification'}), 500

@app.route('/api/admin/notifications/stats', methods=['GET'])
@admin_required
def get_notification_stats():
    """Get notification statistics"""
    total = Notification.query.count()
    unread = Notification.query.filter_by(is_read=False).count()
    today = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    today_count = Notification.query.filter(Notification.created_at >= today).count()

    # Count by type
    type_counts = {}
    for notif_type in ['outbid', 'won', 'ending', 'info', 'system']:
        type_counts[notif_type] = Notification.query.filter_by(type=notif_type).count()

    return jsonify({
        'total': total,
        'unread': unread,
        'today': today_count,
        'by_type': type_counts
    }), 200

@app.route('/api/admin/scan-images', methods=['GET'])
@admin_required
def scan_corrupted_images():
    """Scan database for corrupted/malformed image URLs"""
    import re

    def check_url(url, source_type, source_id, field_name):
        """Check if URL is corrupted and return issue details"""
        if not url:
            return None

        url = str(url).strip()
        issues = []

        # Check for truncated cloudinary domain
        if 'cloudinar' in url.lower() and 'cloudinary' not in url.lower():
            issues.append('Truncated Cloudinary domain')

        # Check for double URL (https://...https://)
        # Double URL with slash: site.com/https://
        if re.search(r'https?://[^/]+/https?://', url):
            issues.append('Double URL detected (with slash)')

        # Double URL without slash: site.comhttps://
        if re.search(r'https?://[^/]+\.[a-z]+https?://', url.lower()):
            issues.append('Double URL detected (without slash)')

        # Check for leading slash before protocol
        if url.startswith('/http://') or url.startswith('/https://'):
            issues.append('Leading slash before protocol')

        # Check for very short URLs that should be longer
        if url.startswith('http') and len(url) < 20:
            issues.append('URL too short')

        # Check for malformed URLs (missing TLD)
        if url.startswith('http') and not re.search(r'https?://[^/]+\.[a-z]{2,}', url.lower()):
            issues.append('Malformed domain (missing TLD)')

        # Check for truncated file extensions
        if re.search(r'\.(jp|pn|gi|we|sv)$', url.lower()):
            issues.append('Truncated file extension')

        if issues:
            return {
                'source_type': source_type,
                'source_id': source_id,
                'field': field_name,
                'url': url[:200],  # Truncate for display
                'issues': issues
            }
        return None

    corrupted = []

    # Scan Auction table
    auctions = Auction.query.all()
    for auction in auctions:
        # Check featured_image_url
        issue = check_url(auction.featured_image_url, 'auction', auction.id, 'featured_image_url')
        if issue:
            issue['item_name'] = auction.item_name
            corrupted.append(issue)

        # Check qr_code_url
        issue = check_url(auction.qr_code_url, 'auction', auction.id, 'qr_code_url')
        if issue:
            issue['item_name'] = auction.item_name
            corrupted.append(issue)

    # Scan Image table
    images = Image.query.all()
    for img in images:
        issue = check_url(img.url, 'image', img.id, 'url')
        if issue:
            issue['auction_id'] = img.auction_id
            corrupted.append(issue)

    # Scan User profile images
    users = User.query.all()
    for user in users:
        issue = check_url(user.profile_image, 'user', user.id, 'profile_image')
        if issue:
            issue['username'] = user.username
            corrupted.append(issue)

    return jsonify({
        'total_corrupted': len(corrupted),
        'corrupted_urls': corrupted
    }), 200

@app.route('/api/admin/fix-image/<source_type>/<int:source_id>', methods=['PUT'])
@admin_required
def fix_corrupted_image(source_type, source_id):
    """Fix or clear a corrupted image URL"""
    try:
        data = request.json or {}
        new_url = data.get('new_url', '')  # Empty string to clear
        field = data.get('field', 'url')

        if source_type == 'auction':
            auction = Auction.query.get(source_id)
            if not auction:
                return jsonify({'error': 'Auction not found'}), 404

            if field == 'featured_image_url':
                auction.featured_image_url = new_url if new_url else None
            elif field == 'qr_code_url':
                auction.qr_code_url = new_url if new_url else None
            else:
                return jsonify({'error': f'Unknown field: {field}'}), 400

            db.session.commit()
            return jsonify({'message': f'Auction {source_id} {field} updated'}), 200

        elif source_type == 'image':
            image = Image.query.get(source_id)
            if not image:
                return jsonify({'error': 'Image not found'}), 404

            if new_url:
                image.url = new_url
                db.session.commit()
                return jsonify({'message': f'Image {source_id} URL updated'}), 200
            else:
                # Delete the image record if clearing
                db.session.delete(image)
                db.session.commit()
                return jsonify({'message': f'Image {source_id} deleted'}), 200

        elif source_type == 'user':
            user = User.query.get(source_id)
            if not user:
                return jsonify({'error': 'User not found'}), 404

            user.profile_image = new_url if new_url else None
            db.session.commit()
            return jsonify({'message': f'User {source_id} profile image updated'}), 200

        else:
            return jsonify({'error': f'Unknown source type: {source_type}'}), 400

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/admin/delete-corrupted-images', methods=['POST'])
@admin_required
def delete_all_corrupted_images():
    """Delete all corrupted image records (use with caution)"""
    import re

    def is_corrupted(url):
        if not url:
            return False
        url = str(url).strip()

        # Check for common corruption patterns
        if 'cloudinar' in url.lower() and 'cloudinary' not in url.lower():
            return True
        # Double URL with slash: site.com/https://
        if re.search(r'https?://[^/]+/https?://', url):
            return True
        # Double URL without slash: site.comhttps://
        if re.search(r'https?://[^/]+\.[a-z]+https?://', url.lower()):
            return True
        if url.startswith('/http://') or url.startswith('/https://'):
            return True
        if url.startswith('http') and len(url) < 20:
            return True
        if re.search(r'\.(jp|pn|gi|we|sv)$', url.lower()):
            return True
        return False

    deleted_count = 0
    fixed_count = 0

    # Fix/clear corrupted auction URLs
    auctions = Auction.query.all()
    for auction in auctions:
        if is_corrupted(auction.featured_image_url):
            auction.featured_image_url = None
            fixed_count += 1
        if is_corrupted(auction.qr_code_url):
            auction.qr_code_url = None
            fixed_count += 1

    # Delete corrupted image records
    images = Image.query.all()
    for img in images:
        if is_corrupted(img.url):
            db.session.delete(img)
            deleted_count += 1

    # Clear corrupted user profile images
    users = User.query.all()
    for user in users:
        if is_corrupted(user.profile_image):
            user.profile_image = None
            fixed_count += 1

    db.session.commit()

    return jsonify({
        'message': 'Corrupted images cleaned up',
        'deleted_image_records': deleted_count,
        'cleared_url_fields': fixed_count
    }), 200

@app.route('/api/admin/categories', methods=['POST'])
@admin_required
def create_category_admin():
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        category_name = sanitize_string(data.get('name', ''), max_length=100)
        if not category_name:
            return jsonify({'error': 'Category name is required'}), 400
        
        if Category.query.filter_by(name=category_name).first():
            return jsonify({'error': 'Category already exists'}), 400
        
        category_description = sanitize_string(data.get('description', ''), max_length=500)
        category = Category(name=category_name, description=category_description)
        db.session.add(category)
        db.session.commit()
        # Clear categories cache after modification
        _get_cached_categories.cache_clear()
        return jsonify({'message': 'Category created', 'id': category.id}), 201
    except Exception as e:
        db.session.rollback()
        print(f"Error creating category: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to create category: {str(e)}'}), 500

@app.route('/api/admin/categories/<int:category_id>', methods=['PUT'])
@admin_required
def update_category_admin(category_id):
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        category = Category.query.get_or_404(category_id)
        
        if 'name' in data:
            if not data['name'] or not data['name'].strip():
                return jsonify({'error': 'Category name cannot be empty'}), 400
            
            # Check if new name conflicts with existing category
            existing = Category.query.filter_by(name=data['name'].strip()).first()
            if existing and existing.id != category_id:
                return jsonify({'error': 'Category name already exists'}), 400
            
            category.name = data['name'].strip()
        
        if 'description' in data:
            category.description = data.get('description', '').strip()
        
        db.session.commit()
        # Clear categories cache after modification
        _get_cached_categories.cache_clear()
        return jsonify({'message': 'Category updated successfully'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error updating category: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to update category: {str(e)}'}), 500

@app.route('/api/admin/categories/<int:category_id>', methods=['DELETE'])
@admin_required
def delete_category_admin(category_id):
    try:
        category = Category.query.get_or_404(category_id)
        
        # Check if category has associated auctions
        auctions_count = Auction.query.filter_by(category_id=category_id).count()
        if auctions_count > 0:
            return jsonify({
                'error': f'Cannot delete category. There are {auctions_count} auction(s) using this category. Please reassign or delete those auctions first.'
            }), 400
        
        db.session.delete(category)
        db.session.commit()
        # Clear categories cache after modification
        _get_cached_categories.cache_clear()
        return jsonify({'message': 'Category deleted successfully'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error deleting category: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to delete category: {str(e)}'}), 500

# Initialize database
def init_db():
    with app.app_context():
        db.create_all()
        print("Database tables created/verified successfully!")
        
        # Verify Invoice table exists
        try:
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            if 'invoice' not in tables:
                print("WARNING: Invoice table not found! Creating it now...")
                db.create_all()
        except Exception as e:
            print(f"Note: Could not verify tables: {e}")
        
        # Check and add market_price column if missing
        try:
            from sqlalchemy import inspect, text
            inspector = inspect(db.engine)
            columns = [col['name'] for col in inspector.get_columns('auction')]
            if 'market_price' not in columns:
                print("Adding market_price column to Auction table...")
                try:
                    with db.engine.connect() as conn:
                        with conn.begin():
                            # Use REAL for SQLite, FLOAT for others
                            if 'sqlite' in str(db.engine.url).lower():
                                conn.execute(text("ALTER TABLE auction ADD COLUMN market_price REAL"))
                            else:
                                conn.execute(text("ALTER TABLE auction ADD COLUMN market_price FLOAT"))
                    print("[OK] market_price column added successfully!")
                except Exception as e:
                    print(f"[WARNING] Could not add market_price column automatically: {e}")
                    print("Please run: python migrate_market_price.py")
            else:
                print("[OK] market_price column exists")
        except Exception as e:
            print(f"Note: Could not check/add market_price column: {e}")
        
        # Ensure ReturnRequest table exists
        try:
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            if 'return_request' not in tables:
                print("Creating ReturnRequest table...")
                db.create_all()
                print("[OK] ReturnRequest table created!")
            else:
                print("[OK] ReturnRequest table exists")
            
            # Ensure SocialShare and Cashback tables exist
            if 'social_share' not in tables:
                print("Creating SocialShare table...")
                db.create_all()
                print("[OK] SocialShare table created!")
            if 'cashback' not in tables:
                print("Creating Cashback table...")
                db.create_all()
                print("[OK] Cashback table created!")
        except Exception as e:
            print(f"Note: Could not verify tables: {e}")
        
        # Check and add featured_image_url column if missing
        try:
            inspector = inspect(db.engine)
            columns = [col['name'] for col in inspector.get_columns('auction')]
            if 'featured_image_url' not in columns:
                print("Adding featured_image_url column to Auction table...")
                try:
                    with db.engine.connect() as conn:
                        with conn.begin():
                            if 'sqlite' in str(db.engine.url).lower():
                                conn.execute(text("ALTER TABLE auction ADD COLUMN featured_image_url VARCHAR(500)"))
                            else:
                                conn.execute(text("ALTER TABLE auction ADD COLUMN featured_image_url VARCHAR(500)"))
                    print("[OK] featured_image_url column added successfully!")
                except Exception as e:
                    print(f"[WARNING] Could not add featured_image_url column automatically: {e}")
            else:
                print("[OK] featured_image_url column exists")
        except Exception as e:
            print(f"Note: Could not check/add featured_image_url column: {e}")
        
        # Check and add real_price column if missing
        try:
            inspector = inspect(db.engine)
            columns = [col['name'] for col in inspector.get_columns('auction')]
            if 'real_price' not in columns:
                print("Adding real_price column to Auction table...")
                try:
                    with db.engine.connect() as conn:
                        with conn.begin():
                            # Use REAL for SQLite, FLOAT for others
                            if 'sqlite' in str(db.engine.url).lower():
                                conn.execute(text("ALTER TABLE auction ADD COLUMN real_price REAL"))
                            else:
                                conn.execute(text("ALTER TABLE auction ADD COLUMN real_price FLOAT"))
                    print("[OK] real_price column added successfully!")
                except Exception as e:
                    print(f"[WARNING] Could not add real_price column automatically: {e}")
            else:
                print("[OK] real_price column exists")
        except Exception as e:
            print(f"Note: Could not check/add real_price column: {e}")

        # Check and add cashback_amount column to Invoice table if missing
        try:
            inspector = inspect(db.engine)
            invoice_columns = [col['name'] for col in inspector.get_columns('invoice')]
            if 'cashback_amount' not in invoice_columns:
                print("Adding cashback_amount column to Invoice table...")
                try:
                    with db.engine.connect() as conn:
                        with conn.begin():
                            if 'sqlite' in str(db.engine.url).lower():
                                conn.execute(text("ALTER TABLE invoice ADD COLUMN cashback_amount REAL DEFAULT 0"))
                            else:
                                conn.execute(text("ALTER TABLE invoice ADD COLUMN cashback_amount FLOAT DEFAULT 0"))
                    print("[OK] cashback_amount column added successfully!")
                except Exception as e:
                    print(f"[WARNING] Could not add cashback_amount column automatically: {e}")
            else:
                print("[OK] cashback_amount column exists in Invoice table")
        except Exception as e:
            print(f"Note: Could not check/add cashback_amount column: {e}")

        # Check and add additional Auction columns if missing
        try:
            inspector = inspect(db.engine)
            auction_columns = [col['name'] for col in inspector.get_columns('auction')]

            new_auction_columns = {
                'item_condition': 'VARCHAR(50)',
                'qr_code_url': 'VARCHAR(500)',
                'video_url': 'VARCHAR(500)',
            }

            added_auction_cols = 0
            for col_name, col_type in new_auction_columns.items():
                if col_name not in auction_columns:
                    try:
                        with db.engine.connect() as conn:
                            with conn.begin():
                                conn.execute(text(f"ALTER TABLE auction ADD COLUMN {col_name} {col_type}"))
                        added_auction_cols += 1
                    except Exception as e:
                        print(f"[WARNING] Could not add {col_name} column to Auction table: {e}")

            if added_auction_cols > 0:
                print(f"[OK] Added {added_auction_cols} new columns to Auction table")
            else:
                print("[OK] Auction table columns up to date")
        except Exception as e:
            print(f"Note: Could not check/add additional Auction columns: {e}")

        # Check and add new User table columns if missing
        try:
            inspector = inspect(db.engine)
            user_columns = [col['name'] for col in inspector.get_columns('user')]

            new_user_columns = {
                'profile_photo': 'VARCHAR(500)',
                'first_name': 'VARCHAR(50)',
                'last_name': 'VARCHAR(50)',
                'bio': 'TEXT',
                'company': 'VARCHAR(100)',
                'website': 'VARCHAR(255)',
                'city': 'VARCHAR(100)',
                'country': 'VARCHAR(100)',
                'postal_code': 'VARCHAR(20)',
                'phone_verified': 'BOOLEAN DEFAULT FALSE',
                'email_verified': 'BOOLEAN DEFAULT FALSE',
                'is_active': 'BOOLEAN DEFAULT TRUE',
                'last_login': 'TIMESTAMP',
                'login_count': 'INTEGER DEFAULT 0',
                'balance': 'FLOAT DEFAULT 0.0',
                'fcm_token': 'VARCHAR(255)'
            }

            added_count = 0
            for col_name, col_type in new_user_columns.items():
                if col_name not in user_columns:
                    try:
                        with db.engine.connect() as conn:
                            with conn.begin():
                                conn.execute(text(f"ALTER TABLE user ADD COLUMN {col_name} {col_type}"))
                        added_count += 1
                    except Exception as e:
                        print(f"[WARNING] Could not add {col_name} column: {e}")

            if added_count > 0:
                print(f"[OK] Added {added_count} new columns to User table")
            else:
                print("[OK] User table columns up to date")
        except Exception as e:
            print(f"Note: Could not check/add User columns: {e}")

        # Ensure NavigationMenu and UserPreference tables exist
        try:
            inspector = inspect(db.engine)
            tables = inspector.get_table_names()
            if 'navigation_menu' not in tables:
                print("Creating NavigationMenu table...")
                db.create_all()
                print("[OK] NavigationMenu table created!")
            if 'user_preference' not in tables:
                print("Creating UserPreference table...")
                db.create_all()
                print("[OK] UserPreference table created!")
            if 'password_reset_token' not in tables:
                print("Creating PasswordResetToken table...")
                db.create_all()
                print("[OK] PasswordResetToken table created!")
        except Exception as e:
            print(f"Note: Could not verify new tables: {e}")

        # CRITICAL: Check and add missing Category table columns
        # This fixes the "column category.parent_id does not exist" error
        try:
            inspector = inspect(db.engine)
            category_columns = [col['name'] for col in inspector.get_columns('category')]

            new_category_columns = {
                'parent_id': 'INTEGER',
                'icon_url': 'VARCHAR(500)',
                'image_url': 'VARCHAR(500)',
                'is_active': 'BOOLEAN DEFAULT TRUE',
                'sort_order': 'INTEGER DEFAULT 0',
                'created_at': 'TIMESTAMP',
                'updated_at': 'TIMESTAMP',
            }

            added_cat_cols = 0
            for col_name, col_type in new_category_columns.items():
                if col_name not in category_columns:
                    try:
                        with db.engine.connect() as conn:
                            with conn.begin():
                                conn.execute(text(f"ALTER TABLE category ADD COLUMN {col_name} {col_type}"))
                        print(f"[OK] Added {col_name} column to Category table")
                        added_cat_cols += 1
                    except Exception as e:
                        if "already exists" not in str(e).lower() and "duplicate" not in str(e).lower():
                            print(f"[WARNING] Could not add {col_name} column to Category: {e}")

            if added_cat_cols > 0:
                # Set default values for existing rows
                try:
                    with db.engine.connect() as conn:
                        with conn.begin():
                            conn.execute(text("UPDATE category SET is_active = TRUE WHERE is_active IS NULL"))
                            conn.execute(text("UPDATE category SET sort_order = id WHERE sort_order IS NULL"))
                            conn.execute(text("UPDATE category SET created_at = NOW() WHERE created_at IS NULL"))
                            conn.execute(text("UPDATE category SET updated_at = NOW() WHERE updated_at IS NULL"))
                    print(f"[OK] Category table migration complete - added {added_cat_cols} columns")
                except Exception as e:
                    print(f"[WARNING] Could not set default values for Category: {e}")
            else:
                print("[OK] Category table columns up to date")
        except Exception as e:
            print(f"Note: Could not check/add Category columns: {e}")

        # Create default categories
        # Use raw SQL to avoid ORM issues during migration
        try:
            with db.engine.connect() as conn:
                result = conn.execute(text("SELECT COUNT(*) FROM category"))
                cat_count = result.scalar()
        except:
            cat_count = 0

        if cat_count == 0:
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
        # SECURITY: Only create default admin in development, require env vars in production
        # Use raw SQL to avoid ORM issues with new columns
        try:
            admin = User.query.filter_by(username='admin').first()
        except Exception as e:
            print(f"[WARNING] Could not query User table with ORM: {e}")
            print("[INFO] Attempting to check admin user with raw SQL...")
            try:
                with db.engine.connect() as conn:
                    result = conn.execute(text("SELECT id FROM user WHERE username = 'admin'"))
                    admin_exists = result.fetchone() is not None
                if admin_exists:
                    print("[OK] Admin user already exists")
                    admin = True  # Set to True to skip creation
                else:
                    admin = None
            except Exception as e2:
                print(f"[ERROR] Could not check for admin user: {e2}")
                admin = True  # Assume exists to avoid errors

        if not admin:
            # Use defaults for development, require env vars for production (but don't crash)
            admin_username = os.getenv('ADMIN_USERNAME', 'admin')
            admin_password = os.getenv('ADMIN_PASSWORD', 'Admin123!@#')
            admin_email = os.getenv('ADMIN_EMAIL', 'admin@zubid.com')

            if not admin_username or not admin_password or not admin_email:
                print("WARNING: Skipping admin user creation. Set ADMIN_USERNAME, ADMIN_PASSWORD, and ADMIN_EMAIL to create admin.")
            else:
                admin = User(
                    username=admin_username,
                    email=admin_email,
                    password_hash=generate_password_hash(admin_password),
                    id_number=os.getenv('ADMIN_ID_NUMBER', 'ADMIN001'),
                    birth_date=date(1990, 1, 1),  # Default birth date for admin
                    address='Admin Address',  # Required field
                    phone='+1-000-0000',  # Required field
                    role='admin'
                )
                db.session.add(admin)
                db.session.commit()
                # Security: Never log credentials
                if not is_production:
                    print(f"Admin user created: username='{admin_username}'")
                    print("IMPORTANT: Change the default password immediately!")
                else:
                    print("Admin user created. Please change the default password immediately via profile settings.")
        
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

        # Initialize default navigation menu items if none exist
        if NavigationMenu.query.count() == 0:
            print("Creating default navigation menu...")

            # Home
            home_menu = NavigationMenu(
                name='home',
                label='Home',
                url='index.html',
                icon='home',
                order=1,
                is_active=True,
                requires_auth=False
            )
            db.session.add(home_menu)

            # My Account (parent dropdown - requires auth)
            my_account_menu = NavigationMenu(
                name='my_account',
                label='My Account',
                url=None,
                icon='user',
                order=2,
                is_active=True,
                requires_auth=True
            )
            db.session.add(my_account_menu)
            db.session.flush()

            # My Account children
            profile_menu = NavigationMenu(
                name='profile',
                label='Profile',
                url='profile.html',
                parent_id=my_account_menu.id,
                order=1,
                is_active=True,
                requires_auth=True
            )
            db.session.add(profile_menu)

            my_bids_menu = NavigationMenu(
                name='my_bids',
                label='My Bids',
                url='my-bids.html',
                parent_id=my_account_menu.id,
                order=2,
                is_active=True,
                requires_auth=True
            )
            db.session.add(my_bids_menu)

            payments_menu = NavigationMenu(
                name='payments',
                label='Payments',
                url='payments.html',
                parent_id=my_account_menu.id,
                order=3,
                is_active=True,
                requires_auth=True
            )
            db.session.add(payments_menu)

            return_requests_menu = NavigationMenu(
                name='return_requests',
                label='Return Requests',
                url='return-requests.html',
                parent_id=my_account_menu.id,
                order=4,
                is_active=True,
                requires_auth=True
            )
            db.session.add(return_requests_menu)

            # Info (parent dropdown)
            info_menu = NavigationMenu(
                name='info',
                label='Info',
                url=None,
                icon='info',
                order=3,
                is_active=True,
                requires_auth=False
            )
            db.session.add(info_menu)
            db.session.flush()

            # Info children
            how_to_bid_menu = NavigationMenu(
                name='how_to_bid',
                label='How to Bid',
                url='how-to-bid.html',
                parent_id=info_menu.id,
                order=1,
                is_active=True,
                requires_auth=False
            )
            db.session.add(how_to_bid_menu)

            contact_menu = NavigationMenu(
                name='contact',
                label='Contact Us',
                url='contact-us.html',
                parent_id=info_menu.id,
                order=2,
                is_active=True,
                requires_auth=False
            )
            db.session.add(contact_menu)

            db.session.commit()
            print("[OK] Default navigation menu created!")

        print("Database initialized successfully!")

# Initialize database on module load (for gunicorn/production)
# Skip auto-init if we're just importing for testing or if explicitly disabled
if not os.getenv('SKIP_DB_INIT', '').lower() == 'true':
    try:
        init_db()
    except Exception as e:
        print(f"Warning: Database initialization failed during import: {e}")
        print("Database will be initialized on first request if needed.")

@app.route('/api/user/payments', methods=['GET'])
@login_required
def get_user_payments():
    """Get all invoices for the current user"""
    try:
        # Check if Invoice table exists
        try:
            Invoice.query.first()
        except Exception as e:
            print(f"Invoice table error: {e}")
            return jsonify({'error': 'Database table not initialized. Please restart the backend server.'}), 500
        
        # Get all won auctions for the user
        won_auctions = Auction.query.filter_by(winner_id=session['user_id'], status='ended').all()
        
        invoices = []
        for auction in won_auctions:
            # Check if invoice exists, if not create one
            invoice = Invoice.query.filter_by(auction_id=auction.id, user_id=session['user_id']).first()
            
            if not invoice:
                # Calculate fees
                item_price = auction.current_bid or auction.starting_bid
                bid_fee = item_price * 0.01  # 1% bid fee
                delivery_fee = calculate_delivery_fee(session['user_id'])
                total_amount = item_price + bid_fee + delivery_fee
                
                # Generate QR code if auction doesn't have one
                if not auction.qr_code_url:
                    qr_code_url = generate_qr_code(auction.id, auction.item_name, item_price)
                    if qr_code_url:
                        auction.qr_code_url = qr_code_url
                        db.session.flush()
                
                # Create invoice
                invoice = Invoice(
                    auction_id=auction.id,
                    user_id=session['user_id'],
                    item_price=item_price,
                    bid_fee=bid_fee,
                    delivery_fee=delivery_fee,
                    total_amount=total_amount,
                    payment_status='pending'
                )
                db.session.add(invoice)
                db.session.commit()
            
            # Get auction details
            auction_data = {
                'id': auction.id,
                'item_name': auction.item_name,
                'description': auction.description,
                'image_url': auction.images[0].url if auction.images else None,
                'end_time': auction.end_time.isoformat() if auction.end_time else None,
                'qr_code_url': auction.qr_code_url
            }
            
            # Check for pending cashback that can be applied
            pending_cashback = Cashback.query.filter_by(
                user_id=session['user_id'],
                auction_id=auction.id,
                status='pending'
            ).first()

            invoices.append({
                'id': invoice.id,
                'auction': auction_data,
                'item_price': invoice.item_price,
                'bid_fee': invoice.bid_fee,
                'delivery_fee': invoice.delivery_fee,
                'cashback_amount': invoice.cashback_amount or 0,
                'pending_cashback': pending_cashback.amount if pending_cashback else 0,
                'total_amount': invoice.total_amount,
                'payment_method': invoice.payment_method,
                'payment_status': invoice.payment_status,
                'created_at': invoice.created_at.isoformat(),
                'paid_at': invoice.paid_at.isoformat() if invoice.paid_at else None,
                'qr_code_url': auction.qr_code_url
            })
        
        return jsonify(invoices), 200
    except Exception as e:
        print(f"Error in get_user_payments: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to get payments: {str(e)}'}), 500

@app.route('/api/payments/<int:invoice_id>/pay', methods=['POST'])
@login_required
def process_payment(invoice_id):
    """Process payment for an invoice"""
    try:
        invoice = Invoice.query.get_or_404(invoice_id)

        # Verify invoice belongs to user
        if invoice.user_id != session['user_id']:
            return jsonify({'error': 'Unauthorized access'}), 403

        # Check if already paid
        if invoice.payment_status == 'paid':
            return jsonify({'error': 'Invoice already paid'}), 400

        data = request.json
        payment_method = data.get('payment_method')

        # Supported payment methods
        supported_methods = ['cash_on_delivery', 'fib', 'stripe', 'paypal']
        if payment_method not in supported_methods:
            return jsonify({'error': f'Invalid payment method. Supported: {", ".join(supported_methods)}'}), 400

        invoice.payment_method = payment_method

        # Process payment based on method
        if payment_method == 'cash_on_delivery':
            invoice.payment_status = 'pending'  # Will be marked as paid when delivered
            db.session.commit()
            return jsonify({
                'message': 'Payment method set to Cash on Delivery',
                'invoice_id': invoice.id,
                'payment_status': invoice.payment_status,
                'note': 'Payment will be collected upon delivery'
            }), 200
        elif payment_method == 'fib':
            # Process FIB payment with money request
            fib_name = data.get('fib_name')
            fib_phone = data.get('fib_phone')

            if not fib_name or not fib_phone:
                return jsonify({'error': 'FIB payment requires name and phone number'}), 400

            # Clean phone number
            fib_phone_clean = fib_phone.replace(' ', '').replace('-', '')

            # Validate Iraqi phone format
            import re
            if not re.match(r'^07[3-9]\d{8}$', fib_phone_clean):
                return jsonify({'error': 'Invalid Iraqi phone number format'}), 400

            # Process FIB money request
            payment_result = process_fib_money_request(invoice, fib_name, fib_phone_clean)

            if payment_result['success']:
                invoice.payment_status = 'pending'  # Waiting for user to accept money request
                invoice.payment_notes = f"FIB Money Request sent to {fib_phone_clean} ({fib_name})"
                db.session.commit()
                return jsonify({
                    'message': 'Money request sent successfully!',
                    'invoice_id': invoice.id,
                    'payment_status': invoice.payment_status,
                    'request_id': payment_result.get('request_id'),
                    'fib_phone': fib_phone_clean,
                    'amount': invoice.total_amount,
                    'note': 'Please check your FIB app to approve the payment request'
                }), 200
            else:
                return jsonify({
                    'error': payment_result.get('error', 'Failed to send money request'),
                    'invoice_id': invoice.id
                }), 400
        else:
            # Process other online payments (stripe, paypal)
            payment_result = process_fib_payment(invoice)
            if payment_result['success']:
                invoice.payment_status = 'paid'
                invoice.paid_at = datetime.now(timezone.utc)
                db.session.commit()
                return jsonify({
                    'message': 'Payment processed successfully',
                    'invoice_id': invoice.id,
                    'payment_status': invoice.payment_status,
                    'transaction_id': payment_result.get('transaction_id')
                }), 200
            else:
                invoice.payment_status = 'failed'
                db.session.commit()
                return jsonify({
                    'error': payment_result.get('error', 'Payment failed'),
                    'invoice_id': invoice.id,
                    'payment_status': invoice.payment_status
                }), 400

    except Exception as e:
        print(f"Error in process_payment: {str(e)}")
        import traceback
        traceback.print_exc()
        db.session.rollback()
        return jsonify({'error': f'Failed to process payment: {str(e)}'}), 500


# ZUBID FIB Account Number to receive payments
ZUBID_FIB_NUMBER = '07715625156'

def process_fib_money_request(invoice, customer_name, customer_phone):
    """Send FIB money request to customer's phone number"""
    try:
        # In production, this would integrate with FIB's actual API
        # FIB API endpoint would be something like:
        # POST https://api.fib.iq/v1/money-request
        # {
        #     "receiver_phone": ZUBID_FIB_NUMBER,
        #     "sender_phone": customer_phone,
        #     "amount": invoice.total_amount,
        #     "currency": "IQD",
        #     "description": f"ZUBID Invoice #{invoice.id}",
        #     "reference": f"INV-{invoice.id}"
        # }

        # For now, simulate the money request
        import random
        request_id = f"FIB-REQ-{invoice.id}-{random.randint(100000, 999999)}"

        print(f"[FIB] Money Request Sent:")
        print(f"  - To Phone: {customer_phone}")
        print(f"  - Customer Name: {customer_name}")
        print(f"  - Amount: {invoice.total_amount} IQD")
        print(f"  - ZUBID Account: {ZUBID_FIB_NUMBER}")
        print(f"  - Invoice ID: {invoice.id}")
        print(f"  - Request ID: {request_id}")

        return {
            'success': True,
            'request_id': request_id,
            'message': f'Money request sent to {customer_phone}'
        }

    except Exception as e:
        print(f"[FIB] Error sending money request: {str(e)}")
        return {
            'success': False,
            'error': str(e)
        }

# Return Request APIs
@app.route('/api/return-requests', methods=['GET'])
@login_required
def get_return_requests():
    """Get return requests for the current user"""
    try:
        return_requests = ReturnRequest.query.filter_by(user_id=session['user_id']).order_by(ReturnRequest.created_at.desc()).all()
        
        requests_data = []
        for req in return_requests:
            requests_data.append({
                'id': req.id,
                'invoice_id': req.invoice_id,
                'auction_id': req.auction_id,
                'auction_name': req.auction.item_name if req.auction else None,
                'reason': req.reason,
                'description': req.description,
                'status': req.status,
                'admin_notes': req.admin_notes,
                'created_at': req.created_at.isoformat(),
                'updated_at': req.updated_at.isoformat(),
                'processed_at': req.processed_at.isoformat() if req.processed_at else None
            })
        
        return jsonify(requests_data), 200
    except Exception as e:
        print(f"Error in get_return_requests: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to get return requests: {str(e)}'}), 500

@app.route('/api/return-requests', methods=['POST'])
@login_required
def create_return_request():
    """Create a new return request"""
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        invoice_id = data.get('invoice_id')
        reason = sanitize_string(data.get('reason', ''), max_length=500)
        description = sanitize_string(data.get('description', ''), max_length=2000)
        
        if not invoice_id:
            return jsonify({'error': 'Invoice ID is required'}), 400
        if not reason:
            return jsonify({'error': 'Return reason is required'}), 400
        
        # Verify invoice belongs to user
        invoice = Invoice.query.get_or_404(invoice_id)
        if invoice.user_id != session['user_id']:
            return jsonify({'error': 'Unauthorized access'}), 403
        
        # Check if invoice is paid
        if invoice.payment_status != 'paid':
            return jsonify({'error': 'Can only request return for paid invoices'}), 400
        
        # Check if return request already exists for this invoice
        existing_request = ReturnRequest.query.filter_by(invoice_id=invoice_id, user_id=session['user_id']).first()
        if existing_request:
            if existing_request.status in ['pending', 'approved', 'processing']:
                return jsonify({'error': 'Return request already exists for this invoice'}), 400
        
        # Create return request
        return_request = ReturnRequest(
            invoice_id=invoice_id,
            auction_id=invoice.auction_id,
            user_id=session['user_id'],
            reason=reason,
            description=description,
            status='pending'
        )
        db.session.add(return_request)
        db.session.commit()
        
        return jsonify({
            'message': 'Return request created successfully',
            'id': return_request.id,
            'status': return_request.status
        }), 201
    except Exception as e:
        db.session.rollback()
        print(f"Error in create_return_request: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to create return request: {str(e)}'}), 500

@app.route('/api/return-requests/<int:request_id>', methods=['GET'])
@login_required
def get_return_request(request_id):
    """Get a specific return request"""
    try:
        return_request = ReturnRequest.query.get_or_404(request_id)
        
        # Verify user owns the request or is admin
        if return_request.user_id != session['user_id']:
            # Check if user is admin
            user = User.query.get(session['user_id'])
            if not user or user.role != 'admin':
                return jsonify({'error': 'Unauthorized access'}), 403
        
        return jsonify({
            'id': return_request.id,
            'invoice_id': return_request.invoice_id,
            'auction_id': return_request.auction_id,
            'auction_name': return_request.auction.item_name if return_request.auction else None,
            'reason': return_request.reason,
            'description': return_request.description,
            'status': return_request.status,
            'admin_notes': return_request.admin_notes,
            'created_at': return_request.created_at.isoformat(),
            'updated_at': return_request.updated_at.isoformat(),
            'processed_at': return_request.processed_at.isoformat() if return_request.processed_at else None
        }), 200
    except Exception as e:
        print(f"Error in get_return_request: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to get return request: {str(e)}'}), 500

@app.route('/api/return-requests/<int:request_id>/cancel', methods=['POST'])
@login_required
def cancel_return_request(request_id):
    """Cancel a return request (user only)"""
    try:
        return_request = ReturnRequest.query.get_or_404(request_id)
        
        # Verify user owns the request
        if return_request.user_id != session['user_id']:
            return jsonify({'error': 'Unauthorized access'}), 403
        
        # Only allow cancellation if status is pending
        if return_request.status != 'pending':
            return jsonify({'error': f'Cannot cancel return request with status: {return_request.status}'}), 400
        
        return_request.status = 'cancelled'
        return_request.updated_at = datetime.now(timezone.utc)
        db.session.commit()
        
        return jsonify({
            'message': 'Return request cancelled successfully',
            'id': return_request.id,
            'status': return_request.status
        }), 200
    except Exception as e:
        db.session.rollback()
        print(f"Error in cancel_return_request: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to cancel return request: {str(e)}'}), 500

def process_fib_payment(invoice):
    """Process FIB payment gateway (simulated)"""
    # Use payment gateway module if available
    try:
        from payment_gateways import get_configured_gateway
        
        # Try to get configured gateway
        gateway = get_configured_gateway()
        
        if gateway:
            # Use configured gateway
            user = invoice.user
            user_data = {
                'email': user.email if user else '',
                'name': user.username if user else '',
                'id': user.id if user else None
            }
            
            result = gateway.process_payment(
                amount=invoice.total_amount,
                currency='IQD',  # Default currency, can be configured
                invoice_id=invoice.id,
                user_data=user_data
            )
            return result
        else:
            # Fallback to FIB simulation if no gateway configured
            # In production, integrate with actual FIB payment gateway API
            return {'success': True, 'transaction_id': f'FIB-{invoice.id}-{int(datetime.now().timestamp())}'}
    except ImportError:
        # Payment gateway module not available, use simulation
        return {'success': True, 'transaction_id': f'FIB-{invoice.id}-{int(datetime.now().timestamp())}'}
    except Exception as e:
        app.logger.error(f"Payment processing error: {str(e)}")
        return {'success': False, 'error': str(e)}

# Social Sharing and Cashback APIs
@app.route('/api/user/social-share', methods=['POST'])
@login_required
def record_social_share():
    """Record a social media share for cashback tracking"""
    try:
        if not request.json:
            return jsonify({'error': 'No JSON data received'}), 400
        
        data = request.json
        platform = data.get('platform', '').lower().strip()
        auction_id = data.get('auction_id')
        
        # Validate platform
        if not platform:
            return jsonify({'error': 'Platform is required'}), 400
        
        valid_platforms = ['facebook', 'twitter', 'linkedin', 'whatsapp', 'telegram', 'reddit', 'tiktok', 'instagram', 'snapchat']
        if platform not in valid_platforms:
            return jsonify({'error': f'Invalid platform. Must be one of: {", ".join(valid_platforms)}'}), 400
        
        # Validate auction_id
        if auction_id is None:
            return jsonify({'error': 'auction_id is required'}), 400
        
        try:
            auction_id = int(auction_id)
        except (ValueError, TypeError):
            return jsonify({'error': 'Invalid auction_id. Must be a number'}), 400
        
        # Get user_id from session
        if 'user_id' not in session:
            return jsonify({'error': 'User not authenticated'}), 401
        
        user_id = session['user_id']
        
        # Validate user exists
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Validate auction exists
        auction = Auction.query.get(auction_id)
        if not auction:
            return jsonify({'error': 'Auction not found'}), 404
        
        # Check if user already shared on this platform for this auction
        existing_share = SocialShare.query.filter_by(
            user_id=user_id,
            auction_id=auction_id,
            platform=platform
        ).first()
        
        if existing_share:
            total_shares = SocialShare.query.filter_by(user_id=user_id, auction_id=auction_id).count()
            is_winner = auction.winner_id == user_id and auction.status == 'ended'
            return jsonify({
                'message': 'Share already recorded',
                'shares_count': total_shares,
                'cashback_eligible': total_shares >= 3 and is_winner,
                'cashback_created': False
            }), 200
        
        # Create new share record
        try:
            social_share = SocialShare(
                user_id=user_id,
                auction_id=auction_id,
                platform=platform,
                verified=True  # For now, we trust the client. In production, verify via API
            )
            db.session.add(social_share)
            db.session.flush()
        except Exception as e:
            db.session.rollback()
            error_msg = str(e)
            # Check if it's a unique constraint violation
            if 'unique' in error_msg.lower() or 'duplicate' in error_msg.lower():
                # Share already exists, return success
                total_shares = SocialShare.query.filter_by(user_id=user_id, auction_id=auction_id).count()
                is_winner = auction.winner_id == user_id and auction.status == 'ended'
                return jsonify({
                    'message': 'Share already recorded',
                    'shares_count': total_shares,
                    'cashback_eligible': total_shares >= 3 and is_winner,
                    'cashback_created': False
                }), 200
            app.logger.error(f'Error creating social share record: {error_msg}')
            import traceback
            app.logger.error(traceback.format_exc())
            return jsonify({'error': f'Failed to create share record: {error_msg}'}), 500
        
        # Count total shares for this user and auction
        total_shares = SocialShare.query.filter_by(user_id=user_id, auction_id=auction_id).count()
        
        # Check if user has won the auction
        is_winner = auction.winner_id == user_id and auction.status == 'ended'
        
        # If user has shared 3 times and is a winner, create cashback
        cashback_created = False
        if total_shares >= 3 and is_winner:
            # Check if cashback already exists
            existing_cashback = Cashback.query.filter_by(
                user_id=user_id,
                auction_id=auction_id,
                status='pending'
            ).first()
            
            if not existing_cashback:
                try:
                    cashback = Cashback(
                        user_id=user_id,
                        auction_id=auction_id,
                        amount=5.0,
                        status='pending'
                    )
                    db.session.add(cashback)
                    cashback_created = True
                except Exception as e:
                    app.logger.error(f'Error creating cashback: {str(e)}')
                    # Don't fail the share record if cashback creation fails
                    cashback_created = False
        
        try:
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            app.logger.error(f'Error committing social share: {str(e)}')
            return jsonify({'error': f'Failed to save share: {str(e)}'}), 500
        
        return jsonify({
            'message': 'Share recorded successfully',
            'shares_count': total_shares,
            'cashback_eligible': total_shares >= 3 and is_winner,
            'cashback_created': cashback_created,
            'remaining_shares': max(0, 3 - total_shares)
        }), 201
        
    except Exception as e:
        db.session.rollback()
        import traceback
        error_trace = traceback.format_exc()
        app.logger.error(f'Error recording social share: {str(e)}\n{error_trace}')
        # Return more detailed error in development
        error_msg = str(e)
        if app.config.get('DEBUG', False):
            return jsonify({'error': f'Failed to record share: {error_msg}', 'trace': error_trace}), 500
        return jsonify({'error': 'Failed to record share. Please try again.'}), 500

@app.route('/api/user/social-shares', methods=['GET'])
@login_required
def get_social_shares():
    """Get social shares for current user"""
    try:
        auction_id = request.args.get('auction_id', type=int)
        user_id = session['user_id']
        
        query = SocialShare.query.filter_by(user_id=user_id)
        if auction_id:
            query = query.filter_by(auction_id=auction_id)
        
        shares = query.all()
        
        # Group by auction
        shares_by_auction = {}
        for share in shares:
            key = share.auction_id or 'general'
            if key not in shares_by_auction:
                shares_by_auction[key] = []
            shares_by_auction[key].append({
                'platform': share.platform,
                'shared_at': share.shared_at.isoformat(),
                'verified': share.verified
            })
        
        return jsonify({
            'shares': shares_by_auction,
            'total_shares': len(shares)
        }), 200
        
    except Exception as e:
        app.logger.error(f'Error getting social shares: {str(e)}')
        return jsonify({'error': f'Failed to get shares: {str(e)}'}), 500

@app.route('/api/user/cashback', methods=['GET'])
@login_required
def get_user_cashback():
    """Get cashback information for current user"""
    try:
        user_id = session['user_id']
        auction_id = request.args.get('auction_id', type=int)
        
        query = Cashback.query.filter_by(user_id=user_id)
        if auction_id:
            query = query.filter_by(auction_id=auction_id)
        
        cashbacks = query.order_by(Cashback.created_at.desc()).all()
        
        total_cashback = sum(cb.amount for cb in cashbacks if cb.status == 'processed')
        pending_cashback = sum(cb.amount for cb in cashbacks if cb.status == 'pending')
        
        return jsonify({
            'cashbacks': [{
                'id': cb.id,
                'auction_id': cb.auction_id,
                'amount': cb.amount,
                'status': cb.status,
                'created_at': cb.created_at.isoformat(),
                'processed_at': cb.processed_at.isoformat() if cb.processed_at else None
            } for cb in cashbacks],
            'total_cashback': total_cashback,
            'pending_cashback': pending_cashback
        }), 200
        
    except Exception as e:
        app.logger.error(f'Error getting cashback: {str(e)}')
        return jsonify({'error': f'Failed to get cashback: {str(e)}'}), 500

@app.route('/api/user/cashback/<int:cashback_id>/process', methods=['POST'])
@login_required
def process_cashback(cashback_id):
    """Process cashback (apply to invoice or account balance)"""
    try:
        cashback = Cashback.query.get_or_404(cashback_id)
        
        # Verify ownership
        if cashback.user_id != session['user_id']:
            return jsonify({'error': 'Unauthorized'}), 403
        
        if cashback.status != 'pending':
            return jsonify({'error': f'Cashback already {cashback.status}'}), 400
        
        # Process cashback - apply to invoice if exists
        if cashback.auction_id:
            invoice = Invoice.query.filter_by(
                auction_id=cashback.auction_id,
                user_id=cashback.user_id
            ).first()

            if invoice:
                # Apply cashback to invoice total and track the amount
                invoice.cashback_amount = (invoice.cashback_amount or 0) + cashback.amount
                invoice.total_amount = max(0, invoice.total_amount - cashback.amount)

        cashback.status = 'processed'
        cashback.processed_at = datetime.now(timezone.utc)
        db.session.commit()
        
        return jsonify({
            'message': 'Cashback processed successfully',
            'cashback': {
                'id': cashback.id,
                'amount': cashback.amount,
                'status': cashback.status
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        app.logger.error(f'Error processing cashback: {str(e)}')
        return jsonify({'error': f'Failed to process cashback: {str(e)}'}), 500

# User Preferences APIs
@app.route('/api/user/preferences', methods=['GET'])
@login_required
def get_user_preferences():
    """Get user preferences"""
    try:
        user_id = session['user_id']
        preferences = UserPreference.query.filter_by(user_id=user_id).first()

        if not preferences:
            # Create default preferences
            preferences = UserPreference(user_id=user_id)
            db.session.add(preferences)
            db.session.commit()

        return jsonify({
            'theme': preferences.theme,
            'language': preferences.language,
            'notifications_enabled': preferences.notifications_enabled,
            'email_notifications': preferences.email_notifications,
            'bid_alerts': preferences.bid_alerts,
            'auction_reminders': preferences.auction_reminders,
            'newsletter_subscribed': preferences.newsletter_subscribed,
            'currency': preferences.currency,
            'timezone': preferences.timezone,
            'items_per_page': preferences.items_per_page,
            'default_view': preferences.default_view
        }), 200

    except Exception as e:
        app.logger.error(f'Error getting preferences: {str(e)}')
        return jsonify({'error': f'Failed to get preferences: {str(e)}'}), 500

@app.route('/api/user/preferences', methods=['PUT'])
@login_required
def update_user_preferences():
    """Update user preferences"""
    try:
        user_id = session['user_id']
        data = request.json

        preferences = UserPreference.query.filter_by(user_id=user_id).first()
        if not preferences:
            preferences = UserPreference(user_id=user_id)
            db.session.add(preferences)

        # Update preferences
        if 'theme' in data:
            if data['theme'] not in ['light', 'dark', 'auto']:
                return jsonify({'error': 'Invalid theme value'}), 400
            preferences.theme = data['theme']

        if 'language' in data:
            if data['language'] not in ['en', 'ku', 'ar']:
                return jsonify({'error': 'Invalid language value'}), 400
            preferences.language = data['language']

        if 'notifications_enabled' in data:
            preferences.notifications_enabled = bool(data['notifications_enabled'])

        if 'email_notifications' in data:
            preferences.email_notifications = bool(data['email_notifications'])

        if 'bid_alerts' in data:
            preferences.bid_alerts = bool(data['bid_alerts'])

        if 'auction_reminders' in data:
            preferences.auction_reminders = bool(data['auction_reminders'])

        if 'newsletter_subscribed' in data:
            preferences.newsletter_subscribed = bool(data['newsletter_subscribed'])

        if 'currency' in data:
            preferences.currency = sanitize_string(data['currency'], max_length=10)

        if 'timezone' in data:
            preferences.timezone = sanitize_string(data['timezone'], max_length=50)

        if 'items_per_page' in data:
            items_per_page = int(data['items_per_page'])
            if items_per_page < 5 or items_per_page > 100:
                return jsonify({'error': 'Items per page must be between 5 and 100'}), 400
            preferences.items_per_page = items_per_page

        if 'default_view' in data:
            if data['default_view'] not in ['grid', 'list']:
                return jsonify({'error': 'Invalid default view value'}), 400
            preferences.default_view = data['default_view']

        preferences.updated_at = datetime.now(timezone.utc)
        db.session.commit()

        return jsonify({'message': 'Preferences updated successfully'}), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f'Error updating preferences: {str(e)}')
        return jsonify({'error': f'Failed to update preferences: {str(e)}'}), 500

# Navigation Menu APIs
@app.route('/api/navigation/menu', methods=['GET'])
def get_navigation_menu():
    """Get navigation menu structure"""
    try:
        # Get query parameters
        include_inactive = request.args.get('include_inactive', 'false').lower() == 'true'
        user_role = None

        # Check if user is logged in to filter by role
        if 'user_id' in session:
            user = User.query.get(session['user_id'])
            if user:
                user_role = user.role

        # Build query
        query = NavigationMenu.query.filter_by(parent_id=None)
        if not include_inactive:
            query = query.filter_by(is_active=True)

        # Get top-level menu items
        menu_items = query.order_by(NavigationMenu.order).all()

        def build_menu_tree(item):
            """Recursively build menu tree"""
            # Check if user has access to this menu item
            if item.requires_auth and 'user_id' not in session:
                return None
            if item.requires_role and (not user_role or user_role != item.requires_role):
                return None

            menu_dict = {
                'id': item.id,
                'name': item.name,
                'label': item.label,
                'url': item.url,
                'icon': item.icon,
                'target': item.target,
                'css_class': item.css_class,
                'requires_auth': item.requires_auth,
                'children': []
            }

            # Get children
            children_query = NavigationMenu.query.filter_by(parent_id=item.id)
            if not include_inactive:
                children_query = children_query.filter_by(is_active=True)

            children = children_query.order_by(NavigationMenu.order).all()
            for child in children:
                child_dict = build_menu_tree(child)
                if child_dict:  # Only add if user has access
                    menu_dict['children'].append(child_dict)

            return menu_dict

        # Build menu structure
        menu_structure = []
        for item in menu_items:
            item_dict = build_menu_tree(item)
            if item_dict:  # Only add if user has access
                menu_structure.append(item_dict)

        return jsonify({
            'menu': menu_structure,
            'user_authenticated': 'user_id' in session,
            'user_role': user_role
        }), 200

    except Exception as e:
        app.logger.error(f'Error getting navigation menu: {str(e)}')
        return jsonify({'error': f'Failed to get menu: {str(e)}'}), 500

@app.route('/api/navigation/menu', methods=['POST'])
@login_required
def create_menu_item():
    """Create new navigation menu item (admin only)"""
    try:
        user = User.query.get(session['user_id'])
        if user.role != 'admin':
            return jsonify({'error': 'Admin access required'}), 403

        data = request.json
        if not data or not data.get('name') or not data.get('label'):
            return jsonify({'error': 'Name and label are required'}), 400

        menu_item = NavigationMenu(
            name=sanitize_string(data['name'], max_length=100),
            label=sanitize_string(data['label'], max_length=100),
            url=sanitize_string(data.get('url', ''), max_length=500) if data.get('url') else None,
            icon=sanitize_string(data.get('icon', ''), max_length=100) if data.get('icon') else None,
            parent_id=data.get('parent_id'),
            order=data.get('order', 0),
            is_active=data.get('is_active', True),
            requires_auth=data.get('requires_auth', False),
            requires_role=data.get('requires_role'),
            target=data.get('target', '_self'),
            css_class=sanitize_string(data.get('css_class', ''), max_length=100) if data.get('css_class') else None
        )

        db.session.add(menu_item)
        db.session.commit()

        return jsonify({
            'message': 'Menu item created successfully',
            'menu_item': {
                'id': menu_item.id,
                'name': menu_item.name,
                'label': menu_item.label,
                'url': menu_item.url
            }
        }), 201

    except Exception as e:
        db.session.rollback()
        app.logger.error(f'Error creating menu item: {str(e)}')
        return jsonify({'error': f'Failed to create menu item: {str(e)}'}), 500

@app.route('/api/navigation/menu/<int:menu_id>', methods=['PUT'])
@login_required
def update_menu_item(menu_id):
    """Update navigation menu item (admin only)"""
    try:
        user = User.query.get(session['user_id'])
        if user.role != 'admin':
            return jsonify({'error': 'Admin access required'}), 403

        menu_item = NavigationMenu.query.get_or_404(menu_id)
        data = request.json

        if 'name' in data:
            menu_item.name = sanitize_string(data['name'], max_length=100)
        if 'label' in data:
            menu_item.label = sanitize_string(data['label'], max_length=100)
        if 'url' in data:
            menu_item.url = sanitize_string(data['url'], max_length=500) if data['url'] else None
        if 'icon' in data:
            menu_item.icon = sanitize_string(data['icon'], max_length=100) if data['icon'] else None
        if 'parent_id' in data:
            menu_item.parent_id = data['parent_id']
        if 'order' in data:
            menu_item.order = data['order']
        if 'is_active' in data:
            menu_item.is_active = data['is_active']
        if 'requires_auth' in data:
            menu_item.requires_auth = data['requires_auth']
        if 'requires_role' in data:
            menu_item.requires_role = data['requires_role']
        if 'target' in data:
            menu_item.target = data['target']
        if 'css_class' in data:
            menu_item.css_class = sanitize_string(data['css_class'], max_length=100) if data['css_class'] else None

        menu_item.updated_at = datetime.now(timezone.utc)
        db.session.commit()

        return jsonify({'message': 'Menu item updated successfully'}), 200

    except Exception as e:
        db.session.rollback()
        app.logger.error(f'Error updating menu item: {str(e)}')
        return jsonify({'error': f'Failed to update menu item: {str(e)}'}), 500

# Serve frontend static files (for same-origin requests to fix cookie issues)
@app.route('/')
def serve_index():
    return send_from_directory(frontend_dir, 'index.html')

@app.route('/favicon.ico')
def serve_favicon():
    """Serve favicon - returns a simple SVG icon to prevent 404 errors"""
    # Simple blue "Z" favicon for ZUBID
    svg_favicon = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
        <rect width="32" height="32" rx="6" fill="#1259c3"/>
        <text x="16" y="24" font-family="Arial,sans-serif" font-size="22" font-weight="bold" fill="white" text-anchor="middle">Z</text>
    </svg>'''
    response = make_response(svg_favicon)
    response.headers['Content-Type'] = 'image/svg+xml'
    response.headers['Cache-Control'] = 'public, max-age=86400'  # Cache for 1 day
    return response

@app.route('/<path:filename>')
def serve_static(filename):
    # Don't serve API routes or uploads as static files (they have their own routes)
    if filename.startswith('api/') or filename.startswith('uploads/'):
        return jsonify({'error': 'Not found'}), 404
    # Try to serve the file from frontend directory
    try:
        return send_from_directory(frontend_dir, filename)
    except:
        # If file not found, return 404
        return jsonify({'error': 'File not found'}), 404

# ==========================================
# ADMIN: Database Reset Endpoint (Development Only)
# ==========================================
@app.route('/api/admin/reset-database', methods=['POST'])
def reset_database():
    """Reset database - clears all users except admin. Development only."""
    try:
        # Get secret key from request
        data = request.get_json() or {}
        secret = data.get('secret', '')

        # Simple secret check (in production, use proper admin auth)
        expected_secret = os.getenv('ADMIN_RESET_SECRET', 'zubid-reset-2025')
        if secret != expected_secret:
            return jsonify({'error': 'Unauthorized'}), 401

        # Delete all users except admin
        deleted_users = User.query.filter(User.role != 'admin').delete()

        # Delete all bids
        deleted_bids = Bid.query.delete()

        # Delete password reset tokens
        try:
            PasswordResetToken.query.delete()
        except:
            pass

        db.session.commit()

        return jsonify({
            'message': 'Database reset successful',
            'deleted_users': deleted_users,
            'deleted_bids': deleted_bids
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Reset failed: {str(e)}'}), 500

@app.route('/api/debug/db-status', methods=['GET'])
def debug_db_status():
    """Debug endpoint to check database connection status"""
    try:
        from sqlalchemy import text

        # Test basic connection
        result = db.session.execute(text('SELECT 1')).scalar()

        # Get pool status if available
        pool_info = {}
        try:
            engine = db.engine
            pool = engine.pool
            pool_info = {
                'pool_class': str(type(pool).__name__),
                'pool_size': getattr(pool, 'size', 'N/A'),
                'checked_in': getattr(pool, 'checkedin', 'N/A'),
                'checked_out': getattr(pool, 'checkedout', 'N/A'),
                'overflow': getattr(pool, 'overflow', 'N/A'),
                'invalid': getattr(pool, 'invalid', 'N/A'),
            }
        except Exception as e:
            pool_info = {'error': str(e)}

        return jsonify({
            'status': 'connected',
            'test_query': result,
            'pool_info': pool_info,
            'database_uri': app.config['SQLALCHEMY_DATABASE_URI'].split('@')[0] + '@***'  # Hide credentials
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e),
            'database_uri': app.config['SQLALCHEMY_DATABASE_URI'].split('@')[0] + '@***'
        }), 500


@app.route('/api/admin/run-migrations', methods=['POST', 'GET'])
def run_migrations_endpoint():
    """Run database migrations to add missing columns - safe to call multiple times"""
    try:
        results = []

        # Add missing columns to User table
        user_columns_to_add = {
            'balance': 'FLOAT DEFAULT 0.0',
            'fcm_token': 'VARCHAR(255)',
            'profile_photo': 'VARCHAR(500)',
            'first_name': 'VARCHAR(50)',
            'last_name': 'VARCHAR(50)',
            'bio': 'TEXT',
            'company': 'VARCHAR(100)',
            'website': 'VARCHAR(255)',
            'city': 'VARCHAR(100)',
            'country': 'VARCHAR(100)',
            'postal_code': 'VARCHAR(20)',
            'phone_verified': 'BOOLEAN DEFAULT FALSE',
            'email_verified': 'BOOLEAN DEFAULT FALSE',
            'is_active': 'BOOLEAN DEFAULT TRUE',
            'last_login': 'TIMESTAMP',
            'login_count': 'INTEGER DEFAULT 0'
        }

        for col_name, col_type in user_columns_to_add.items():
            try:
                with db.engine.connect() as conn:
                    with conn.begin():
                        # PostgreSQL syntax with IF NOT EXISTS
                        conn.execute(text(f'ALTER TABLE "user" ADD COLUMN IF NOT EXISTS {col_name} {col_type}'))
                results.append(f"User.{col_name}: OK")
            except Exception as e:
                if "already exists" in str(e).lower() or "duplicate" in str(e).lower():
                    results.append(f"User.{col_name}: already exists")
                else:
                    results.append(f"User.{col_name}: ERROR - {str(e)}")

        return jsonify({
            'message': 'Migrations completed',
            'results': results
        }), 200

    except Exception as e:
        return jsonify({'error': f'Migration failed: {str(e)}'}), 500


@app.route('/api/admin/init-database', methods=['POST', 'GET'])
def init_database_endpoint():
    """Initialize database tables - useful for first deployment"""
    try:
        with app.app_context():
            db.create_all()

            # Create default categories if none exist
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

            # Create admin user if doesn't exist
            admin = User.query.filter_by(username='admin').first()
            if not admin:
                from werkzeug.security import generate_password_hash
                admin = User(
                    username='admin',
                    email='admin@zubid.com',
                    password_hash=generate_password_hash('Admin123!@#'),
                    role='admin',
                    id_number='ADMIN001',
                    birth_date=datetime(1990, 1, 1),
                    phone='+1234567890',
                    address='ZUBID HQ'
                )
                db.session.add(admin)
                db.session.commit()

        return jsonify({
            'message': 'Database initialized successfully',
            'tables_created': True
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Init failed: {str(e)}'}), 500

if __name__ == '__main__':
    init_db()

    # Configuration from environment variables
    # SECURITY: Never run in debug mode in production
    flask_env = os.getenv('FLASK_ENV', 'development').lower()
    is_prod = flask_env == 'production'
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'

    # Force debug mode OFF in production
    if is_prod and debug_mode:
        import warnings
        warnings.warn("Debug mode is disabled in production for security!", UserWarning)
        debug_mode = False

    port = int(os.getenv('PORT', '5000'))
    host = os.getenv('HOST', '0.0.0.0')  # Changed to bind to all interfaces

    print("\n" + "="*50)
    print("ZUBID Backend Server Starting...")
    print("="*50)
    print(f"Server will run on: http://{host}:{port}")
    print(f"Frontend: http://{host}:{port}/index.html")
    print(f"API Test: http://{host}:{port}/api/test")
    print(f"Environment: {flask_env.upper()}")
    print(f"Debug mode: {'ON' if debug_mode else 'OFF'}")
    if is_prod:
        print("⚠️  PRODUCTION MODE - Security features enabled")
    print("="*50 + "\n")
    
    try:
        app.run(debug=debug_mode, port=port, host=host, use_reloader=debug_mode)
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

