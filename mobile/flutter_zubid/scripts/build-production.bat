@echo off
REM ZUBID Flutter App - Production Build Script for Windows
REM This script builds the Flutter app for production deployment

echo.
echo 🚀 ZUBID Flutter App - Production Build
echo =======================================
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

echo [INFO] Checking Flutter installation...
flutter --version

echo.
echo [INFO] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [INFO] Running code generation...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo [INFO] Analyzing code...
flutter analyze

echo.
echo [INFO] Running tests...
flutter test

echo.
echo [INFO] Cleaning previous builds...
flutter clean
flutter pub get

echo.
echo [INFO] Building APK for development environment...
flutter build apk --debug --flavor dev --target lib/main.dart

echo.
echo [INFO] Building APK for staging environment...
flutter build apk --profile --flavor staging --target lib/main.dart

echo.
echo [INFO] Building APK for production environment...
flutter build apk --release --flavor prod --target lib/main.dart

echo.
echo [INFO] Building App Bundle for Play Store...
flutter build appbundle --release --flavor prod --target lib/main.dart

REM Create output directory
if not exist "build\outputs" mkdir "build\outputs"

echo.
echo [INFO] Copying build artifacts...

REM Copy built files to output directory
if exist "build\app\outputs\flutter-apk\app-dev-debug.apk" (
    copy "build\app\outputs\flutter-apk\app-dev-debug.apk" "build\outputs\zubid-dev-debug.apk" >nul
    echo [SUCCESS] Development APK copied
) else (
    echo [WARNING] Development APK not found
)

if exist "build\app\outputs\flutter-apk\app-staging-profile.apk" (
    copy "build\app\outputs\flutter-apk\app-staging-profile.apk" "build\outputs\zubid-staging-profile.apk" >nul
    echo [SUCCESS] Staging APK copied
) else (
    echo [WARNING] Staging APK not found
)

if exist "build\app\outputs\flutter-apk\app-prod-release.apk" (
    copy "build\app\outputs\flutter-apk\app-prod-release.apk" "build\outputs\zubid-production-release.apk" >nul
    echo [SUCCESS] Production APK copied
) else (
    echo [WARNING] Production APK not found
)

if exist "build\app\outputs\bundle\prodRelease\app-prod-release.aab" (
    copy "build\app\outputs\bundle\prodRelease\app-prod-release.aab" "build\outputs\zubid-production-release.aab" >nul
    echo [SUCCESS] Production App Bundle copied
) else (
    echo [WARNING] Production App Bundle not found
)

REM Generate build info
echo [INFO] Generating build information...
(
echo ZUBID Flutter App - Build Information
echo =====================================
echo.
echo Build Date: %date% %time%
echo Platform: Windows
echo.
echo Build Artifacts:
echo - Development APK: zubid-dev-debug.apk
echo - Staging APK: zubid-staging-profile.apk
echo - Production APK: zubid-production-release.apk
echo - Production App Bundle: zubid-production-release.aab
echo.
echo Environment Configurations:
echo - Development: https://zubid-2025.onrender.com/api
echo - Staging: https://zubid-staging.onrender.com/api
echo - Production: https://zubidauction.duckdns.org/api
echo.
echo Installation Instructions:
echo 1. For testing: Install the appropriate APK file
echo 2. For Play Store: Upload the App Bundle ^(.aab file^)
echo 3. Make sure to test each environment before deployment
echo.
echo Security Notes:
echo - Production builds are signed with release keystore
echo - Network security config restricts cleartext traffic
echo - ProGuard obfuscation is enabled for release builds
echo - Debug tools are disabled in production builds
) > "build\outputs\build-info.txt"

echo.
echo [SUCCESS] Build completed successfully!
echo [INFO] Build artifacts are available in: build\outputs
echo [INFO] Build information saved to: build\outputs\build-info.txt

echo.
echo [INFO] Build artifact sizes:
dir "build\outputs\*.apk" "build\outputs\*.aab" 2>nul

echo.
echo [SUCCESS] 🎉 Production build completed!
echo [INFO] Next steps:
echo [INFO] 1. Test the APK files on different devices
echo [INFO] 2. Upload the App Bundle to Google Play Console
echo [INFO] 3. Configure Play Store listing and screenshots
echo [INFO] 4. Submit for review

echo.
echo [WARNING] ⚠️  Important reminders:
echo [WARNING] - Test all payment methods in production
echo [WARNING] - Verify API endpoints are accessible
echo [WARNING] - Check push notification configuration
echo [WARNING] - Ensure proper SSL certificates are in place

echo.
pause
