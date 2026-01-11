@echo off
REM ZUBID Flutter App - Simple Production Build
REM This script builds the Flutter app for production with the correct server URL

echo.
echo 🚀 ZUBID Flutter App - Production Build
echo ======================================
echo 🌐 Target Server: https://zubid-2025.onrender.com
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check if we're in the correct directory
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Please run this script from the Flutter project root.
    pause
    exit /b 1
)

echo [INFO] Flutter version:
flutter --version

echo.
echo [INFO] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [INFO] Cleaning previous builds...
flutter clean
flutter pub get

echo.
echo [INFO] Building production APK...
echo [INFO] This will automatically use: https://zubid-2025.onrender.com
flutter build apk --release --dart-define=API_URL=https://zubid-2025.onrender.com

if %errorlevel% neq 0 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)

REM Create output directory
if not exist "build\outputs" mkdir "build\outputs"

echo.
echo [INFO] Copying production APK...

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs\zubid-production.apk" >nul
    echo [SUCCESS] Production APK: build\outputs\zubid-production.apk
) else (
    echo [ERROR] Production APK not found
    pause
    exit /b 1
)

echo.
echo [SUCCESS] ✅ Production build completed successfully!
echo.
echo [INFO] 📱 Installation Instructions:
echo [INFO] 1. Transfer zubid-production.apk to your Android device
echo [INFO] 2. Enable "Install from unknown sources" in Android settings
echo [INFO] 3. Install the APK file
echo [INFO] 4. The app will connect to: https://zubid-2025.onrender.com
echo.

if exist "build\outputs\zubid-production.apk" (
    for %%I in ("build\outputs\zubid-production.apk") do echo [INFO] APK size: %%~zI bytes
)

echo.
echo [INFO] 🎯 Production APK ready for testing!
echo [INFO] File location: build\outputs\zubid-production.apk
echo.

pause
