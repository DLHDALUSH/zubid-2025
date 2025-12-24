# Option 1: Linux Server Deployment Checklist

## Pre-Deployment
- [ ] Have SSH credentials ready
- [ ] Know your server IP/hostname
- [ ] Have sudo access
- [ ] Git is installed on server
- [ ] Python 3.9+ installed
- [ ] Nginx installed
- [ ] Domain zubidauction.duckdns.org is pointing to server

## Deployment Steps

### Step 1: Server Setup
- [ ] SSH into server: `ssh user@your-server-ip`
- [ ] Create directory: `sudo mkdir -p /opt/zubid`
- [ ] Change ownership: `sudo chown $USER:$USER /opt/zubid`
- [ ] Navigate: `cd /opt/zubid`

### Step 2: Clone Repository
- [ ] Clone repo: `git clone https://github.com/DLHDALUSH/zubid-2025.git .`
- [ ] Navigate to backend: `cd backend`
- [ ] Verify files exist: `ls -la`

### Step 3: Python Environment
- [ ] Create venv: `python3 -m venv venv`
- [ ] Activate: `source venv/bin/activate`
- [ ] Upgrade pip: `pip install --upgrade pip`
- [ ] Install deps: `pip install -r requirements.txt`
- [ ] Verify: `pip list | grep Flask`

### Step 4: Configuration
- [ ] Copy template: `cp .env.production .env`
- [ ] Edit .env: `nano .env`
- [ ] Set FLASK_ENV=production
- [ ] Generate SECRET_KEY: `python3 -c "import secrets; print(secrets.token_hex(32))"`
- [ ] Set CORS_ORIGINS correctly
- [ ] Set DATABASE_URI
- [ ] Set CSRF_ENABLED=true
- [ ] Set HTTPS_ENABLED=true
- [ ] Save and exit (Ctrl+X, Y, Enter)

### Step 5: Create Directories
- [ ] Create logs: `mkdir -p logs`
- [ ] Create uploads: `mkdir -p uploads`
- [ ] Create instance: `mkdir -p instance`

### Step 6: Systemd Service
- [ ] Copy service: `sudo cp zubid.service /etc/systemd/system/`
- [ ] Edit if needed: `sudo nano /etc/systemd/system/zubid.service`
- [ ] Reload: `sudo systemctl daemon-reload`
- [ ] Enable: `sudo systemctl enable zubid`
- [ ] Start: `sudo systemctl start zubid`
- [ ] Check status: `sudo systemctl status zubid`

### Step 7: Nginx Configuration
- [ ] Create config: `sudo nano /etc/nginx/sites-available/zubid`
- [ ] Paste Nginx config (see DEPLOY_STEP_BY_STEP.md)
- [ ] Enable site: `sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/`
- [ ] Test config: `sudo nginx -t`
- [ ] Restart Nginx: `sudo systemctl restart nginx`

### Step 8: SSL Certificate
- [ ] Update packages: `sudo apt update`
- [ ] Install Certbot: `sudo apt install certbot python3-certbot-nginx`
- [ ] Generate cert: `sudo certbot --nginx -d zubidauction.duckdns.org`
- [ ] Follow prompts (email, agree to terms)
- [ ] Verify auto-renewal: `sudo certbot renew --dry-run`

## Post-Deployment Verification

### Service Status
- [ ] Service running: `sudo systemctl status zubid`
- [ ] Service enabled: `sudo systemctl is-enabled zubid`
- [ ] Check logs: `sudo journalctl -u zubid -n 20`

### API Tests
- [ ] Test endpoint: `curl https://zubidauction.duckdns.org/api/csrf-token`
- [ ] Should return HTTP 200 with JSON
- [ ] Test CORS: `curl -H "Origin: https://zubid-2025.onrender.com" https://zubidauction.duckdns.org/api/csrf-token`
- [ ] Should have Access-Control-Allow-Origin header

### Web Frontend
- [ ] Open https://zubid-2025.onrender.com/auctions.html
- [ ] Click Login button
- [ ] Check DevTools Network tab
- [ ] No CORS errors should appear
- [ ] Login should work

### Mobile App
- [ ] Update Dio baseUrl to `https://zubidauction.duckdns.org/api`
- [ ] Test login from Android app
- [ ] Test browsing auctions
- [ ] Test placing bids

## Monitoring

- [ ] Set up log rotation: `sudo nano /etc/logrotate.d/zubid`
- [ ] Monitor disk space: `df -h`
- [ ] Monitor memory: `free -h`
- [ ] Check service health: `sudo systemctl status zubid`

## Troubleshooting

If service won't start:
```bash
sudo journalctl -u zubid -n 50 -e
```

If port 5000 is in use:
```bash
sudo lsof -i :5000
sudo kill -9 <PID>
```

If Nginx error:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

If CORS still failing:
```bash
grep CORS_ORIGINS /opt/zubid/backend/.env
sudo systemctl restart zubid
sudo journalctl -u zubid -f
```

## Success Indicators

✅ Service running: `sudo systemctl status zubid` shows "active (running)"
✅ API responding: `curl` returns HTTP 200
✅ CORS headers present: `curl -H "Origin: ..."` shows Access-Control-Allow-Origin
✅ Web frontend works: Login succeeds without CORS errors
✅ Mobile app works: Login and bidding work
✅ Logs clean: No errors in `sudo journalctl -u zubid -f`

