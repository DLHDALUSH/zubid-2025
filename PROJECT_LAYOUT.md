# ZUBID Project Layout

## 📁 Project Structure

```
ZUBID/
├── 📂 backend/                    # Python Flask Backend
│   ├── app.py                    # Main Flask application (API server)
│   ├── requirements.txt          # Python dependencies
│   ├── test_backend.py           # Backend testing script
│   ├── __pycache__/              # Python cache (auto-generated)
│   └── instance/                 # Database instance folder
│       └── auction.db            # SQLite database (created on first run)
│
├── 📂 frontend/                   # Frontend Web Application
│   ├── 📄 index.html             # Homepage
│   ├── 📄 auctions.html          # Auction listing page
│   ├── 📄 auction-detail.html    # Auction detail page
│   ├── 📄 create-auction.html    # Create auction page
│   ├── 📄 profile.html           # User profile page
│   ├── 📄 admin.html             # Admin dashboard
│   ├── 📄 admin-auctions.html    # Admin auctions management
│   ├── 📄 admin-users.html       # Admin users management
│   ├── 📄 admin-categories.html  # Admin categories management
│   │
│   ├── 📄 api.js                 # API client functions
│   ├── 📄 app.js                 # Main application logic
│   ├── 📄 auctions.js             # Auction listing logic
│   ├── 📄 auction-detail.js      # Auction detail logic
│   ├── 📄 create-auction.js       # Create auction logic
│   ├── 📄 profile.js              # Profile management logic
│   ├── 📄 profile-standalone.js  # Standalone profile script
│   ├── 📄 admin.js                # Admin dashboard logic
│   ├── 📄 admin-auctions.js      # Admin auctions logic
│   ├── 📄 admin-users.js         # Admin users logic
│   ├── 📄 admin-categories.js     # Admin categories logic
│   │
│   ├── 📄 styles.css             # Main stylesheet
│   └── 📄 admin.css               # Admin stylesheet
│
├── 📄 README.md                   # Main project documentation
├── 📄 COLLABORATION_GUIDE.md      # Collaboration guidelines
├── 📄 CURSOR_WORKFLOW.md         # Cursor workflow guide
├── 📄 share-project.md            # Project sharing guide
│
├── 🔧 start-backend.bat          # Start backend server (Windows)
├── 🔧 start-frontend.bat         # Start frontend server (Windows)
└── 🔧 start-both.bat             # Start both servers (Windows)
```

## 📊 File Count Summary

### Backend Files: 4
- `app.py` - Main Flask application
- `requirements.txt` - Dependencies
- `test_backend.py` - Testing script
- `__pycache__/` - Python cache (auto-generated)

### Frontend Files: 20
- **HTML Pages:** 9 files
- **JavaScript Files:** 11 files
- **CSS Files:** 2 files

### Documentation: 4 files
- `README.md`
- `COLLABORATION_GUIDE.md`
- `CURSOR_WORKFLOW.md`
- `share-project.md`

### Scripts: 3 batch files
- `start-backend.bat`
- `start-frontend.bat`
- `start-both.bat`

## 🎯 Key Components

### Backend (Flask API)
- **app.py** - Main Flask server with REST API endpoints
  - User authentication (register, login, logout)
  - Auction management (CRUD operations)
  - Bidding system
  - Admin APIs
  - Database models (User, Auction, Bid, Category, Image)

### Frontend (Vanilla JavaScript)
- **index.html** - Homepage with featured auctions carousel
- **auctions.html** - Browse all auctions with filters
- **auction-detail.html** - View auction details and place bids
- **create-auction.html** - Create new auctions
- **profile.html** - User profile and account management
- **admin.html** - Admin dashboard for managing users, auctions, categories

### API Client
- **api.js** - Centralized API request functions
  - `UserAPI` - User authentication
  - `AuctionAPI` - Auction operations
  - `BidAPI` - Bidding operations
  - `CategoryAPI` - Category operations

## 🚀 Quick Start

1. **Start Backend:**
   ```bash
   # Option 1: Use batch file
   start-backend.bat
   
   # Option 2: Manual
   cd backend
   pip install -r requirements.txt
   python app.py
   ```

2. **Start Frontend:**
   ```bash
   # Option 1: Use batch file
   start-frontend.bat
   
   # Option 2: Manual
   cd frontend
   python -m http.server 8080
   ```

3. **Start Both:**
   ```bash
   start-both.bat
   ```

4. **Access:**
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:5000
   - API Test: http://localhost:5000/api/test

## 📝 Notes

- Database (`auction.db`) is created automatically on first backend run
- Default admin user is created: `admin` / `admin123`
- All unnecessary files have been removed
- Code uses modern `datetime.now(timezone.utc)` instead of deprecated `datetime.utcnow()`

