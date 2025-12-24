# Option 1: Linux Server Deployment - READY TO GO! 🚀

## What You Need

1. **Linux Server** (Ubuntu/Debian recommended)
2. **SSH Access** with sudo privileges
3. **Domain**: zubidauction.duckdns.org (already configured)
4. **Git** installed on server
5. **Python 3.9+** installed
6. **Nginx** installed

## Quick Start (Copy & Paste)

### 1. Connect to Server
```bash
ssh user@your-server-ip
```

### 2. Setup Application
```bash
sudo mkdir -p /opt/zubid
sudo chown $USER:$USER /opt/zubid
cd /opt/zubid
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
```

### 3. Create Python Environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Configure Environment
```bash
cp .env.production .env
nano .env
```

**In nano, set these values:**
```
FLASK_ENV=production
SECRET_KEY=<paste-generated-key-here>
CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org
DATABASE_URI=sqlite:///auction.db
CSRF_ENABLED=true
HTTPS_ENABLED=true
PORT=5000
```

**Generate SECRET_KEY (run this first):**
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### 5. Create Directories
```bash
mkdir -p logs uploads instance
```

### 6. Setup Systemd Service
```bash
sudo cp zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
sudo systemctl status zubid
```

### 7. Configure Nginx
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

**Enable and test:**
```bash
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 8. Setup SSL
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org
```

## Verify Deployment

### Check Service
```bash
sudo systemctl status zubid
sudo journalctl -u zubid -f
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

Expected headers:
- `Access-Control-Allow-Origin: https://zubid-2025.onrender.com`
- `Access-Control-Allow-Credentials: true`

## Test Everything

1. **Web Frontend**: Open https://zubid-2025.onrender.com/auctions.html
   - Click Login
   - Check DevTools Network (no CORS errors)
   - Verify login works

2. **Mobile App**: Update Dio baseUrl
   - Set to: `https://zubidauction.duckdns.org/api`
   - Test login
   - Test bidding

## Documentation Files

- **DEPLOY_STEP_BY_STEP.md** - Detailed guide with explanations
- **OPTION1_DEPLOYMENT_CHECKLIST.md** - Checkbox checklist
- **This file** - Quick reference

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

**CORS failing:**
```bash
grep CORS_ORIGINS /opt/zubid/backend/.env
sudo systemctl restart zubid
```

**Nginx error:**
```bash
sudo nginx -t
sudo systemctl restart nginx
```

## Success Checklist

✅ Service running: `sudo systemctl status zubid` shows "active (running)"
✅ API responding: `curl` returns HTTP 200
✅ CORS headers present: Origin header returned
✅ Web frontend works: Login succeeds
✅ Mobile app works: Login and bidding work
✅ Logs clean: No errors in journalctl

## Need Help?

1. Check logs: `sudo journalctl -u zubid -f`
2. Review DEPLOY_STEP_BY_STEP.md
3. Check OPTION1_DEPLOYMENT_CHECKLIST.md
4. Verify .env configuration
5. Test with curl commands above

---

**You're ready to deploy!** Follow the Quick Start section above. 🎉

