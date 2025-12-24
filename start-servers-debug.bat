@echo off
echo Starting ZUBID servers with debugging...
echo.

echo Checking Python version...
python --version
echo.

echo Checking if ports are available...
netstat -an | findstr :8000
netstat -an | findstr :5000
echo.

echo Starting frontend server...
cd frontend
start "Frontend Server" cmd /k "python -m http.server 8000"
cd ..
echo Frontend server started in new window
echo.

echo Waiting 3 seconds...
timeout /t 3 /nobreak > nul

echo Starting backend server...
cd backend
start "Backend Server" cmd /k "python simple_server.py"
cd ..
echo Backend server started in new window
echo.

echo Waiting 5 seconds for servers to start...
timeout /t 5 /nobreak > nul

echo Testing connections...
echo Testing frontend...
curl -s http://localhost:8000 > nul && echo Frontend: OK || echo Frontend: FAILED

echo Testing backend...
curl -s http://localhost:5001/api/health > nul && echo Backend: OK || echo Backend: FAILED

echo.
echo Servers should now be running in separate windows.
echo Frontend: http://localhost:8000
echo Backend: http://localhost:5001
echo.
pause
