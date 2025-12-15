# ZUBID App - Testing Guide

## 🚀 SETUP

### 1. Start Backend Server
```bash
cd C:\Users\Amer\Desktop\ZUBID\zubid-2025
python backend/app.py
```
**Expected Output**:
```
Server will run on: http://0.0.0.0:5000
API Test: http://0.0.0.0:5000/api/test
```

### 2. Install APK on Android Device/Emulator
```bash
adb install -r frontend_flutter/build/app/outputs/flutter-apk/app-release.apk
```

### 3. Open App
- Tap ZUBID icon to launch
- Should show loading spinner briefly
- Then display auctions list

---

## ✅ TEST CHECKLIST

### Authentication
- [ ] **Login Screen** - Appears on first launch
- [ ] **Login** - Use `admin` / `admin123`
- [ ] **Error Handling** - Wrong password shows error
- [ ] **Register** - Can create new account
- [ ] **Logout** - Can logout from profile

### Home Screen
- [ ] **Auctions Load** - List displays with images
- [ ] **Categories** - Filter chips appear
- [ ] **Search** - Can search auctions
- [ ] **Refresh** - Pull-to-refresh works
- [ ] **Error Display** - Shows error if server down

### Auction Details
- [ ] **Open Auction** - Tap auction card
- [ ] **Images** - Carousel displays
- [ ] **Countdown** - Timer shows time left
- [ ] **Bid Form** - Can enter bid amount
- [ ] **Place Bid** - Submit bid works

### Wishlist
- [ ] **Add to Wishlist** - Heart icon toggles
- [ ] **View Wishlist** - Tab shows saved items
- [ ] **Remove** - Can remove from wishlist

### Notifications
- [ ] **View Notifications** - Tab shows messages
- [ ] **Mark Read** - Can mark as read
- [ ] **Real-time** - New notifications appear

### Admin Features
- [ ] **Admin Panel** - Access from profile
- [ ] **Create Auction** - Form submits
- [ ] **Manage Categories** - Can add/edit

### Settings
- [ ] **Dark Mode** - Toggle works
- [ ] **Language** - Switch to Kurdish/Arabic
- [ ] **Profile** - Edit user info

---

## 🔍 DEBUGGING

### Check Logs
```bash
adb logcat | grep -E "\[API\]|\[AUTH\]|\[PROVIDER\]"
```

### Expected Log Output
```
[API] GET /auctions
[API] Response: 200 /auctions
[AUCTIONS] Loaded 10 auctions
[PROVIDER] Loaded 10 auctions
```

### Common Issues

**Issue**: "Connection Error" displayed
- **Fix**: Ensure backend is running
- **Check**: `python backend/app.py` is executing
- **Verify**: `http://localhost:5000/api/test` works

**Issue**: Auctions not loading
- **Check**: Logcat for API errors
- **Verify**: Backend database has auctions
- **Try**: Tap "Retry" button

**Issue**: Login fails
- **Check**: Credentials are correct
- **Verify**: Backend is running
- **Try**: Clear app cache and retry

---

## 📊 SUCCESS CRITERIA

✅ App launches without crashing  
✅ Auctions display in home screen  
✅ Can login with admin credentials  
✅ Can place bids on auctions  
✅ Notifications appear  
✅ Language switching works  
✅ Dark mode toggles  
✅ All features functional  

**If all tests pass, the app is working correctly!** 🎉

