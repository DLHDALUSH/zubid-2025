@echo off
REM ZUBID Flutter App - Android Studio Setup Script

echo.
echo 🚀 ZUBID Flutter App - Android Studio Setup
echo ==========================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo [INFO] Please install Flutter first
    pause
    exit /b 1
)

echo [INFO] Flutter version:
flutter --version

echo.
echo [INFO] Checking Flutter doctor...
flutter doctor

echo.
echo [INFO] Getting Flutter dependencies...
flutter pub get

echo.
echo [INFO] Generating necessary files...
flutter packages get

echo.
echo [SUCCESS] ✅ Android Studio setup completed!
echo.
echo [INFO] 📋 Next Steps:
echo [INFO] 1. Open Android Studio
echo [INFO] 2. Click "Open an Existing Project"
echo [INFO] 3. Navigate to this folder: %CD%
echo [INFO] 4. Wait for indexing to complete
echo [INFO] 5. Select your target device/emulator
echo [INFO] 6. Run the app using the 'main.dart' configuration
echo.
echo [INFO] 🔧 Available Run Configurations:
echo [INFO] - main.dart (Debug with hot reload)
echo [INFO] - main.dart (profile mode)
echo [INFO] - main.dart (release mode)
echo.
echo [INFO] 📖 For detailed setup instructions, see: ANDROID_STUDIO_SETUP.md
echo.

pause
