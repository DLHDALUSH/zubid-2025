# ZUBID Production Database Setup

This guide explains how to populate the production database on Render with realistic sample data for both web and mobile applications.

## 🌐 Production Server Status

**Production URL**: https://zubid-2025.onrender.com

### Current Database State
- ✅ **Categories**: 8 categories already configured
  - Electronics (1 auction)
  - Art & Collectibles  
  - Fashion
  - Jewelry
  - Other
  - Real Estate
  - Sports
  - Vehicles

- ⚠️ **Auctions**: 1 existing auction (needs more realistic data)
- ⚠️ **Users**: Limited user data (needs sample users)

## 🔧 Manual Data Population

Since the production server has limited API endpoints for data seeding, here's how to add realistic sample data:

### Option 1: Web Interface (Recommended)

1. **Access Admin Panel**:
   - Go to: https://zubid-2025.onrender.com/admin.html
   - Login: `admin` / `Admin123!@#`

2. **Create Sample Users**:
   - Use the registration form to create users:
     - Username: `ahmed_collector`, Email: `ahmed@example.com`, Password: `User123!@#`
     - Username: `sara_antiques`, Email: `sara@example.com`, Password: `User123!@#`
     - Username: `omar_tech`, Email: `omar@example.com`, Password: `User123!@#`
     - Username: `layla_fashion`, Email: `layla@example.com`, Password: `User123!@#`
     - Username: `hassan_cars`, Email: `hassan@example.com`, Password: `User123!@#`

3. **Create Sample Auctions**:
   - Login as admin and create auctions with realistic data:

#### High-Value Electronics
- **iPhone 15 Pro Max 256GB**
  - Starting Bid: $1,200
  - Market Price: $1,399
  - Real Price: $1,350
  - Category: Electronics
  - Condition: New
  - Description: "Brand new iPhone 15 Pro Max in Natural Titanium. Unlocked, with original box and accessories."

#### Luxury Vehicles  
- **2022 Toyota Camry Hybrid**
  - Starting Bid: $25,000
  - Market Price: $28,000
  - Real Price: $27,500
  - Category: Vehicles
  - Condition: Used - Excellent
  - Description: "Excellent condition Toyota Camry Hybrid with low mileage. Full service history, single owner."

#### Luxury Items
- **Rolex Submariner Date**
  - Starting Bid: $8,000
  - Market Price: $10,000
  - Real Price: $9,200
  - Category: Jewelry
  - Condition: Used - Very Good
  - Description: "Authentic Rolex Submariner Date in stainless steel. Excellent condition with box and papers."

#### Additional Suggestions
- **MacBook Pro M3 14-inch** ($1,800 starting, Electronics)
- **Louis Vuitton Neverfull MM** ($800 starting, Fashion)
- **Antique Persian Carpet** ($1,500 starting, Art & Collectibles)
- **PlayStation 5 Console** ($450 starting, Electronics)

### Option 2: Database Script (Advanced)

If you have direct database access, you can run the local seeding script:

```bash
cd backend
python seed_production_direct.py
```

## 📱 Mobile App Configuration

The mobile app is already configured to work with both local and production servers:

### Automatic Configuration
- **Development Mode**: Uses `http://10.0.2.2:5000` (local server)
- **Production Mode**: Uses `https://zubid-2025.onrender.com` (Render server)

### Manual Configuration
To force the mobile app to use the production server:

1. **Flutter Run Command**:
   ```bash
   flutter run --dart-define=API_URL=https://zubid-2025.onrender.com
   ```

2. **Build for Production**:
   ```bash
   flutter build apk --release --dart-define=API_URL=https://zubid-2025.onrender.com
   ```

### App Configuration File
The configuration is in `mobile/flutter_zubid/lib/core/config/app_config.dart`:

```dart
static String get baseUrl {
  // Check for environment variable first
  const envApiUrl = String.fromEnvironment('API_URL');
  if (envApiUrl.isNotEmpty) {
    return envApiUrl;
  }

  // Auto-detect based on build mode
  if (isProduction) {
    return 'https://zubid-2025.onrender.com';  // Production server
  } else {
    return 'http://10.0.2.2:5000';  // Local development
  }
}
```

## 🧪 Testing Production Setup

### Web Application
1. Visit: https://zubid-2025.onrender.com
2. Login with admin credentials: `admin` / `Admin123!@#`
3. Browse auctions and test functionality

### Mobile Application
1. Configure app to use production server (see above)
2. Launch the Flutter app
3. Login with same credentials
4. Test bidding and real-time updates

### API Testing
```bash
# Test API endpoints
curl https://zubid-2025.onrender.com/api/health
curl https://zubid-2025.onrender.com/api/auctions
curl https://zubid-2025.onrender.com/api/categories
```

## 🔐 Login Credentials

### Admin Access
- **Username**: `admin`
- **Password**: `Admin123!@#`
- **URL**: https://zubid-2025.onrender.com/admin.html

### Sample Users (after creation)
- **Password**: `User123!@#` (same for all)
- **Usernames**: `ahmed_collector`, `sara_antiques`, `omar_tech`, `layla_fashion`, `hassan_cars`

## 📊 Expected Results

After populating the database, you should have:
- **8 Categories**: All major auction categories
- **5+ Users**: Realistic Iraqi user profiles
- **10+ Auctions**: High-quality items with realistic pricing
- **Active Bidding**: Multiple bids per auction
- **Real-time Updates**: WebSocket functionality working

## 🚨 Important Notes

- **Server Sleep**: Render free tier servers sleep after 15 minutes of inactivity
- **Wake-up Time**: First request may take 30-60 seconds to wake the server
- **Data Persistence**: All data is stored in PostgreSQL and persists across server restarts
- **Images**: Use high-quality Unsplash URLs for auction images
- **Pricing**: Use realistic USD pricing for Iraqi market context

## 🎯 Next Steps

1. **Populate Data**: Use the web interface to add sample auctions and users
2. **Test Web App**: Verify all functionality works on production
3. **Test Mobile App**: Configure and test the Flutter app with production server
4. **Monitor Performance**: Check server response times and functionality
5. **User Testing**: Have real users test the production system

The production database is now ready to be populated with realistic, high-quality auction data that demonstrates all ZUBID features for both web and mobile platforms! 🎉
