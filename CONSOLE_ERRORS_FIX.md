# 🔧 Console Errors Fix Guide

**Issue:** Frontend showing 404 errors and "Failed to load resources"  
**Date:** January 3, 2026

---

## 🐛 Errors Observed

From the console screenshot:
- ❌ Failed to load resources: 404 errors
- ❌ API errors: Resource not found
- ❌ Multiple endpoint failures

**Root Cause:** Backend on Render is not responding or not deployed

---

## 🔍 Step 1: Check Backend Status

### Option A: Use Status Check Page

I created a diagnostic page for you:

1. Open: `frontend/backend-status-check.html` in your browser
2. It will automatically test all endpoints
3. Shows which endpoints are working/failing

### Option B: Manual Check

Open these URLs in your browser:

1. **Health Check:** https://zubid-2025.onrender.com/api/health
2. **Versioned Health:** https://zubid-2025.onrender.com/api/v1/health
3. **Categories:** https://zubid-2025.onrender.com/api/v1/categories

**Expected:** JSON responses  
**If you see:** Error page or "Application Error" → Backend is down

---

## ✅ Step 2: Deploy the Backend Fix

The backend has a fix ready but needs to be deployed:

### Deploy Now:

```powershell
# Windows PowerShell
.\deploy-fix-to-render.ps1
```

Or manually:
```bash
git add backend/app.py
git commit -m "Fix: Backend deployment - Move Flask g import to top"
git push origin main
```

---

## 📊 Step 3: Monitor Deployment

1. Go to: https://dashboard.render.com
2. Click on **"zubid-backend"** service
3. Go to **"Logs"** tab
4. Wait for: **"Deploy live"** status

**Deployment takes:** 5-10 minutes

---

## 🧪 Step 4: Test After Deployment

### Test 1: Backend Health
```bash
curl https://zubid-2025.onrender.com/api/v1/health
```
**Expected:**
```json
{"status": "healthy"}
```

### Test 2: Open Frontend
1. Go to: https://zubid-2025.onrender.com
2. Open browser console (F12)
3. Check for errors
4. Should see: "ZUBID Config Loaded" message

---

## 🔄 Alternative: Test Locally

If Render is having issues, test locally:

### Start Backend Locally:
```bash
cd backend
python app.py
```

### Start Frontend Locally:
```bash
cd frontend
python -m http.server 8080
```

### Open:
```
http://localhost:8080
```

The frontend will automatically detect localhost and use `http://localhost:5000/api/v1`

---

## 🎯 Common Issues & Solutions

### Issue 1: Backend Not Deployed
**Symptoms:** All API calls return 404  
**Solution:** Deploy the backend fix (see Step 2)

### Issue 2: Render Service Sleeping
**Symptoms:** First request takes 30+ seconds  
**Solution:** Render free tier sleeps after inactivity. Wait for wake-up.

### Issue 3: Database Not Connected
**Symptoms:** 500 errors, "Database connection failed"  
**Solution:** Check Render dashboard → Environment Variables → DATABASE_URI

### Issue 4: CORS Errors
**Symptoms:** "CORS policy blocked"  
**Solution:** Check backend CORS_ORIGINS includes your domain

### Issue 5: Old Code Cached
**Symptoms:** Errors persist after deployment  
**Solution:** 
- Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- Clear browser cache
- Try incognito mode

---

## 📋 Quick Checklist

- [ ] Backend fix deployed to Render
- [ ] Render deployment shows "Deploy live"
- [ ] Health endpoint returns 200 OK
- [ ] API version header present (X-API-Version: v1)
- [ ] Frontend loads without console errors
- [ ] Can see categories/auctions
- [ ] Can login/register

---

## 🆘 If Still Not Working

### Check Render Dashboard:

1. **Service Status:**
   - Should show: 🟢 "Live"
   - If shows: 🔴 "Failed" → Check logs for errors

2. **Recent Deploys:**
   - Should show: Latest commit deployed
   - If not: Trigger manual deploy

3. **Environment Variables:**
   - `FLASK_ENV` = `production`
   - `SECRET_KEY` = (set)
   - `DATABASE_URI` = (from database)
   - `HTTPS_ENABLED` = `true`

4. **Logs:**
   - Look for: `[ERROR]` or `[CRITICAL]` messages
   - Common errors:
     - Import errors → Check requirements.txt
     - Database errors → Check DATABASE_URI
     - Port errors → Should use $PORT

---

## 🔧 Emergency Fix: Rollback

If the new deployment breaks things:

### Rollback in Render:
1. Go to **"Events"** tab
2. Find last working deployment
3. Click **"Rollback to this deploy"**

### Or revert Git:
```bash
git log --oneline
git revert HEAD
git push origin main
```

---

## 📞 Debug Commands

### Check if backend is accessible:
```bash
# Test health endpoint
curl -I https://zubid-2025.onrender.com/api/health

# Test with verbose output
curl -v https://zubid-2025.onrender.com/api/v1/health

# Test CORS
curl -H "Origin: https://zubid-2025.onrender.com" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS \
     https://zubid-2025.onrender.com/api/health
```

### Check DNS:
```bash
# Windows
nslookup zubid-2025.onrender.com

# Linux/Mac
dig zubid-2025.onrender.com
```

---

## ✨ Expected Result

After fixing, you should see:

### In Browser Console:
```
🔧 ZUBID Configuration Loaded
┌─────────────┬──────────────────────────────────────┐
│ Environment │ Production (Render)                  │
│ API URL     │ https://zubid-2025.onrender.com/api/v1 │
│ Debug Mode  │ false                                │
└─────────────┴──────────────────────────────────────┘
```

### No Errors:
- ✅ No 404 errors
- ✅ No "Failed to load resources"
- ✅ No CORS errors
- ✅ API calls succeed

---

## 📚 Related Files

- **Backend Fix:** `backend/app.py` (already fixed)
- **Deployment Script:** `deploy-fix-to-render.ps1`
- **Status Check:** `frontend/backend-status-check.html`
- **Full Guide:** `RENDER_TROUBLESHOOTING_GUIDE.md`
- **Fix Summary:** `RENDER_FIX_SUMMARY.md`

---

**Next Step:** Deploy the backend fix and wait 5-10 minutes for Render to deploy! 🚀

