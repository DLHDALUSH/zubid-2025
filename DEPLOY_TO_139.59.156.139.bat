@echo off
REM ZUBID Backend Deployment Script for 139.59.156.139
REM Windows Batch Version

setlocal enabledelayedexpansion

set SERVER_IP=139.59.156.139
set DOMAIN=zubidauction.duckdns.org
set APP_DIR=/opt/zubid
set BACKEND_DIR=/opt/zubid/backend

echo.
echo ==========================================
echo ZUBID Backend Deployment
echo Server: %SERVER_IP%
echo Domain: %DOMAIN%
echo ==========================================
echo.

REM Check if SSH is available
where ssh >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: SSH is not installed or not in PATH
    echo Please install Git for Windows or OpenSSH
    pause
    exit /b 1
)

echo Step 1: Connecting to server and creating directories...
ssh -t root@%SERVER_IP% "mkdir -p /opt/zubid && chown $USER:$USER /opt/zubid && cd /opt/zubid && echo OK: Directories created"
if %errorlevel% neq 0 goto :error

echo.
echo Step 2: Cloning repository...
ssh -t root@%SERVER_IP% "cd /opt/zubid && git clone https://github.com/DLHDALUSH/zubid-2025.git . && cd backend && echo OK: Repository cloned"
if %errorlevel% neq 0 goto :error

echo.
echo Step 3: Setting up Python environment...
ssh -t root@%SERVER_IP% "cd /opt/zubid/backend && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt && echo OK: Python environment ready"
if %errorlevel% neq 0 goto :error

echo.
echo Step 4: Configuring environment...
ssh -t root@%SERVER_IP% "cd /opt/zubid/backend && cp .env.production .env && SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))') && sed -i 's/FLASK_ENV=.*/FLASK_ENV=production/' .env && sed -i \"s/SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/\" .env && sed -i 's|CORS_ORIGINS=.*|CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org|' .env && sed -i 's/CSRF_ENABLED=.*/CSRF_ENABLED=true/' .env && sed -i 's/HTTPS_ENABLED=.*/HTTPS_ENABLED=true/' .env && echo OK: Environment configured"
if %errorlevel% neq 0 goto :error

echo.
echo Step 5: Creating application directories...
ssh -t root@%SERVER_IP% "cd /opt/zubid/backend && mkdir -p logs uploads instance && echo OK: Directories created"
if %errorlevel% neq 0 goto :error

echo.
echo Step 6: Setting up systemd service...
ssh -t root@%SERVER_IP% "cd /opt/zubid/backend && sudo cp zubid.service /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable zubid && sudo systemctl start zubid && sleep 2 && sudo systemctl status zubid && echo OK: Service started"
if %errorlevel% neq 0 goto :error

echo.
echo Step 7: Configuring Nginx...
ssh -t root@%SERVER_IP% "sudo tee /etc/nginx/sites-available/zubid > /dev/null << 'NGINX_CONFIG' && sudo ln -sf /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/ && sudo nginx -t && sudo systemctl restart nginx && echo OK: Nginx configured"
if %errorlevel% neq 0 goto :error

echo.
echo Step 8: Setting up SSL certificate...
ssh -t root@%SERVER_IP% "sudo apt update && sudo apt install -y certbot python3-certbot-nginx && sudo certbot --nginx -d %DOMAIN% --non-interactive --agree-tos -m admin@%DOMAIN% && echo OK: SSL certificate installed"
if %errorlevel% neq 0 goto :error

echo.
echo Step 9: Verifying deployment...
ssh -t root@%SERVER_IP% "sudo systemctl status zubid && echo. && echo Testing API endpoint... && curl -s https://%DOMAIN%/api/csrf-token | head -c 100 && echo. && echo OK: Deployment complete"
if %errorlevel% neq 0 goto :error

echo.
echo ==========================================
echo OK: DEPLOYMENT SUCCESSFUL!
echo ==========================================
echo.
echo Your backend is now running at:
echo   https://%DOMAIN%
echo.
echo Next steps:
echo 1. Test web frontend: https://zubid-2025.onrender.com/auctions.html
echo 2. Test mobile app with baseUrl: https://%DOMAIN%/api
echo 3. Monitor logs: ssh root@%SERVER_IP% "sudo journalctl -u zubid -f"
echo.
pause
exit /b 0

:error
echo.
echo ERROR: Deployment failed!
echo Please check the error messages above and try again.
echo.
pause
exit /b 1

