# 🚀 Deploy Now to 139.59.156.139

## ⚡ Fastest Way: Manual SSH (Recommended)

The automated script requires SSH key setup. The manual method is actually faster and more reliable!

---

## 🎯 Quick Start

### Step 1: Open PowerShell
```powershell
cd C:\Users\Amer\Desktop\ZUBID\zubid-2025
```

### Step 2: SSH to Server
```powershell
ssh root@139.59.156.139
```

Enter your root password when prompted.

### Step 3: Copy & Paste Commands

Follow **DEPLOY_SIMPLE_139.md** and copy/paste each command one at a time.

**Time**: 15-20 minutes

---

## 📋 Commands Summary

Once SSH'd into the server, run these commands in order:

```bash
# 1. Create directories
mkdir -p /opt/zubid
chown $USER:$USER /opt/zubid
cd /opt/zubid

# 2. Clone repo
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend

# 3. Python setup (takes 2-3 minutes)
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 4. Configure .env
cp .env.production .env
nano .env
# Edit and set: FLASK_ENV=production, SECRET_KEY, CORS_ORIGINS, etc.
# Save: Ctrl+X, Y, Enter

# 5. Create directories
mkdir -p logs uploads instance

# 6. Setup service
sudo cp zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
sudo systemctl status zubid

# 7. Configure Nginx
sudo nano /etc/nginx/sites-available/zubid
# Paste Nginx config from DEPLOY_SIMPLE_139.md
# Save: Ctrl+X, Y, Enter
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 8. Setup SSL
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org

# 9. Verify
sudo systemctl status zubid
curl https://zubidauction.duckdns.org/api/csrf-token

# 10. Exit
exit
```

---

## ✅ Verify from Windows

After exiting SSH, run these in PowerShell:

```powershell
# Check service
ssh root@139.59.156.139 'sudo systemctl status zubid'

# Test API
curl https://zubidauction.duckdns.org/api/csrf-token

# Test CORS
curl -H "Origin: https://zubid-2025.onrender.com" `
  https://zubidauction.duckdns.org/api/csrf-token

# View logs
ssh root@139.59.156.139 'sudo journalctl -u zubid -f'
```

---

## 🧪 Test Everything

### Web Frontend
1. Open https://zubid-2025.onrender.com/auctions.html
2. Click Login
3. Should work!

### Mobile App
1. Update Dio baseUrl to: `https://zubidauction.duckdns.org/api`
2. Test login
3. Test bidding

---

## 📚 Full Documentation

- **DEPLOY_SIMPLE_139.md** - Detailed step-by-step guide
- **DEPLOY_139.59.156.139.md** - Alternative detailed guide
- **DEPLOY_WINDOWS_139.md** - Windows-specific help

---

## 🆘 If Something Goes Wrong

```bash
# View logs
sudo journalctl -u zubid -n 50

# Restart service
sudo systemctl restart zubid

# Check Nginx
sudo nginx -t

# Check port
sudo lsof -i :5000
```

---

## 🎯 Next Steps

1. **Open PowerShell**
2. **SSH to server**: `ssh root@139.59.156.139`
3. **Follow DEPLOY_SIMPLE_139.md** step by step
4. **Verify** with curl commands above
5. **Test** web and mobile apps

---

## ⏱️ Time Estimate

- SSH + Setup: 2 minutes
- Python install: 3 minutes
- Configuration: 2 minutes
- Service setup: 1 minute
- Nginx setup: 2 minutes
- SSL setup: 3 minutes
- Verification: 1 minute

**Total**: ~15-20 minutes

---

## 🚀 Ready?

```powershell
ssh root@139.59.156.139
```

Then follow **DEPLOY_SIMPLE_139.md**!

**You've got this!** 🎉

