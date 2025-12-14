# ZUBID Deployment Checklist

## Pre-Deployment ✅

- [ ] Code committed and pushed to GitHub
- [ ] All environment variables configured
- [ ] Database backups created
- [ ] SSL certificates ready (Let's Encrypt)
- [ ] Nginx configuration prepared
- [ ] Systemd service file ready

## Backend Deployment Steps

### 1. Server Setup
- [ ] SSH into production server
- [ ] Create `/opt/zubid` directory
- [ ] Clone repository: `git clone https://github.com/DLHDALUSH/zubid-2025.git`
- [ ] Navigate to backend: `cd /opt/zubid/backend`

### 2. Python Environment
- [ ] Create venv: `python3 -m venv venv`
- [ ] Activate: `source venv/bin/activate`
- [ ] Install deps: `pip install -r requirements.txt`

### 3. Configuration
- [ ] Copy `.env.production` to `.env`
- [ ] Set `SECRET_KEY` (generate new one)
- [ ] Set `CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org`
- [ ] Set `DATABASE_URI` (PostgreSQL recommended for production)
- [ ] Set `CSRF_ENABLED=true`
- [ ] Set `HTTPS_ENABLED=true`

### 4. Systemd Service
- [ ] Copy `zubid.service` to `/etc/systemd/system/`
- [ ] Update paths in service file if needed
- [ ] Run: `sudo systemctl daemon-reload`
- [ ] Enable: `sudo systemctl enable zubid`
- [ ] Start: `sudo systemctl start zubid`
- [ ] Verify: `sudo systemctl status zubid`

### 5. Nginx Reverse Proxy
- [ ] Create Nginx config for `zubidauction.duckdns.org`
- [ ] Configure proxy to `http://127.0.0.1:5000`
- [ ] Test config: `sudo nginx -t`
- [ ] Restart Nginx: `sudo systemctl restart nginx`

### 6. SSL Certificate
- [ ] Install Certbot: `sudo apt install certbot python3-certbot-nginx`
- [ ] Generate cert: `sudo certbot --nginx -d zubidauction.duckdns.org`
- [ ] Auto-renewal enabled

## Post-Deployment Verification

### API Tests
- [ ] Test CSRF endpoint: `curl https://zubidauction.duckdns.org/api/csrf-token`
- [ ] Check CORS headers with web origin
- [ ] Test login endpoint: `POST /api/login`
- [ ] Test profile endpoint: `GET /api/profile`

### Web Frontend
- [ ] Open `https://zubid-2025.onrender.com/auctions.html`
- [ ] Click Login button
- [ ] Check DevTools Network tab (no CORS errors)
- [ ] Verify login works
- [ ] Test browsing auctions
- [ ] Test placing bids

### Mobile App
- [ ] Update Dio baseUrl to `https://zubidauction.duckdns.org/api`
- [ ] Test login from Android app
- [ ] Test browsing auctions
- [ ] Test placing bids
- [ ] Check for any network errors

### Monitoring
- [ ] Check service logs: `sudo journalctl -u zubid -f`
- [ ] Monitor CPU/Memory usage
- [ ] Check disk space
- [ ] Verify database connectivity

## Rollback Plan

If issues occur:
1. Stop service: `sudo systemctl stop zubid`
2. Revert code: `cd /opt/zubid && git revert HEAD`
3. Restart: `sudo systemctl start zubid`
4. Check logs: `sudo journalctl -u zubid -f`

## Maintenance

- [ ] Set up log rotation
- [ ] Configure automated backups
- [ ] Set up monitoring alerts
- [ ] Document any custom configurations
- [ ] Create runbook for common issues

