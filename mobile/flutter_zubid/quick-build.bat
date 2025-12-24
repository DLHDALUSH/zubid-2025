@echo off
REM ZUBID Flutter App - Quick Build Script (assumes Flutter is installed)

echo.
echo 🚀 ZUBID Flutter App - Quick Build
echo =================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo [INFO] Please run setup-and-build.bat first to install Flutter
    echo [INFO] Or install Flutter manually from: https://flutter.dev/docs/get-started/install/windows
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
echo [INFO] Building debug APK...
flutter build apk --debug

echo.
echo [INFO] Building release APK...
flutter build apk --release

REM Create output directory
if not exist "build\outputs" mkdir "build\outputs"

echo.
echo [INFO] Copying APK files...

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    copy "build\app\outputs\flutter-apk\app-debug.apk" "build\outputs\zubid-debug.apk" >nul
    echo [SUCCESS] Debug APK: build\outputs\zubid-debug.apk
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs\zubid-release.apk" >nul
    echo [SUCCESS] Release APK: build\outputs\zubid-release.apk
)

echo.
echo [SUCCESS] ✅ Build completed successfully!
echo.
echo [INFO] 📱 Installation Instructions:
echo [INFO] 1. Transfer the APK file to your Android device
echo [INFO] 2. Enable "Install from unknown sources" in Android settings
echo [INFO] 3. Install the APK file
echo [INFO] 4. The app will connect to: https://zubidauction.duckdns.org/api
echo.
echo [INFO] 🔧 APK Files:
echo [INFO] - Debug APK (for testing): build\outputs\zubid-debug.apk
echo [INFO] - Release APK (for production): build\outputs\zubid-release.apk
echo.

if exist "build\outputs\zubid-debug.apk" (
    for %%I in ("build\outputs\zubid-debug.apk") do echo [INFO] Debug APK size: %%~zI bytes
)
if exist "build\outputs\zubid-release.apk" (
    for %%I in ("build\outputs\zubid-release.apk") do echo [INFO] Release APK size: %%~zI bytes
)

echo.
pause
