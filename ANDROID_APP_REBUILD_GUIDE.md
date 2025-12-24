# 🔧 ANDROID APP - REBUILD GUIDE

## ⚠️ Problem

The Android app was showing errors because:
1. ❌ It was still using the **old Render.com API URL** (cached from previous build)
2. ❌ Missing **network security configuration** for HTTPS
3. ❌ Missing **INTERNET permission** in manifest

## ✅ What Was Fixed

### 1. **API URL Updated** ✅
- **File**: `frontend_flutter/lib/services/api_service.dart`
- **Old**: `https://zubid-2025.onrender.com/api`
- **New**: `https://zubidauction.duckdns.org/api`

### 2. **Network Security Config Added** ✅
- **File**: `frontend_flutter/android/app/src/main/res/xml/network_security_config.xml`
- Allows HTTPS connections to production server
- Trusts system and user certificates

### 3. **Permissions Added** ✅
- **File**: `frontend_flutter/android/app/src/main/AndroidManifest.xml`
- Added `INTERNET` permission
- Added `ACCESS_NETWORK_STATE` permission

---

## 🚀 REBUILD INSTRUCTIONS

### **Step 1: Clean Everything**

```bash
cd frontend_flutter
flutter clean
```

This removes all cached build files.

### **Step 2: Get Dependencies**

```bash
flutter pub get
```

### **Step 3: Build APK (Release)**

```bash
flutter build apk --release
```

**OR** for debug (faster):

```bash
flutter build apk --debug
```

### **Step 4: Install on Device**

**Option A - Using Flutter:**
```bash
flutter install
```

**Option B - Using ADB directly:**
```bash
adb install -r build/app/outputs/apk/release/app-release.apk
```

**Option C - Run directly:**
```bash
flutter run --release
```

---

## 📱 TESTING AFTER REBUILD

### **Test Login**
1. Open the app
2. Username: `admin`
3. Password: `Admin123!@#`
4. Click **Login**

### **Expected Results**
✅ No connection errors
✅ Login screen loads
✅ Can enter credentials
✅ Login succeeds
✅ Redirects to home screen
✅ Auctions load

### **If Still Getting Errors**

**Error: "Failed host lookup: 'zubid-2025.onrender.com'"**
- ❌ App wasn't rebuilt properly
- ✅ Solution: Run `flutter clean` again and rebuild

**Error: "Certificate verification failed"**
- ❌ SSL certificate issue
- ✅ Solution: Check if backend is running with valid SSL

**Error: "Connection refused"**
- ❌ Backend server not running
- ✅ Solution: Check if Flask backend is running on 139.59.156.139

---

## 🔍 VERIFICATION CHECKLIST

Before testing, verify:

- [ ] `flutter clean` completed
- [ ] `flutter pub get` completed
- [ ] `api_service.dart` has correct URL
- [ ] `network_security_config.xml` exists
- [ ] `AndroidManifest.xml` has permissions
- [ ] Device has internet connection
- [ ] Backend server is running
- [ ] SSL certificate is valid

---

## 📊 Build Output Locations

| Build Type | Location |
|-----------|----------|
| **Debug APK** | `build/app/outputs/apk/debug/app-debug.apk` |
| **Release APK** | `build/app/outputs/apk/release/app-release.apk` |
| **Bundle** | `build/app/outputs/bundle/release/app-release.aab` |

---

## 🎯 QUICK REBUILD COMMAND

Copy and paste this to rebuild everything:

```bash
cd frontend_flutter && flutter clean && flutter pub get && flutter build apk --release
```

Then install:
```bash
adb install -r build/app/outputs/apk/release/app-release.apk
```

---

## ✨ SUMMARY

| Component | Status |
|-----------|--------|
| API URL | ✅ Updated to production |
| Network Config | ✅ Created |
| Permissions | ✅ Added |
| Build Cache | ⏳ Needs cleaning |
| App Rebuild | ⏳ Needs rebuilding |

---

## 🟢 NEXT STEPS

1. **Run the rebuild commands above**
2. **Install the new APK on your device**
3. **Test login and auction browsing**
4. **Verify no connection errors appear**

Your Android app will then work perfectly! 🎉

