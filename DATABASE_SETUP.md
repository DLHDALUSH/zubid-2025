# ZUBID Database Setup & Seeding

This guide explains how to clear and populate the ZUBID database with realistic sample data for both web and mobile applications.

## 🚀 Quick Start

### Option 1: Automated Reset (Recommended)
```bash
cd backend
python reset_database.py
```

### Option 2: Manual Seeding
```bash
cd backend
python seed_database.py
```

## 📊 What Gets Created

The seeding process creates:

### 👥 Users (6 total)
- **Admin User**: `admin` / `Admin123!@#`
- **Regular Users**: Various Iraqi users with realistic profiles
  - All user passwords: `User123!@#`
  - Users have different balances and locations in Baghdad

### 📂 Categories (8 total)
- Electronics
- Vehicles  
- Jewelry & Watches
- Art & Collectibles
- Fashion & Accessories
- Home & Garden
- Sports & Recreation
- Books & Media

### 🏷️ Auctions (10 total)
High-quality realistic auctions including:
- **iPhone 15 Pro Max** - $1,350 current bid
- **2022 Toyota Camry Hybrid** - $27,500 current bid  
- **Rolex Submariner** - $9,200 current bid
- **MacBook Pro M3** - $1,950 current bid
- **Louis Vuitton Neverfull** - $920 current bid
- **Antique Persian Carpet** - $1,750 current bid
- **PlayStation 5** - $480 current bid
- **Canon EOS R5** - $2,750 current bid
- **Vintage Fender Stratocaster** - $3,400 current bid
- **Original Baghdad Sunset Painting** - $650 current bid

### 💰 Bids (25+ total)
- Realistic bidding patterns
- Multiple bidders per auction
- Recent activity for active auctions
- Auto-bid functionality included

### 🧾 Invoices (2-3 sample)
- Completed transactions
- Different payment methods
- Realistic fees and delivery costs

## 🔧 Technical Details

### Database Location
- **SQLite**: `backend/instance/auction.db`
- **PostgreSQL/MySQL**: As configured in `.env`

### Image Sources
All auction images use high-quality Unsplash photos with proper attribution.

### Data Characteristics
- **Iraqi Context**: Users located in Baghdad districts
- **Realistic Pricing**: Market-appropriate prices in USD
- **Time-based**: Auctions end at different times (1-9 days)
- **Featured Items**: Some auctions marked as featured
- **Bidding Activity**: Varied bid counts and patterns

## 🌐 Testing the Setup

### Web Application
1. Start backend: `cd backend && python app.py`
2. Open: http://localhost:5000
3. Login with admin credentials

### Mobile Application  
1. Ensure backend is running
2. Mobile app auto-connects to `http://10.0.2.2:5000` (Android emulator)
3. Use same login credentials

### API Testing
```bash
cd backend
python test_api_data.py
```

## 🔐 Login Credentials

### Admin Access
- **Username**: `admin`
- **Password**: `Admin123!@#`
- **Capabilities**: Full admin panel access

### Regular Users
- **Usernames**: `ahmed_collector`, `sara_antiques`, `omar_tech`, `layla_fashion`, `hassan_cars`
- **Password**: `User123!@#` (same for all)
- **Features**: Bidding, profile management, transaction history

## 🛠️ Customization

### Adding More Data
Edit `backend/seed_database.py` to:
- Add more auction items
- Create additional user profiles  
- Modify categories
- Adjust pricing and bidding patterns

### Clearing Specific Data
```python
# In Python shell with app context
from app import db, Auction, Bid, User
db.session.query(Bid).delete()  # Clear all bids
db.session.query(Auction).delete()  # Clear all auctions
db.session.commit()
```

## 🔍 Verification

After seeding, verify the data:
1. **Web**: Browse auctions at http://localhost:5000
2. **API**: Test endpoints with `test_api_data.py`
3. **Mobile**: Launch Flutter app and browse auctions
4. **Database**: Check `backend/instance/auction.db` with SQLite browser

## 🚨 Important Notes

- **Backup**: The script creates backups before clearing data
- **Production**: Never run seeding scripts on production databases
- **Images**: Uses external Unsplash URLs (requires internet)
- **Passwords**: Change default passwords in production
- **Locale**: Sample data uses Iraqi context and USD pricing

## 📱 Mobile App Configuration

The mobile app is pre-configured to work with seeded data:
- API endpoint: `http://10.0.2.2:5000/api` (Android emulator)
- WebSocket: `ws://10.0.2.2:5000` (real-time updates)
- Same authentication as web app

## 🎯 Next Steps

1. **Start Backend**: `cd backend && python app.py`
2. **Test Web**: Visit http://localhost:5000
3. **Test Mobile**: Run Flutter app
4. **Explore Data**: Login and browse auctions
5. **Place Bids**: Test the bidding functionality
6. **Admin Panel**: Use admin account for management

The database now contains realistic, interconnected data that demonstrates all ZUBID features for both web and mobile platforms!
