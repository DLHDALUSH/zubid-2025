# Step-by-Step Linux Deployment Guide

## Prerequisites
- Linux server (Ubuntu/Debian)
- SSH access
- Sudo privileges
- Domain: zubidauction.duckdns.org

## Step 1: Connect to Server
```bash
ssh user@your-server-ip
# or
ssh user@zubidauction.duckdns.org
```

## Step 2: Create Application Directory
```bash
sudo mkdir -p /opt/zubid
sudo chown $USER:$USER /opt/zubid
cd /opt/zubid
```

## Step 3: Clone Repository
```bash
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
```

## Step 4: Create Python Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

## Step 5: Install Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

## Step 6: Configure Environment
```bash
# Copy production template
cp .env.production .env

# Edit with your values
nano .env
```

**Required values in .env:**
```
FLASK_ENV=production
SECRET_KEY=<generate-new-key>
CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org
DATABASE_URI=sqlite:///auction.db
CSRF_ENABLED=true
HTTPS_ENABLED=true
PORT=5000
```

**Generate SECRET_KEY:**
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

## Step 7: Create Directories
```bash
mkdir -p logs uploads instance
```

## Step 8: Set Up Systemd Service
```bash
# Copy service file
sudo cp zubid.service /etc/systemd/system/

# Edit if paths are different
sudo nano /etc/systemd/system/zubid.service

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable zubid

# Start service
sudo systemctl start zubid

# Check status
sudo systemctl status zubid
```

## Step 9: Configure Nginx
```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/zubid
```

**Paste this config:**
```nginx
server {
    listen 80;
    server_name zubidauction.duckdns.org;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }
}
```

**Enable site:**
```bash
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Step 10: Set Up SSL (Let's Encrypt)
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org
```

## Step 11: Verify Deployment
```bash
# Check service
sudo systemctl status zubid

# Check logs
sudo journalctl -u zubid -f

# Test API
curl https://zubidauction.duckdns.org/api/csrf-token
```

## Step 12: Test CORS Headers
```bash
curl -H "Origin: https://zubid-2025.onrender.com" \
  https://zubidauction.duckdns.org/api/csrf-token
```

Expected response headers:
- `Access-Control-Allow-Origin: https://zubid-2025.onrender.com`
- `Access-Control-Allow-Credentials: true`

## Troubleshooting

**Service won't start:**
```bash
sudo journalctl -u zubid -n 50
```

**Port 5000 in use:**
```bash
sudo lsof -i :5000
sudo kill -9 <PID>
```

**Nginx error:**
```bash
sudo nginx -t
sudo systemctl restart nginx
```

**CORS still failing:**
- Check .env: `grep CORS_ORIGINS .env`
- Restart: `sudo systemctl restart zubid`
- Check logs: `sudo journalctl -u zubid -f`

