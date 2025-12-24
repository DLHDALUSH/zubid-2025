# Deployment Guide for 139.59.156.139

## Server Details
- **IP Address**: 139.59.156.139
- **Domain**: zubidauction.duckdns.org
- **Application Path**: /opt/zubid
- **Backend Path**: /opt/zubid/backend

## Option A: Automated Deployment (Recommended)

### 1. Make script executable
```bash
chmod +x DEPLOY_TO_139.59.156.139.sh
```

### 2. Run automated deployment
```bash
./DEPLOY_TO_139.59.156.139.sh
```

This script will:
- ✅ Connect to your server
- ✅ Clone the repository
- ✅ Setup Python environment
- ✅ Configure .env file
- ✅ Setup systemd service
- ✅ Configure Nginx
- ✅ Install SSL certificate
- ✅ Verify deployment

**Estimated time**: 10-15 minutes

---

## Option B: Manual Deployment (Step-by-Step)

### Step 1: SSH into Server
```bash
ssh root@139.59.156.139
```

### Step 2: Create Application Directory
```bash
mkdir -p /opt/zubid
chown $USER:$USER /opt/zubid
cd /opt/zubid
```

### Step 3: Clone Repository
```bash
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
```

### Step 4: Setup Python Environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 5: Configure Environment
```bash
cp .env.production .env
nano .env
```

**Set these values:**
```
FLASK_ENV=production
SECRET_KEY=<generate-new>
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

### Step 6: Create Directories
```bash
mkdir -p logs uploads instance
```

### Step 7: Setup Systemd Service
```bash
sudo cp zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
sudo systemctl status zubid
```

### Step 8: Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/zubid
```

**Paste this:**
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

### Step 9: Setup SSL Certificate
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org
```

### Step 10: Verify Deployment
```bash
sudo systemctl status zubid
curl https://zubidauction.duckdns.org/api/csrf-token
```

---

## Verification

### Check Service Status
```bash
ssh root@139.59.156.139 'sudo systemctl status zubid'
```

### View Logs
```bash
ssh root@139.59.156.139 'sudo journalctl -u zubid -f'
```

### Test API
```bash
curl https://zubidauction.duckdns.org/api/csrf-token
```

### Test CORS
```bash
curl -H "Origin: https://zubid-2025.onrender.com" \
  https://zubidauction.duckdns.org/api/csrf-token
```

---

## Testing

### Web Frontend
1. Open https://zubid-2025.onrender.com/auctions.html
2. Click Login
3. Check DevTools Network (no CORS errors)
4. Verify login works

### Mobile App
1. Update Dio baseUrl to: `https://zubidauction.duckdns.org/api`
2. Test login
3. Test browsing auctions
4. Test placing bids

---

## Troubleshooting

**Service won't start:**
```bash
ssh root@139.59.156.139 'sudo journalctl -u zubid -n 50'
```

**Port 5000 in use:**
```bash
ssh root@139.59.156.139 'sudo lsof -i :5000'
```

**CORS failing:**
```bash
ssh root@139.59.156.139 'grep CORS_ORIGINS /opt/zubid/backend/.env'
ssh root@139.59.156.139 'sudo systemctl restart zubid'
```

**Nginx error:**
```bash
ssh root@139.59.156.139 'sudo nginx -t'
```

---

## Success Indicators

✅ Service running: `sudo systemctl status zubid` shows "active (running)"
✅ API responding: `curl` returns HTTP 200
✅ CORS headers present: Origin header returned
✅ Web frontend works: Login succeeds
✅ Mobile app works: Login and bidding work
✅ Logs clean: No errors in journalctl

