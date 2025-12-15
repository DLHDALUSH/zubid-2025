# Simple Manual Deployment for 139.59.156.139

## Why Manual?

The automated script requires SSH key authentication. If your server uses password authentication, you'll need to enter the password for each command. This guide shows you how to do it step-by-step.

---

## Prerequisites

1. **SSH installed** (Git for Windows or OpenSSH)
2. **Server IP**: 139.59.156.139
3. **Root password** for the server

---

## Step-by-Step Deployment

### Step 1: SSH to Server

Open PowerShell and run:
```powershell
ssh root@139.59.156.139
```

Enter your root password when prompted.

---

### Step 2: Create Directories

```bash
mkdir -p /opt/zubid
chown $USER:$USER /opt/zubid
cd /opt/zubid
```

---

### Step 3: Clone Repository

```bash
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
```

---

### Step 4: Setup Python Environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

This takes 2-3 minutes. Wait for it to complete.

---

### Step 5: Configure Environment

```bash
cp .env.production .env
nano .env
```

Edit the file and set:
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

Copy the output and paste it as the SECRET_KEY value.

**Save file**: Press `Ctrl+X`, then `Y`, then `Enter`

---

### Step 6: Create Directories

```bash
mkdir -p logs uploads instance
```

---

### Step 7: Setup Systemd Service

```bash
sudo cp zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
sudo systemctl status zubid
```

Should show: `active (running)`

---

### Step 8: Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/zubid
```

Paste this:
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

**Save file**: Press `Ctrl+X`, then `Y`, then `Enter`

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

### Step 9: Setup SSL Certificate

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org
```

When prompted:
- Enter your email
- Agree to terms (A)
- No to sharing email (N)

---

### Step 10: Verify Deployment

```bash
sudo systemctl status zubid
curl https://zubidauction.duckdns.org/api/csrf-token
```

Should return HTTP 200 with JSON response.

---

### Step 11: Exit SSH

```bash
exit
```

---

## ✅ Verification from Windows

Open PowerShell and run:

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

## 🧪 Testing

### Web Frontend
1. Open https://zubid-2025.onrender.com/auctions.html
2. Click Login
3. Should work without CORS errors

### Mobile App
1. Update Dio baseUrl to: `https://zubidauction.duckdns.org/api`
2. Test login
3. Test bidding

---

## 🆘 Troubleshooting

**Service won't start:**
```bash
sudo journalctl -u zubid -n 50
```

**Port 5000 in use:**
```bash
sudo lsof -i :5000
```

**CORS failing:**
```bash
grep CORS_ORIGINS /opt/zubid/backend/.env
sudo systemctl restart zubid
```

**Nginx error:**
```bash
sudo nginx -t
```

---

## ⏱️ Time Estimate

- Steps 1-3: 2 minutes
- Step 4: 3 minutes (Python setup)
- Steps 5-6: 2 minutes
- Step 7: 1 minute
- Step 8: 2 minutes
- Step 9: 3 minutes (SSL setup)
- Step 10: 1 minute

**Total**: ~15-20 minutes

---

## 🎉 Success!

When complete, your backend will be running at:
- https://zubidauction.duckdns.org

All CORS headers will be configured for:
- Web frontend: https://zubid-2025.onrender.com
- Mobile app: https://zubidauction.duckdns.org/api

