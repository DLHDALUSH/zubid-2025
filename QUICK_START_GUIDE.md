# Zubid Quick Start Guide

## 🚀 Start Development in 3 Steps

### Step 1: Start Backend Server

```bash
cd backend
python app.py
```

**Expected Output:**
```
 * Running on http://127.0.0.1:5000
 * Running on http://YOUR_IP:5000
```

**Verify Backend is Running:**
```bash
curl http://localhost:5000/api/csrf-token
```

---

### Step 2: Start Flutter App

**For Android Emulator (Recommended):**
```bash
cd mobile/flutter_zubid
flutter pub get
flutter run
```

**For iOS Simulator:**
1. Edit `lib/core/config/app_config.dart`:
   - Comment line 21: `// return 'http://10.0.2.2:5000/api';`
   - Uncomment line 22: `return 'http://localhost:5000/api';`
2. Run: `flutter run`

**For Physical Device:**
1. Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Edit `lib/core/config/app_config.dart`:
   - Comment line 21: `// return 'http://10.0.2.2:5000/api';`
   - Uncomment line 23: `return 'http://YOUR_IP:5000/api';`
   - Replace `YOUR_IP` with your actual IP
3. Make sure backend `.env` has `HOST=0.0.0.0`
4. Run: `flutter run`

---

### Step 3: Test Login

**Test Credentials:**
- Username: `admin`
- Password: `admin123`

---

## 🔧 Common Commands

### Backend:

```bash
# Start server
python app.py

# Run tests
pytest tests/

# Database migrations
flask db upgrade

# Create new migration
flask db migrate -m "description"
```

### Flutter:

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Check for issues
flutter analyze

# Clean build
flutter clean
flutter pub get

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

---

## 🐛 Troubleshooting

### Backend Issues:

**"Port 5000 already in use":**
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:5000 | xargs kill -9
```

**"Database not found":**
```bash
flask db upgrade
```

**"Module not found":**
```bash
pip install -r requirements.txt
```

---

### Flutter Issues:

**"Connection Error" on Android Emulator:**
- ✅ Backend running on `localhost:5000`?
- ✅ Using `10.0.2.2` not `localhost`?
- ✅ Firewall not blocking port 5000?

**"Connection Error" on Physical Device:**
- ✅ Device and computer on same WiFi?
- ✅ Using correct IP address?
- ✅ Backend running with `HOST=0.0.0.0`?
- ✅ Firewall allows connections on port 5000?

**"Package not found":**
```bash
flutter clean
flutter pub get
```

**"Build failed":**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📱 Platform-Specific Notes

### Android:
- Uses `10.0.2.2` to access host machine's localhost
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)

### iOS:
- Uses `localhost` or `127.0.0.1`
- Minimum iOS: 12.0
- Requires Xcode for building

### Web:
- Uses `localhost` or actual IP
- Run with: `flutter run -d chrome`

---

## 🔑 API Endpoints

### Authentication:
- `POST /api/register` - Register new user
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `GET /api/user/profile` - Get user profile

### Auctions:
- `GET /api/auctions` - List all auctions
- `GET /api/auctions/<id>` - Get auction details
- `POST /api/auctions` - Create auction (admin)
- `PUT /api/auctions/<id>` - Update auction (admin)

### Bids:
- `POST /api/bids` - Place bid
- `GET /api/bids/auction/<id>` - Get auction bids
- `GET /api/bids/user` - Get user's bids

### Notifications:
- `POST /api/notifications/fcm-token` - Register FCM token
- `GET /api/notifications` - Get user notifications

---

## 📚 Documentation

- **Backend Fixes:** See `FIXES_SUMMARY_DEC_25_2024.md`
- **Flutter Fixes:** See `mobile/flutter_zubid/FLUTTER_APP_FIXES.md`
- **API Documentation:** See `backend/README.md`
- **Flutter Documentation:** See `mobile/flutter_zubid/README.md`

---

## 🎯 Development Workflow

1. **Start Backend:** `cd backend && python app.py`
2. **Start Flutter:** `cd mobile/flutter_zubid && flutter run`
3. **Make Changes:** Edit code
4. **Hot Reload:** Press `r` in Flutter terminal
5. **Test:** Run tests for both backend and Flutter
6. **Commit:** Commit your changes

---

## ✅ Health Check

**Backend:**
```bash
curl http://localhost:5000/api/csrf-token
# Should return: {"csrf_token": "..."}
```

**Flutter:**
- App should show login screen
- No connection errors in logs
- Can navigate through screens

---

## 🆘 Need Help?

1. Check the troubleshooting section above
2. Review the detailed documentation:
   - `FIXES_SUMMARY_DEC_25_2024.md`
   - `mobile/flutter_zubid/FLUTTER_APP_FIXES.md`
3. Check Flutter logs: Look for error messages in the terminal
4. Check backend logs: Look for error messages in the backend terminal

---

**Happy Coding! 🎉**

