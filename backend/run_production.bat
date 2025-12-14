@echo off
REM ZUBID Backend Production Server Startup Script (Windows)
REM This script starts the Flask application using Gunicorn

echo.
echo ==========================================
echo ZUBID Production Server Starting...
echo ==========================================
echo.

REM Change to backend directory
cd /d "%~dp0"

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install/upgrade dependencies
echo Checking dependencies...
pip install -q -r requirements.txt

REM Create necessary directories
if not exist "logs" mkdir logs
if not exist "uploads" mkdir uploads

REM Set environment variables
set FLASK_ENV=production
set PORT=5000
set WORKERS=4
set TIMEOUT=120

echo.
echo Configuration:
echo   Port: %PORT%
echo   Workers: %WORKERS%
echo   Timeout: %TIMEOUT% seconds
echo   Environment: %FLASK_ENV%
echo.

REM Start Gunicorn
echo Starting Gunicorn server...
gunicorn -w %WORKERS% -b 0.0.0.0:%PORT% --timeout %TIMEOUT% --access-logfile - --error-logfile - --log-level info app:app

pause

