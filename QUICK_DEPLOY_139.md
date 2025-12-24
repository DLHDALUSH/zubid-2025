# Quick Deploy to 139.59.156.139 ⚡

## Server Info
- **IP**: 139.59.156.139
- **Domain**: zubidauction.duckdns.org
- **App Path**: /opt/zubid/backend

## 🚀 Fastest Way: Automated Script

### 1. Make script executable
```bash
chmod +x DEPLOY_TO_139.59.156.139.sh
```

### 2. Run it
```bash
./DEPLOY_TO_139.59.156.139.sh
```

**That's it!** The script handles everything:
- ✅ SSH to server
- ✅ Clone repo
- ✅ Setup Python
- ✅ Configure .env
- ✅ Setup service
- ✅ Configure Nginx
- ✅ Install SSL
- ✅ Verify

**Time**: ~10-15 minutes

---

## 🔧 Manual Way: Copy & Paste

```bash
# 1. SSH to server
ssh root@139.59.156.139

# 2. Setup
mkdir -p /opt/zubid
chown $USER:$USER /opt/zubid
cd /opt/zubid
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend

# 3. Python
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 4. Configure
cp .env.production .env
nano .env
# Edit: FLASK_ENV=production, CORS_ORIGINS, etc.

# 5. Directories
mkdir -p logs uploads instance

# 6. Service
sudo cp zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid

# 7. Nginx
sudo nano /etc/nginx/sites-available/zubid
# Paste config from DEPLOY_139.59.156.139.md
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 8. SSL
sudo apt update
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org

# 9. Verify
curl https://zubidauction.duckdns.org/api/csrf-token
```

---

## ✅ Verify It Works

### Check service
```bash
ssh root@139.59.156.139 'sudo systemctl status zubid'
```

### View logs
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

## 🧪 Test Everything

### Web Frontend
1. Open https://zubid-2025.onrender.com/auctions.html
2. Click Login
3. Should work without CORS errors

### Mobile App
1. Set Dio baseUrl to: `https://zubidauction.duckdns.org/api`
2. Test login
3. Test bidding

---

## 🆘 Troubleshooting

**Service won't start:**
```bash
ssh root@139.59.156.139 'sudo journalctl -u zubid -n 50'
```

**CORS failing:**
```bash
ssh root@139.59.156.139 'sudo systemctl restart zubid'
```

**Nginx error:**
```bash
ssh root@139.59.156.139 'sudo nginx -t'
```

---

## 📚 Full Docs

- **DEPLOY_139.59.156.139.md** - Detailed guide
- **DEPLOY_TO_139.59.156.139.sh** - Automated script
- **OPTION1_READY.md** - General Linux deployment

---

## 🎯 Next Steps

1. **Choose method**: Automated script OR manual copy & paste
2. **Run deployment**
3. **Verify with curl commands** above
4. **Test web frontend** and mobile app
5. **Monitor logs**: `ssh root@139.59.156.139 'sudo journalctl -u zubid -f'`

---

**Ready? Let's go! 🚀**

