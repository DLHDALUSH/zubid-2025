@echo off
REM ZUBID Flutter App - Setup and Build Script
REM This script will install Flutter if needed and build the app

echo.
echo 🚀 ZUBID Flutter App - Setup and Build
echo =====================================
echo.

REM Check if Flutter is already installed
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Flutter is already installed
    goto :build_app
)

echo [INFO] Flutter not found. Setting up Flutter...

REM Create flutter directory if it doesn't exist
if not exist "C:\flutter" (
    echo [INFO] Creating Flutter directory...
    mkdir "C:\flutter" 2>nul
)

REM Check if we have internet connectivity
ping -n 1 google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] No internet connection. Cannot download Flutter.
    echo [INFO] Please download Flutter manually from: https://flutter.dev/docs/get-started/install/windows
    echo [INFO] Extract to C:\flutter and add C:\flutter\bin to your PATH
    pause
    exit /b 1
)

echo [INFO] Downloading Flutter SDK...
echo [INFO] This may take several minutes depending on your internet speed...

REM Download Flutter using PowerShell
powershell -Command "& {
    $ProgressPreference = 'SilentlyContinue'
    try {
        Write-Host '[INFO] Downloading Flutter SDK...'
        Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'C:\flutter_sdk.zip'
        Write-Host '[INFO] Download completed. Extracting...'
        Expand-Archive -Path 'C:\flutter_sdk.zip' -DestinationPath 'C:\' -Force
        Remove-Item 'C:\flutter_sdk.zip'
        Write-Host '[SUCCESS] Flutter SDK extracted to C:\flutter'
    } catch {
        Write-Host '[ERROR] Failed to download or extract Flutter:' $_.Exception.Message
        exit 1
    }
}"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to download Flutter SDK
    echo [INFO] Please download Flutter manually from: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

REM Add Flutter to PATH for this session
set PATH=C:\flutter\bin;%PATH%

echo [INFO] Flutter SDK installed successfully!

:build_app
echo.
echo [INFO] Verifying Flutter installation...
flutter --version

echo.
echo [INFO] Running Flutter doctor to check setup...
flutter doctor

echo.
echo [INFO] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [INFO] Building APK for development (connected to online server)...
flutter build apk --debug --target lib/main.dart

echo.
echo [INFO] Building APK for release...
flutter build apk --release --target lib/main.dart

REM Create output directory
if not exist "build\outputs" mkdir "build\outputs"

echo.
echo [INFO] Copying build artifacts...

REM Copy built files to output directory
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    copy "build\app\outputs\flutter-apk\app-debug.apk" "build\outputs\zubid-debug.apk" >nul
    echo [SUCCESS] Debug APK copied to build\outputs\zubid-debug.apk
) else (
    echo [WARNING] Debug APK not found
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs\zubid-release.apk" >nul
    echo [SUCCESS] Release APK copied to build\outputs\zubid-release.apk
) else (
    echo [WARNING] Release APK not found
)

echo.
echo [SUCCESS] 🎉 Build completed!
echo [INFO] APK files are available in: build\outputs\
echo [INFO] - zubid-debug.apk (for testing)
echo [INFO] - zubid-release.apk (for production)
echo.
echo [INFO] The app is configured to use: https://zubidauction.duckdns.org/api
echo [INFO] Install the APK on your Android device to test the app.
echo.

pause
