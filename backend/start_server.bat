@echo off
echo Starting ZUBID Backend Server...
echo ================================

REM Set environment variables
set DATABASE_URI=sqlite:///auction.db
set FLASK_ENV=development
set FLASK_DEBUG=1

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if we're in the backend directory
if not exist "app.py" (
    echo [ERROR] app.py not found. Make sure you're in the backend directory.
    pause
    exit /b 1
)

echo [INFO] Environment: %FLASK_ENV%
echo [INFO] Database: %DATABASE_URI%
echo [INFO] Starting server on http://localhost:5000
echo.

REM Start the Flask application
python app.py

pause
