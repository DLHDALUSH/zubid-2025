@echo off
REM ZUBID Production Server Startup Script for Windows
REM This script starts the Flask application using Gunicorn

echo ==========================================
echo ZUBID Production Server Starting...
echo ==========================================

cd /d "%~dp0"

REM Load environment variables from .env file if exists
if exist .env (
    for /f "tokens=1,* delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%a"=="#" set %%a
    )
)

REM Set default values if not set
if not defined PORT set PORT=5000
if not defined WORKERS set WORKERS=4
if not defined TIMEOUT set TIMEOUT=120

echo Configuration:
echo   Port: %PORT%
echo   Workers: %WORKERS%
echo   Timeout: %TIMEOUT% seconds
echo.

REM Create necessary directories
if not exist logs mkdir logs
if not exist uploads mkdir uploads

REM Check if virtual environment exists
if exist venv\Scripts\activate.bat (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
)

REM Install/upgrade dependencies
echo Checking dependencies...
pip install -q -r requirements.txt

REM Start Gunicorn
echo Starting Gunicorn server...
gunicorn -w %WORKERS% -b 0.0.0.0:%PORT% --timeout %TIMEOUT% --access-logfile - --error-logfile - --log-level info --preload app:app

pause

