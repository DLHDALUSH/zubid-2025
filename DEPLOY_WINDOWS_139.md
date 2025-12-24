# Windows Deployment Guide for 139.59.156.139

## Prerequisites

### 1. Install SSH (if not already installed)

**Option A: Git for Windows (Recommended)**
- Download: https://git-scm.com/download/win
- Install with default options
- Includes SSH and Git

**Option B: Windows 10/11 OpenSSH**
- Settings → Apps → Optional Features
- Search for "OpenSSH Client"
- Click Install

### 2. Verify SSH Works
```powershell
ssh -V
```

Should show: `OpenSSH_for_Windows_X.X.X`

---

## Deployment Methods

### Method 1: PowerShell Script (Recommended)

#### Step 1: Open PowerShell as Administrator
- Press `Win + X`
- Select "Windows PowerShell (Admin)"

#### Step 2: Navigate to Project Directory
```powershell
cd C:\Users\Amer\Desktop\ZUBID\zubid-2025
```

#### Step 3: Allow Script Execution
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Step 4: Run Deployment Script
```powershell
.\DEPLOY_TO_139.59.156.139.ps1
```

**Time**: 10-15 minutes

---

### Method 2: Manual SSH Commands

#### Step 1: Open PowerShell
- Press `Win + X`
- Select "Windows PowerShell"

#### Step 2: SSH to Server
```powershell
ssh root@139.59.156.139
```

#### Step 3: Follow Manual Steps
Copy and paste commands from DEPLOY_139.59.156.139.md one at a time

**Time**: 15-20 minutes

---

## Troubleshooting

### SSH Connection Refused
```powershell
# Check if SSH is installed
ssh -V

# If not found, install Git for Windows or OpenSSH
```

### Permission Denied (publickey)
```powershell
# You may need to add your SSH key
# Contact your server provider for SSH key setup
```

### Script Execution Policy Error
```powershell
# Run this first:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run the script again
.\DEPLOY_TO_139.59.156.139.ps1
```

### SSH Timeout
```powershell
# Server may be slow, wait a moment and try again
# Or use manual method with individual commands
```

---

## Verification

After deployment, verify from PowerShell:

```powershell
# Check service status
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

## Testing

### Web Frontend
1. Open https://zubid-2025.onrender.com/auctions.html
2. Click Login
3. Check DevTools Network (no CORS errors)
4. Verify login works

### Mobile App
1. Update Dio baseUrl to: `https://zubidauction.duckdns.org/api`
2. Test login
3. Test bidding

---

## If Script Fails

### Option 1: Check Logs
```powershell
ssh root@139.59.156.139 'sudo journalctl -u zubid -n 50'
```

### Option 2: Manual Deployment
Follow DEPLOY_139.59.156.139.md step by step

### Option 3: Restart Service
```powershell
ssh root@139.59.156.139 'sudo systemctl restart zubid'
```

---

## Success Indicators

✅ Script completes without errors
✅ Service running: `sudo systemctl status zubid` shows "active (running)"
✅ API responding: `curl` returns HTTP 200
✅ CORS headers present: Origin header returned
✅ Web frontend works: Login succeeds
✅ Mobile app works: Login and bidding work

---

## Next Steps

1. **Install SSH** if needed
2. **Open PowerShell as Admin**
3. **Run**: `.\DEPLOY_TO_139.59.156.139.ps1`
4. **Wait** for completion (10-15 minutes)
5. **Verify** with curl commands above
6. **Test** web frontend and mobile app

---

## Support

- **Script Issues**: Check DEPLOY_WINDOWS_139.md (this file)
- **Manual Steps**: See DEPLOY_139.59.156.139.md
- **General Help**: See DEPLOYMENT_READY_139.md

