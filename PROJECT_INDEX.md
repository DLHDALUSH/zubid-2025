# ZUBID Project Index

## 📋 Project Overview
**ZUBID** is a comprehensive modern auction bidding platform with multiple frontend implementations and a unified backend API.

### 🏗️ Architecture
- **Backend**: Python Flask REST API with SQLAlchemy ORM
- **Frontend Options**: 
  - Web (HTML/CSS/JS + Capacitor for mobile)
  - Flutter (Cross-platform mobile app)
  - Native Android (Kotlin)
- **Database**: SQLite (development) / PostgreSQL (production)
- **Mobile**: Capacitor + Native Android with biometric auth

## 📁 Project Structure

### 🔧 Backend (`backend/`)
- **Entry Point**: `app.py` (Flask application)
- **Database**: SQLAlchemy models (User, Auction, Bid, Category, Image)
- **Features**: Authentication, real-time bidding, admin panel, biometric auth
- **Dependencies**: `requirements.txt` (Flask, SQLAlchemy, CORS, etc.)
- **Testing**: `test_*.py` files for validation

### 🌐 Web Frontend (`frontend/`)
- **Type**: Progressive Web App (PWA) with Capacitor
- **Entry Point**: `index.html`
- **Tech Stack**: Vanilla JavaScript, HTML5, CSS3
- **Mobile**: Capacitor for iOS/Android deployment
- **Features**: Responsive design, offline support, push notifications

### 📱 Flutter App (`frontend_flutter/`)
- **Entry Point**: `lib/main.dart`
- **Architecture**: Provider pattern for state management
- **Features**: Multi-language support (EN/AR/KU), dark/light themes
- **Platforms**: iOS, Android, Web

### 🤖 Native Android (`frontend/android/`)
- **Language**: Kotlin
- **Entry Point**: `MainActivity.kt`
- **Package**: `com.zubid.app`
- **Features**: Native UI, biometric auth, push notifications
- **Build**: Gradle with Android SDK 34

### 🔌 Capacitor Bridge (`frontend/android/capacitor-cordova-android-plugins/`)
- **Purpose**: Bridge between web and native Android features
- **Build**: Gradle library module
- **Features**: Camera, notifications, biometrics integration

## 🚀 Quick Start Commands

### Backend Development
```bash
# Setup virtual environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1  # Windows
source .venv/bin/activate     # Linux/Mac

# Install dependencies
pip install -r backend/requirements.txt

# Run development server
python backend/app.py
# Server: http://localhost:5000
```

### Web Frontend
```bash
cd frontend
python -m http.server 8000
# Access: http://localhost:8000
```

### Flutter Development
```bash
cd frontend_flutter
flutter pub get
flutter run
```

### Android Build
```bash
cd frontend/android
./gradlew assembleDebug
# APK: app/build/outputs/apk/debug/
```

## 🔑 Key Features

### Authentication & Security
- Session-based authentication
- Biometric authentication (fingerprint/face)
- Password hashing with Werkzeug
- CSRF protection ready

### Auction System
- Real-time bidding with polling updates
- Auto-bidding functionality
- Image upload and QR code generation
- Category-based filtering
- Featured auctions carousel

### Multi-platform Support
- Web responsive design
- iOS/Android via Capacitor
- Native Android app
- Flutter cross-platform app

### Internationalization
- Multi-language support (English, Arabic, Kurdish)
- RTL layout support
- Localized date/time formatting

## 📊 Technology Stack

| Component | Technology |
|-----------|------------|
| Backend API | Python Flask 3.0 |
| Database | SQLite/PostgreSQL |
| Web Frontend | HTML5/CSS3/JavaScript |
| Mobile Bridge | Capacitor 7.4 |
| Native Android | Kotlin + Android SDK 34 |
| Cross-platform | Flutter 3.10+ |
| Build Tools | Gradle, npm, pip |
| CI/CD | Codemagic YAML |

## 📝 Configuration Files

- `pyproject.toml` - Python project metadata
- `frontend/package.json` - Node.js dependencies
- `frontend/capacitor.config.ts` - Capacitor configuration
- `frontend_flutter/pubspec.yaml` - Flutter dependencies
- `codemagic.yaml` - CI/CD pipeline
- `backend/requirements.txt` - Python dependencies

## 🔍 Development Notes

### Database Schema
- Users with biometric data storage
- Auctions with image galleries
- Bidding history with timestamps
- Categories for organization
- Admin roles and permissions

### API Endpoints
- `/api/auth/*` - Authentication
- `/api/auctions/*` - Auction management
- `/api/bids/*` - Bidding operations
- `/api/admin/*` - Admin functions
- `/api/categories` - Category management

### Mobile Features
- Push notifications
- Camera integration
- Biometric authentication
- Offline data caching
- Native navigation

---
*Generated: 2025-12-16 | Last Updated: Project indexing complete*
