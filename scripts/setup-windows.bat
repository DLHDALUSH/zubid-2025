@echo off
REM =============================================================================
REM ZUBID Windows Development Setup Script
REM =============================================================================
REM Run this script to set up your local development environment
REM =============================================================================

echo ==========================================
echo    ZUBID Windows Development Setup
echo ==========================================
echo.

REM Check if Python is installed
python --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo Please install Python 3.10+ from https://python.org
    pause
    exit /b 1
)

echo [1/6] Python found
python --version
echo.

REM Navigate to project root
cd /d "%~dp0\.."
echo Working directory: %CD%
echo.

REM Create virtual environment
echo [2/6] Creating virtual environment...
if not exist ".venv" (
    python -m venv .venv
    echo Virtual environment created.
) else (
    echo Virtual environment already exists.
)
echo.

REM Activate virtual environment
echo [3/6] Activating virtual environment...
call .venv\Scripts\activate.bat
echo.

REM Install backend dependencies
echo [4/6] Installing backend dependencies...
pip install --upgrade pip
pip install -r backend\requirements.txt
echo.

REM Create .env file if not exists
echo [5/6] Setting up configuration...
if not exist "backend\.env" (
    echo Creating .env file from template...
    copy backend\env.example backend\.env
    echo.
    echo IMPORTANT: Edit backend\.env with your settings!
) else (
    echo .env file already exists.
)
echo.

REM Create required directories
echo [6/6] Creating required directories...
if not exist "backend\logs" mkdir backend\logs
if not exist "backend\uploads" mkdir backend\uploads
if not exist "backend\instance" mkdir backend\instance
echo.

echo ==========================================
echo    Setup Complete!
echo ==========================================
echo.
echo To start the development server:
echo.
echo   Option 1: Run start-both.bat
echo   Option 2: Run start-backend.bat
echo.
echo Backend will be at: http://localhost:5000
echo Frontend will be at: http://localhost:8080
echo.
echo Press any key to start the server now, or close this window.
pause

REM Start the backend
call start-backend.bat

