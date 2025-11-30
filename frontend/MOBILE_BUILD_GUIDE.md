# ZUBID Mobile App Build Guide

## 📱 Your app is ready for mobile!

The Capacitor setup is complete. Here's how to build and run your app.

---

## Option 1: Build APK with Android Studio (Recommended)

### Step 1: Install Android Studio
1. Download from: https://developer.android.com/studio
2. Install and run Android Studio
3. Complete the setup wizard (it will download Android SDK)

### Step 2: Open the Project
1. Open Android Studio
2. Click "Open" and select: `frontend/android`
3. Wait for Gradle sync to complete (may take a few minutes first time)

### Step 3: Build APK
1. In Android Studio menu: **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
2. Wait for build to complete
3. APK will be at: `frontend/android/app/build/outputs/apk/debug/app-debug.apk`

### Step 4: Install on Phone
- Copy the APK to your phone and install it
- Or connect phone via USB and click **Run** (green play button) in Android Studio

---

## Option 2: Build APK with Command Line

### Prerequisites
- Java JDK 17+ installed
- Android SDK installed (via Android Studio or manually)
- Set ANDROID_HOME environment variable

### Build Commands
```powershell
cd frontend/android
./gradlew assembleDebug
```

APK location: `android/app/build/outputs/apk/debug/app-debug.apk`

---

## 🔧 Development Setup

### Testing on Android Emulator
1. In Android Studio, create an emulator (AVD Manager)
2. Start the emulator
3. Run your Flask backend: `python backend/app.py`
4. The app connects to `10.0.2.2:5000` (emulator's localhost)

### Testing on Real Device
1. Connect phone via USB
2. Enable USB debugging on phone
3. Find your computer's IP: `ipconfig`
4. Update `capacitor.config.ts`:
   ```typescript
   url: 'http://YOUR_COMPUTER_IP:5000'
   ```
5. Run: `npx cap sync android`
6. Build and install APK

---

## 📦 Production Build

### Step 1: Update Backend URL
Edit `frontend/www/api.js` and set your production API URL:
```javascript
const API_BASE_URL = 'https://your-production-server.com/api';
```

### Step 2: Disable Dev Mode
Edit `frontend/capacitor.config.ts`:
```typescript
const isDevelopment = false;
```

### Step 3: Rebuild
```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
npx cap sync android
```

### Step 4: Generate Signed APK
In Android Studio: **Build** → **Generate Signed Bundle / APK**

---

## 🍎 iOS Build (Mac Required)

iOS builds require a Mac with Xcode installed.

### Add iOS Platform
```bash
npx cap add ios
npx cap sync ios
npx cap open ios
```

### Build in Xcode
1. Open the project in Xcode
2. Select your team for signing
3. Build and run on simulator or device

---

## 📋 Quick Commands

| Command | Description |
|---------|-------------|
| `powershell -ExecutionPolicy Bypass -File build.ps1` | Copy web files to www/ |
| `npx cap sync android` | Sync changes to Android |
| `npx cap open android` | Open in Android Studio |
| `npx cap sync ios` | Sync changes to iOS |
| `npx cap open ios` | Open in Xcode |

---

## ❓ Troubleshooting

### App shows blank screen
- Check if backend is running
- Verify IP address in capacitor.config.ts
- Check browser console in Android Studio's Logcat

### Icons not showing
- Run `setup-android-icons.ps1` again
- Clean and rebuild in Android Studio

### API connection failed
- Enable cleartext in AndroidManifest.xml (already done)
- Check firewall settings
- Verify phone and computer are on same network

