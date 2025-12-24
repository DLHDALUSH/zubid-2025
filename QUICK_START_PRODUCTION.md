# Quick Start: Deploy Backend to Production

## Option 1: Linux Server (Recommended)

### 1. SSH into your server
```bash
ssh user@your-server-ip
```

### 2. Run automated deployment
```bash
cd /opt/zubid
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
chmod +x deploy.sh
sudo ./deploy.sh production
```

### 3. Configure Nginx (see PRODUCTION_DEPLOYMENT.md)

### 4. Verify
```bash
curl https://zubidauction.duckdns.org/api/csrf-token
```

---

## Option 2: Windows Server / Local Testing

### 1. Open Command Prompt
```cmd
cd C:\Users\Amer\Desktop\ZUBID\zubid-2025\backend
```

### 2. Run production server
```cmd
run_production.bat
```

### 3. Test in browser
```
http://localhost:5000/api/csrf-token
```

---

## Option 3: Docker (If Available)

Create `Dockerfile` in backend directory:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-c", "gunicorn_config.py", "app:app"]
```

Build and run:
```bash
docker build -t zubid-backend .
docker run -p 5000:5000 -e CORS_ORIGINS="https://zubid-2025.onrender.com,https://zubidauction.duckdns.org" zubid-backend
```

---

## Environment Variables Required

```
FLASK_ENV=production
SECRET_KEY=<generate-new>
CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org
DATABASE_URI=sqlite:///auction.db
CSRF_ENABLED=true
HTTPS_ENABLED=true
PORT=5000
```

---

## Verify Deployment

### Test CORS Headers
```bash
curl -H "Origin: https://zubid-2025.onrender.com" \
  https://zubidauction.duckdns.org/api/csrf-token
```

Expected response headers:
- `Access-Control-Allow-Origin: https://zubid-2025.onrender.com`
- `Access-Control-Allow-Credentials: true`

### Test Web Frontend
1. Open https://zubid-2025.onrender.com/auctions.html
2. Click Login
3. Check DevTools → Network (no CORS errors)

### Test Mobile App
1. Update Dio baseUrl to `https://zubidauction.duckdns.org/api`
2. Test login from Android app

---

## Troubleshooting

**Port already in use:**
```bash
lsof -i :5000  # Find process
kill -9 <PID>  # Kill it
```

**Permission denied:**
```bash
chmod +x deploy.sh
sudo ./deploy.sh production
```

**CORS still failing:**
- Check `.env` has correct CORS_ORIGINS
- Restart service: `sudo systemctl restart zubid`
- Check logs: `sudo journalctl -u zubid -f`

---

## Next Steps

1. Choose deployment option above
2. Follow PRODUCTION_DEPLOYMENT.md for detailed steps
3. Use DEPLOYMENT_CHECKLIST.md to verify everything
4. Monitor logs and test all endpoints

