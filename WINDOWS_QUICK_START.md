# Windows Quick Start - Deploy to 139.59.156.139

## ⚡ 3-Step Deployment

### Step 1: Install SSH (if needed)

**Check if SSH is installed:**
```powershell
ssh -V
```

**If not installed, download Git for Windows:**
- https://git-scm.com/download/win
- Install with default options
- Restart PowerShell after installation

---

### Step 2: Open PowerShell as Administrator

1. Press `Win + X`
2. Select "Windows PowerShell (Admin)"
3. Navigate to project:
```powershell
cd C:\Users\Amer\Desktop\ZUBID\zubid-2025
```

---

### Step 3: Run Deployment Script

**Allow script execution (one-time):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Run the deployment:**
```powershell
.\DEPLOY_TO_139.59.156.139.ps1
```

**That's it!** The script will:
- ✅ Connect to your server
- ✅ Clone the repository
- ✅ Setup Python environment
- ✅ Configure .env file
- ✅ Setup systemd service
- ✅ Configure Nginx
- ✅ Install SSL certificate
- ✅ Verify deployment

**Time**: 10-15 minutes

---

## ✅ Verify Deployment

After the script completes, verify everything works:

```powershell
# Check service status
ssh root@139.59.156.139 'sudo systemctl status zubid'

# Test API endpoint
curl https://zubidauction.duckdns.org/api/csrf-token

# Test CORS headers
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
3. Should work without CORS errors

### Mobile App
1. Update Dio baseUrl to: `https://zubidauction.duckdns.org/api`
2. Test login
3. Test bidding

---

## 🆘 Troubleshooting

### SSH Not Found
```powershell
# Install Git for Windows from:
# https://git-scm.com/download/win
# Then restart PowerShell
```

### Script Execution Policy Error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script Fails Midway
```powershell
# Check logs on server:
ssh root@139.59.156.139 'sudo journalctl -u zubid -n 50'

# Or restart service:
ssh root@139.59.156.139 'sudo systemctl restart zubid'
```

### CORS Still Failing
```powershell
# Restart the service:
ssh root@139.59.156.139 'sudo systemctl restart zubid'

# Check configuration:
ssh root@139.59.156.139 'grep CORS_ORIGINS /opt/zubid/backend/.env'
```

---

## 📚 Full Documentation

- **DEPLOY_WINDOWS_139.md** - Detailed Windows guide
- **DEPLOY_139.59.156.139.md** - Manual step-by-step
- **DEPLOYMENT_READY_139.md** - Overview

---

## 🎯 Summary

1. **Install SSH** (if needed)
2. **Open PowerShell as Admin**
3. **Run**: `.\DEPLOY_TO_139.59.156.139.ps1`
4. **Wait** 10-15 minutes
5. **Verify** with curl commands
6. **Test** web and mobile apps

---

## 🚀 Ready?

```powershell
# Copy and paste this:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\DEPLOY_TO_139.59.156.139.ps1
```

**That's all you need!** 🎉

