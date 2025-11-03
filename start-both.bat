@echo off
echo Starting ZUBID - Both Backend and Frontend
echo.
echo Starting Backend in new window...
start "ZUBID Backend" cmd /k "cd backend && pip install -r requirements.txt && python app.py"
timeout /t 3
echo.
echo Starting Frontend in new window...
start "ZUBID Frontend" cmd /k "cd frontend && python -m http.server 8080"
echo.
echo Both servers are starting...
echo.
echo Backend: http://localhost:5000
echo Frontend: http://localhost:8080
echo.
echo Opening browser in 5 seconds...
timeout /t 5
start http://localhost:8080
pause

