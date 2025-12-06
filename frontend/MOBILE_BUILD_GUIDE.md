# ZUBID Mobile App Build Guide

## 📱 Your app is ready for Android and iOS!

The Capacitor setup is complete with support for both Android and iOS platforms.

---

## 🛠️ Prerequisites

### For Android
- **Node.js** 18+ installed
- **Android Studio** (download from https://developer.android.com/studio)
- **Java JDK 17+**

### For iOS (Mac Only)
- **Xcode** 15+ (from Mac App Store)
- **CocoaPods** (`sudo gem install cocoapods`)

---

## 🚀 Quick Start

### Build and Sync
```powershell
# Build web assets
npm run build

# Sync to both platforms
npm run sync

# Or sync to specific platform
npm run sync:android
npm run sync:ios
```

### Open in IDE
```powershell
# Open in Android Studio
npm run open:android

# Open in Xcode (Mac only)
npm run open:ios
```

---

## 📱 Android Build

### Option 1: Android Studio (Recommended)

1. **Open Project**: `npm run open:android`
2. **Wait for Gradle sync** to complete
3. **Build APK**: Menu → **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
4. **APK Location**: `frontend/android/app/build/outputs/apk/debug/app-debug.apk`

### Option 2: Command Line

```powershell
cd frontend/android
./gradlew assembleDebug
```

### Install on Device
- Copy APK to phone and install
- Or connect via USB and click **Run** in Android Studio

---

## 🍎 iOS Build (Mac Required)

1. **Open Project**: `npm run open:ios`
2. **Run `pod install`** in `frontend/ios/App`:
   ```bash
   cd frontend/ios/App
   pod install
   ```
3. **Open `App.xcworkspace`** in Xcode
4. **Select your Team** for code signing
5. **Build and Run** on simulator or device

---

## 🔧 Development Mode

For local development with backend running on your computer:

### Edit `capacitor.config.ts`:
```typescript
const isDevelopment = true;
```

### For Android Emulator:
Uses `10.0.2.2:5000` (emulator's localhost)

### For Real Device:
1. Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Update URL in `capacitor.config.ts`:
   ```typescript
   url: 'http://YOUR_IP:5000'
   ```
3. Run: `npm run update`

---

## 📦 Production Build

### Step 1: Set Production Mode
Edit `frontend/capacitor.config.ts`:
```typescript
const isDevelopment = false;
```

### Step 2: Update API URL
Edit `frontend/api.js` with your production backend URL.

### Step 3: Build and Sync
```powershell
npm run build
npm run sync
```

### Step 4: Generate Signed APK/IPA
- **Android**: In Android Studio → **Build** → **Generate Signed Bundle / APK**
- **iOS**: In Xcode → **Product** → **Archive**

---

## 📋 NPM Scripts Reference

| Script | Description |
|--------|-------------|
| `npm run build` | Copy web files to www/ |
| `npm run sync` | Sync to all platforms |
| `npm run sync:android` | Sync to Android only |
| `npm run sync:ios` | Sync to iOS only |
| `npm run open:android` | Open in Android Studio |
| `npm run open:ios` | Open in Xcode |
| `npm run android` | Build + Sync + Open Android |
| `npm run ios` | Build + Sync + Open iOS |
| `npm run android:run` | Build + Run on Android device |
| `npm run ios:run` | Build + Run on iOS device |
| `npm run update` | Build + Sync all |

---

## 🔌 Installed Plugins

| Plugin | Purpose |
|--------|---------|
| @capacitor/splash-screen | App splash screen |
| @capacitor/status-bar | Native status bar control |
| @capacitor/keyboard | Keyboard handling |
| @capacitor/app | App lifecycle events |
| @capacitor/camera | Camera/photo access |
| @capacitor/haptics | Vibration feedback |
| @capacitor/push-notifications | Push notifications |
| @capacitor/share | Native sharing |

---

## ❓ Troubleshooting

### App shows blank screen
- Ensure backend is running
- Check `capacitor.config.ts` URL setting
- View logs in Android Studio Logcat or Xcode Console

### Icons not showing
- Run `setup-android-icons.ps1`
- Clean and rebuild project

### API connection failed
- Verify `network_security_config.xml` allows your domain
- Check firewall settings
- Ensure device and computer are on same network

### iOS build fails
- Run `pod install` in `ios/App` directory
- Open `.xcworkspace` not `.xcodeproj`
- Check Xcode signing settings

### Android build fails
- Update Gradle: Android Studio → Help → Check for Updates
- Clean project: Android Studio → Build → Clean Project
- Invalidate caches: File → Invalidate Caches

