@echo off
echo ==========================================
echo Starting ZUBID Backend Server
echo ==========================================
echo.

cd /d "%~dp0"

echo Checking Python installation...
python --version
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Checking dependencies...
python -c "import flask; print('Flask OK')" 2>nul
if errorlevel 1 (
    echo ERROR: Flask is not installed
    echo Installing dependencies...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

echo.
echo Starting Flask server...
echo Server will be available at: http://127.0.0.1:5000
echo Press Ctrl+C to stop the server
echo.

python app.py

pause

