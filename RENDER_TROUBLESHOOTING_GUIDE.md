# 🔧 Render Deployment Troubleshooting Guide

**Issue:** Backend not working on Render  
**Date:** January 3, 2026

---

## 🐛 Issue Fixed

**Problem:** Duplicate `from flask import g` import caused deployment failure  
**Solution:** ✅ Moved `g` import to the main import statement at the top of `app.py`

**Changes Made:**
- Line 1: Added `g` to the main Flask import
- Line 280: Removed duplicate `from flask import g`

---

## 🚀 Deployment Steps

### Step 1: Commit and Push Changes

```bash
# Check what changed
git status

# Add the fixed file
git add backend/app.py

# Commit with a clear message
git commit -m "Fix: Move Flask g import to top of file for Render deployment"

# Push to your repository
git push origin main
```

### Step 2: Trigger Render Deployment

Render will automatically detect the push and start deploying. You can also manually trigger:

1. Go to https://dashboard.render.com
2. Select your `zubid-backend` service
3. Click **"Manual Deploy"** → **"Deploy latest commit"**

### Step 3: Monitor Deployment

Watch the deployment logs in real-time:
1. Click on your service
2. Go to **"Logs"** tab
3. Watch for:
   - ✅ `pip install -r requirements.txt` - Dependencies installing
   - ✅ `Starting gunicorn` - Server starting
   - ✅ `Listening at: http://0.0.0.0:XXXX` - Server running
   - ❌ Any error messages

---

## 🔍 Common Render Issues & Solutions

### Issue 1: Import Errors
**Symptoms:** `ImportError`, `ModuleNotFoundError`  
**Solution:**
- Check `requirements.txt` has all dependencies
- Ensure no circular imports
- Verify Python version matches `runtime.txt`

### Issue 2: Database Connection Errors
**Symptoms:** `OperationalError`, `Connection refused`  
**Solution:**
```bash
# Check environment variables in Render dashboard:
# - DATABASE_URI should be set from database
# - Should start with postgresql://
```

### Issue 3: Port Binding Issues
**Symptoms:** `Address already in use`, `Failed to bind`  
**Solution:**
- Render automatically sets `$PORT` environment variable
- Make sure `gunicorn` uses `$PORT`: `--bind 0.0.0.0:$PORT`
- Check `Procfile` and `render.yaml`

### Issue 4: Timeout Errors
**Symptoms:** `Worker timeout`, `Request timeout`  
**Solution:**
- Increase timeout in `Procfile`: `--timeout 120`
- Optimize slow database queries
- Add database indexes

### Issue 5: Memory Issues
**Symptoms:** `MemoryError`, `Killed`, `Out of memory`  
**Solution:**
- Reduce number of workers: `--workers 2`
- Use NullPool for database connections (already configured)
- Optimize image processing

---

## 📋 Render Configuration Checklist

### Environment Variables (Check in Render Dashboard)

- [ ] `FLASK_ENV` = `production`
- [ ] `SECRET_KEY` = (auto-generated or set manually)
- [ ] `DATABASE_URI` = (from database connection)
- [ ] `HTTPS_ENABLED` = `true`
- [ ] `CSRF_ENABLED` = `false` (for API)
- [ ] `CORS_ORIGINS` = `https://zubid-2025.onrender.com,https://zubidauction.duckdns.org`

### Files to Verify

- [ ] `backend/requirements.txt` - All dependencies listed
- [ ] `backend/runtime.txt` - Python version specified
- [ ] `backend/Procfile` - Correct start command
- [ ] `backend/render.yaml` - Correct configuration
- [ ] `backend/app.py` - No syntax errors

---

## 🧪 Testing After Deployment

### Test 1: Health Check
```bash
curl https://zubid-2025.onrender.com/api/health
# Expected: {"status": "healthy"}
```

### Test 2: API Version
```bash
curl -I https://zubid-2025.onrender.com/api/v1/health
# Expected: X-API-Version: v1 header
```

### Test 3: CORS
```bash
curl -H "Origin: https://zubidauction.duckdns.org" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS \
     https://zubid-2025.onrender.com/api/health
# Expected: Access-Control-Allow-Origin header
```

### Test 4: Categories Endpoint
```bash
curl https://zubid-2025.onrender.com/api/v1/categories
# Expected: JSON array of categories
```

---

## 📊 Monitoring Your Deployment

### Check Logs
```
Render Dashboard → Your Service → Logs
```

Look for:
- ✅ `[INFO] Starting gunicorn`
- ✅ `[INFO] Listening at: http://0.0.0.0:XXXX`
- ✅ `[INFO] Using worker: sync`
- ❌ Any `[ERROR]` or `[CRITICAL]` messages

### Check Metrics
```
Render Dashboard → Your Service → Metrics
```

Monitor:
- **CPU Usage** - Should be < 50% normally
- **Memory Usage** - Should be < 400MB (free tier limit: 512MB)
- **Response Time** - Should be < 1000ms
- **Error Rate** - Should be < 1%

---

## 🔄 Rollback if Needed

If the deployment fails:

### Option 1: Rollback in Render Dashboard
1. Go to **"Events"** tab
2. Find the last successful deployment
3. Click **"Rollback to this deploy"**

### Option 2: Revert Git Commit
```bash
# Find the last working commit
git log --oneline

# Revert to that commit
git revert HEAD

# Push
git push origin main
```

---

## 🆘 Getting Help

### Check Render Status
https://status.render.com - Check if Render is having issues

### View Detailed Logs
```bash
# Install Render CLI
npm install -g @render/cli

# Login
render login

# View logs
render logs -s zubid-backend --tail
```

### Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `ModuleNotFoundError` | Missing dependency | Add to `requirements.txt` |
| `OperationalError` | Database issue | Check `DATABASE_URI` |
| `Worker timeout` | Request too slow | Increase `--timeout` |
| `Address in use` | Port conflict | Use `$PORT` variable |
| `Out of memory` | Memory limit exceeded | Reduce workers |

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] Backend is accessible: `https://zubid-2025.onrender.com`
- [ ] Health endpoint works: `/api/health`
- [ ] Versioned endpoint works: `/api/v1/health`
- [ ] API version header present: `X-API-Version: v1`
- [ ] CORS headers present
- [ ] Database connection working
- [ ] Frontend can connect to backend
- [ ] Flutter app can connect to backend
- [ ] No errors in Render logs

---

## 📞 Next Steps

1. ✅ **Fixed:** Import error in `app.py`
2. **Commit and push** the fix
3. **Monitor** Render deployment
4. **Test** all endpoints
5. **Verify** frontend and Flutter app work

---

**Status:** Ready to deploy! 🚀

Push your changes and Render will automatically deploy the fixed version.

