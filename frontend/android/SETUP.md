# Zubid Android App Setup Guide

## 🚀 Quick Start

### Build Debug APK
```bash
cd frontend/android
./gradlew assembleDebug
```
APK location: `app/build/outputs/apk/debug/app-debug.apk`

### Build Release APK
```bash
./gradlew assembleRelease
```
APK location: `app/build/outputs/apk/release/app-release-unsigned.apk`

---

## 🔥 Firebase Setup (Push Notifications)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add Android app with package name: `com.zubid.app`
4. Download `google-services.json`
5. Replace `app/google-services.json` with your downloaded file
6. Enable Cloud Messaging in Firebase Console

---

## 🔐 Signed Release APK (Play Store)

### Step 1: Generate Keystore
```bash
keytool -genkey -v -keystore zubid-release.keystore -alias zubid -keyalg RSA -keysize 2048 -validity 10000
```

### Step 2: Create keystore.properties
Copy `keystore.properties.template` to `keystore.properties`:
```properties
storeFile=zubid-release.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=zubid
keyPassword=YOUR_KEY_PASSWORD
```

### Step 3: Build Signed APK
```bash
./gradlew assembleRelease
```

---

## 📱 Features

| Feature | Description |
|---------|-------------|
| **Login/Register** | Email/password authentication |
| **Home** | 2-column auction grid with live timers |
| **Bids** | Track your active bids |
| **Wishlist** | Save favorite auctions |
| **Wons** | View won auctions |
| **Notifications** | In-app notifications |
| **Auction Detail** | Full auction info + bidding |
| **Profile** | User stats and settings |
| **Settings** | Notification preferences |
| **Navigation Drawer** | Side menu with all options |
| **Push Notifications** | Firebase Cloud Messaging |

---

## 🔧 API Configuration

Update the base URL in `ApiClient.kt`:
```kotlin
private const val BASE_URL = "https://your-api-url.com/api/v1/"
```

---

## 📂 Project Structure

```
app/src/main/
├── java/com/zubid/app/
│   ├── MainActivity.kt
│   ├── data/
│   │   ├── api/           # Retrofit API
│   │   ├── local/         # Session management
│   │   └── model/         # Data models
│   ├── service/           # Firebase service
│   └── ui/
│       ├── activity/      # Activities
│       ├── adapter/       # RecyclerView adapters
│       └── fragment/      # Fragments
└── res/
    ├── layout/            # XML layouts
    ├── drawable/          # Icons & shapes
    ├── menu/              # Navigation menus
    └── values/            # Colors, strings, styles
```

---

## 🎨 Theming

- **Primary Background**: #0D0D0D (dark)
- **Card Background**: #1E1E1E
- **Accent Color**: #FF6B6B (coral)
- **Success**: #4CAF50
- **Error**: #F44336

---

## 📦 Dependencies

- Material Components 1.11.0
- Retrofit 2.9.0
- Glide 4.16.0
- Firebase BOM 32.7.0
- Kotlin Coroutines 1.7.3
- CircleImageView 3.1.0

---

## ⚠️ Important Notes

1. **Don't commit** `keystore.properties` or actual keystore files
2. **Don't commit** your real `google-services.json` with API keys
3. Update `versionCode` and `versionName` before each Play Store release

