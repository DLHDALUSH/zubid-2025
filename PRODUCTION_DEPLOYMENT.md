# ZUBID Backend Production Deployment Guide

## Prerequisites
- Linux server (Ubuntu/Debian recommended)
- Python 3.9+
- Nginx (reverse proxy)
- Git
- SSH access to server

## Step 1: Prepare Production Server

```bash
# SSH into your production server
ssh user@your-server-ip

# Create application directory
sudo mkdir -p /opt/zubid
sudo chown $USER:$USER /opt/zubid
cd /opt/zubid

# Clone repository
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
```

## Step 2: Set Up Python Environment

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

## Step 3: Configure Environment Variables

```bash
# Copy and edit .env file
cp .env.production .env

# Edit .env with production values
nano .env
```

**Required .env variables:**
```
FLASK_ENV=production
SECRET_KEY=<generate-with: python -c "import secrets; print(secrets.token_hex(32))">
CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org
DATABASE_URI=sqlite:///auction.db
CSRF_ENABLED=true
HTTPS_ENABLED=true
PORT=5000
```

## Step 4: Set Up Systemd Service

```bash
# Copy service file
sudo cp zubid.service /etc/systemd/system/

# Edit paths if needed
sudo nano /etc/systemd/system/zubid.service

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid

# Check status
sudo systemctl status zubid
```

## Step 5: Configure Nginx Reverse Proxy

Create `/etc/nginx/sites-available/zubid`:

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
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Step 6: Set Up SSL (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org
```

## Step 7: Verify Deployment

```bash
# Check service status
sudo systemctl status zubid

# Check logs
sudo journalctl -u zubid -f

# Test API endpoint
curl https://zubidauction.duckdns.org/api/csrf-token
```

## Monitoring & Maintenance

```bash
# View logs
sudo journalctl -u zubid -n 100 -f

# Restart service
sudo systemctl restart zubid

# Stop service
sudo systemctl stop zubid

# Update code
cd /opt/zubid && git pull origin main
sudo systemctl restart zubid
```

