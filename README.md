# ZUBID - Modern Auction Bid System 🎯

A full-stack modern auction bidding platform with real-time updates, auto-bidding, and comprehensive auction management.

> **✨ Latest Features:** Biometric Authentication, Modern Glassmorphism UI, Enhanced Security

## Features

### Frontend (JavaScript)
- **Modern UI**: Glassmorphism design, gradient effects, smooth animations
- **Homepage**: Featured auctions carousel, search bar, category navigation
- **Auction Listing**: Grid/list view toggle, filters (category, price, time), sorting options, pagination
- **Auction Detail**: High-quality images with zoom, detailed descriptions, real-time countdown timer, bidding interface with auto-bid option, bid history
- **User Account**: Profile management, view own auctions and bids
- **Create Auction**: Easy auction creation form with image support
- **Responsive Design**: Mobile-friendly interface that works on all devices
- **Biometric Authentication**: Fingerprint/face capture for secure registration

### Backend (Python Flask)
- **User Management**: Registration with ID verification, biometric authentication, profile management
- **Auction Management**: Create, edit, delete auctions with categories
- **Bidding System**: Place bids, auto-bidding, bid validation, real-time bid updates
- **Search & Filter**: Full-text search, category filtering, sorting options
- **Real-time Updates**: Polling-based real-time bid updates
- **Security**: Session-based authentication, password hashing, biometric data storage

## Technology Stack

### Frontend
- HTML5
- CSS3 (Modern, responsive design)
- Vanilla JavaScript (ES6+)
- Fetch API for HTTP requests

### Backend
- Python 3.8+
- Flask (Web framework)
- SQLAlchemy (ORM)
- SQLite (Database)
- Flask-CORS (CORS handling)

## Project Structure

```
ZUBID/
├── backend/
│   ├── app.py              # Main Flask application
│   └── requirements.txt    # Python dependencies
│   └── auction.db         # SQLite database (created on first run)
├── frontend/
│   ├── index.html         # Homepage
│   ├── auctions.html      # Auction listing page
│   ├── auction-detail.html # Auction detail page
│   ├── create-auction.html # Create auction page
│   ├── profile.html        # User profile page
│   ├── api.js             # API client functions
│   ├── app.js             # Main application logic
│   ├── auctions.js        # Auction listing logic
│   ├── auction-detail.js  # Auction detail logic
│   ├── create-auction.js  # Create auction logic
│   ├── profile.js         # Profile management logic
│   └── styles.css         # Main stylesheet
└── README.md              # This file
```

## Setup Instructions

### Prerequisites
- Python 3.8 or higher
- pip (Python package installer)
- A modern web browser
- A simple HTTP server for frontend (or use a web server)

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
   
   **Note:** The default installation uses SQLite (no additional setup needed).
   For PostgreSQL, install `psycopg2-binary`. For MySQL, install `pymysql`.

3. Run the Flask application:
   ```bash
   python app.py
   ```

   The backend server will start on `http://localhost:5000`

4. The database will be automatically initialized with default categories on first run.

### Frontend Setup

#### Option 1: Using Python HTTP Server
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Start a simple HTTP server:
   ```bash
   # Python 3
   python -m http.server 8080
   
   # Or using Python 2
   python -m SimpleHTTPServer 8080
   ```

3. Open your browser and navigate to:
   ```
   http://localhost:8080
   ```

#### Option 2: Using Node.js http-server
1. Install http-server globally:
   ```bash
   npm install -g http-server
   ```

2. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

3. Start the server:
   ```bash
   http-server -p 8080
   ```

4. Open your browser and navigate to:
   ```
   http://localhost:8080
   ```

## Usage

### Getting Started

1. **Start the Backend**: Run `python app.py` in the backend directory
2. **Start the Frontend**: Use one of the methods above to serve the frontend files
3. **Open the Application**: Navigate to `http://localhost:8080` in your browser

### Creating an Account

1. Click "Sign Up" in the navigation bar
2. Fill in the registration form (username, email, password are required)
3. Click "Sign Up" to create your account

### Creating an Auction

1. Login to your account
2. Click "Sell" in the navigation bar
3. Fill in the auction details:
   - Item name and description
   - Category
   - Starting bid and bid increment
   - End date and time
   - Image URLs (optional, one per line)
4. Optionally check "Feature this auction" to feature it on homepage
5. Click "Create Auction"

### Bidding on an Auction

1. Browse auctions on the homepage or auctions page
2. Click on an auction to view details
3. Enter your bid amount (must meet minimum bid requirement)
4. Optionally enable auto-bid with a maximum limit
5. Click "Place Bid"
6. Watch real-time updates as other users bid

### Viewing Your Profile

1. Login and click "Profile" in the navigation bar
2. View your account information, auctions, and bids
3. Edit your profile by clicking "Edit Profile"

## API Endpoints

### User Management
- `POST /api/register` - Register new user
- `POST /api/login` - User login
- `POST /api/logout` - User logout
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile

### Auctions
- `GET /api/auctions` - Get all auctions (with filters)
- `GET /api/auctions/<id>` - Get auction details
- `POST /api/auctions` - Create new auction
- `PUT /api/auctions/<id>` - Update auction
- `GET /api/featured` - Get featured auctions
- `GET /api/user/auctions` - Get user's auctions

### Bidding
- `GET /api/auctions/<id>/bids` - Get bid history
- `POST /api/auctions/<id>/bids` - Place a bid
- `GET /api/user/bids` - Get user's bids

### Categories
- `GET /api/categories` - Get all categories

## Database Schema

- **Users**: User accounts with authentication
- **Categories**: Auction categories
- **Auctions**: Auction items with details
- **Bids**: Bid records with timestamps
- **Images**: Auction images

## Security Features

- Password hashing using Werkzeug
- Session-based authentication
- CSRF protection ready (can be added)
- Input validation on all forms
- SQL injection protection via SQLAlchemy ORM

## Future Enhancements

- WebSocket support for real-time bidding (instead of polling)
- Email/SMS notifications for outbid situations
- Payment gateway integration
- Image upload functionality (currently uses URLs)
- Advanced search with filters
- Auction watchlist/favorites
- Rating and review system
- SSL/HTTPS support
- Admin panel for auction management

## Troubleshooting

### Backend won't start
- Ensure Python 3.8+ is installed
- Check that all dependencies are installed: `pip install -r requirements.txt`
- Verify port 5000 is not in use

### Frontend can't connect to backend
- Ensure backend is running on `http://localhost:5000`
- Check browser console for CORS errors
- Verify API_BASE_URL in `frontend/api.js` matches backend URL

### Database errors
- Delete `backend/auction.db` to reset the database
- Restart the backend to reinitialize

### Images not showing
- Ensure image URLs are valid and accessible
- Check browser console for image loading errors
- Use placeholder images if needed

## License

This project is provided as-is for educational and demonstration purposes.

## Support

For issues or questions, please check the code comments or create an issue in the repository.

---
**Project Index & Developer Quickstart**

- See `PROJECTS_INDEX.md` at repository root for a concise project map and run instructions.

- Quick PowerShell developer steps:
   - Create & activate venv:
      ```powershell
      python -m venv .venv
      .\.venv\Scripts\Activate.ps1
      ```
   - Install backend deps:
      ```powershell
      pip install -r backend/requirements.txt
      ```
   - Start backend (dev):
      ```powershell
      python backend/app.py
      # or from repo root: .\start-backend.bat
      ```
   - Serve frontend (separate terminal):
      ```powershell
      cd frontend
      python -m http.server 8000
      ```

- Run packaged checks (from `backend/`):
   - `python test_imports.py` — import/config checks
   - `python test_backend.py` — quick import/app check
   - `python test_market_price.py` — schema check for `market_price`
   - `python test_production.py` — full unittest suite (may fail; see notes below)

Notes from a quick check run:
- `test_imports.py` and `test_backend.py` succeeded.
- `test_market_price.py` confirmed the `market_price` column exists.
- `test_production.py` failed with multiple `IntegrityError` exceptions (`NOT NULL constraint failed: auction.seller_id`).
   - Likely cause: test setup inserts an `Auction` before the `User` id is available; tests should commit `User` and `Category` first or set the relationship instead of `seller_id`.
   - I can prepare a PR to adjust the test setup or add helper commits if you'd like.

