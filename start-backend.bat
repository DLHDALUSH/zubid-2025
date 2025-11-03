@echo off
echo Starting ZUBID Backend Server...
echo.
cd backend
echo Installing dependencies...
pip install -r requirements.txt
echo.
echo Starting Flask server on http://localhost:5000
echo Keep this window open!
echo.
python app.py
pause

