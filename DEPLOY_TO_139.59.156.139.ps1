# ZUBID Backend Deployment Script for 139.59.156.139
# PowerShell Version for Windows

param(
    [string]$ServerIP = "139.59.156.139",
    [string]$Domain = "zubidauction.duckdns.org"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "ZUBID Backend Deployment" -ForegroundColor Green
Write-Host "Server: $ServerIP" -ForegroundColor Green
Write-Host "Domain: $Domain" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Check if SSH is available
try {
    ssh -V | Out-Null
} catch {
    Write-Host "ERROR: SSH is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git for Windows or OpenSSH" -ForegroundColor Red
    exit 1
}

function Run-SSH {
    param([string]$Command)
    Write-Host "Running: $Command" -ForegroundColor Cyan
    ssh -t root@$ServerIP $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Command failed!" -ForegroundColor Red
        exit 1
    }
}

# Step 1: Create directories
Write-Host "Step 1: Creating directories..." -ForegroundColor Yellow
Run-SSH "mkdir -p /opt/zubid && chown `$USER:`$USER /opt/zubid && echo 'OK: Directories created'"

# Step 2: Clone repository
Write-Host ""
Write-Host "Step 2: Cloning repository..." -ForegroundColor Yellow
Run-SSH "cd /opt/zubid && git clone https://github.com/DLHDALUSH/zubid-2025.git . && cd backend && echo 'OK: Repository cloned'"

# Step 3: Setup Python environment
Write-Host ""
Write-Host "Step 3: Setting up Python environment..." -ForegroundColor Yellow
Run-SSH "cd /opt/zubid/backend && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt && echo 'OK: Python environment ready'"

# Step 4: Configure environment
Write-Host ""
Write-Host "Step 4: Configuring environment..." -ForegroundColor Yellow
$secretKey = ssh root@$ServerIP "python3 -c 'import secrets; print(secrets.token_hex(32))'"
Write-Host "Generated SECRET_KEY: $secretKey" -ForegroundColor Cyan

$envConfig = @"
FLASK_ENV=production
SECRET_KEY=$secretKey
CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org
DATABASE_URI=sqlite:///auction.db
CSRF_ENABLED=true
HTTPS_ENABLED=true
PORT=5000
"@

ssh root@$ServerIP "cd /opt/zubid/backend && cp .env.production .env && cat > .env << 'EOF'
$envConfig
EOF
echo 'OK: Environment configured'"

# Step 5: Create directories
Write-Host ""
Write-Host "Step 5: Creating application directories..." -ForegroundColor Yellow
Run-SSH "cd /opt/zubid/backend && mkdir -p logs uploads instance && echo 'OK: Directories created'"

# Step 6: Setup systemd service
Write-Host ""
Write-Host "Step 6: Setting up systemd service..." -ForegroundColor Yellow
Run-SSH "cd /opt/zubid/backend && sudo cp zubid.service /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable zubid && sudo systemctl start zubid && sleep 2 && sudo systemctl status zubid && echo 'OK: Service started'"

# Step 7: Configure Nginx
Write-Host ""
Write-Host "Step 7: Configuring Nginx..." -ForegroundColor Yellow
$nginxConfig = @"
server {
    listen 80;
    server_name $Domain;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_read_timeout 120s;
    }
}
"@

ssh root@$ServerIP "echo '$nginxConfig' | sudo tee /etc/nginx/sites-available/zubid > /dev/null && sudo ln -sf /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/ && sudo nginx -t && sudo systemctl restart nginx && echo 'OK: Nginx configured'"

# Step 8: Setup SSL
Write-Host ""
Write-Host "Step 8: Setting up SSL certificate..." -ForegroundColor Yellow
Run-SSH "sudo apt update && sudo apt install -y certbot python3-certbot-nginx && sudo certbot --nginx -d $Domain --non-interactive --agree-tos -m admin@$Domain && echo 'OK: SSL certificate installed'"

# Step 9: Verify deployment
Write-Host ""
Write-Host "Step 9: Verifying deployment..." -ForegroundColor Yellow
Run-SSH "sudo systemctl status zubid && echo '' && echo 'Testing API endpoint...' && curl -s https://$Domain/api/csrf-token | head -c 100 && echo '' && echo 'OK: Deployment complete'"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "OK: DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your backend is now running at:" -ForegroundColor Green
Write-Host "  https://$Domain" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Test web frontend: https://zubid-2025.onrender.com/auctions.html" -ForegroundColor Cyan
Write-Host "2. Test mobile app with baseUrl: https://$Domain/api" -ForegroundColor Cyan
Write-Host "3. Monitor logs: ssh root@$ServerIP 'sudo journalctl -u zubid -f'" -ForegroundColor Cyan
Write-Host ""

