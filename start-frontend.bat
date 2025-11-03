@echo off
echo Starting ZUBID Frontend Server...
echo.
cd frontend
echo Starting HTTP server on http://localhost:8080
echo.
echo Open your browser and go to: http://localhost:8080
echo Keep this window open!
echo.
python -m http.server 8080
pause

