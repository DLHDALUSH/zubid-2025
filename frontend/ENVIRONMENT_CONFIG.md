# 🔧 Frontend Environment Configuration Guide

This guide explains how to configure the frontend for different environments (development, staging, production).

## 📋 Quick Start

### Option 1: Use New config.js (Recommended)

Replace `config.production.js` with the new `config.js` in your HTML files:

```html
<!-- OLD -->
<script src="config.production.js"></script>

<!-- NEW -->
<script src="config.js"></script>
```

The new configuration system automatically detects the environment and provides flexible switching options.

### Option 2: Keep Using config.production.js

The existing `config.production.js` will continue to work with auto-detection based on hostname.

---

## 🎯 Environment Switching (config.js)

### Method 1: URL Parameter (Easiest for Testing)

Add `?env=development` to any URL:

```
http://localhost:8080/index.html?env=development
http://localhost:8080/index.html?env=staging
http://localhost:8080/index.html?env=production
```

The environment will be saved to localStorage and persist across page reloads.

### Method 2: Browser Console

Open browser console (F12) and run:

```javascript
// Switch to development
ZUBID_CONFIG.switchEnvironment('development');

// Switch to staging
ZUBID_CONFIG.switchEnvironment('staging');

// Switch to production
ZUBID_CONFIG.switchEnvironment('production');
```

### Method 3: localStorage

```javascript
// Set environment
localStorage.setItem('ZUBID_ENV', 'development');
location.reload();

// Clear environment (will auto-detect)
localStorage.removeItem('ZUBID_ENV');
location.reload();
```

### Method 4: Before Loading Script

```html
<script>
  window.ZUBID_ENV = 'development';
</script>
<script src="config.js"></script>
```

---

## 🌍 Available Environments

| Environment | API URL | Use Case |
|-------------|---------|----------|
| `development` | `http://localhost:5000` | Local development |
| `staging` | `https://staging.zubidauction.com` | Testing before production |
| `production` | `https://zubid-2025.onrender.com` | Main production server |
| `production-alt` | `https://zubidauction.duckdns.org` | Alternative production server |

---

## 🔧 Custom API URL Override

For testing with a custom backend URL, use the `api_url` parameter:

```
http://localhost:8080/index.html?api_url=http://192.168.1.100:5000
```

This is useful when:
- Testing on a physical device
- Testing with a colleague's backend
- Testing with a different server

---

## 📝 Configuration Reference

### Accessing Configuration

```javascript
// Get current environment
console.log(ZUBID_CONFIG.environment); // 'development', 'staging', 'production'

// Get API URL
console.log(ZUBID_CONFIG.apiUrl); // 'http://localhost:5000/api'

// Get base URL (for images)
console.log(ZUBID_CONFIG.baseUrl); // 'http://localhost:5000'

// Check if in production
if (ZUBID_CONFIG.isProduction) {
  // Production-only code
}

// Check if debug mode is enabled
if (ZUBID_CONFIG.debug) {
  console.log('Debug mode enabled');
}
```

### Full Configuration Object

```javascript
ZUBID_CONFIG = {
  // Environment
  environment: 'development',
  environmentName: 'Development',
  
  // URLs
  apiUrl: 'http://localhost:5000/api',
  baseUrl: 'http://localhost:5000',
  wsUrl: 'ws://localhost:5000',
  
  // Platform Detection
  isLocalhost: true,
  isMobileApp: false,
  isCapacitor: false,
  isProduction: false,
  isStaging: false,
  isDevelopment: true,
  
  // Feature Flags
  debug: true,
  enableDebugLogs: true,
  enablePerformanceMetrics: true,
  
  // Timeouts
  apiTimeout: 60000,
  refreshInterval: 30000,
  
  // Image Settings
  maxImageSize: 5242880, // 5MB
  maxVideoSize: 52428800, // 50MB
  allowedImageTypes: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
  
  // Pagination
  defaultPageSize: 12,
  maxPageSize: 50,
  
  // App Info
  appVersion: '1.0.0',
  appName: 'ZUBID',
  
  // Helper Methods
  switchEnvironment: function(env) { /* ... */ }
}
```

---

## 🚀 Development Workflow

### 1. Start Backend

```bash
cd backend
python app.py
# Backend running on http://localhost:5000
```

### 2. Start Frontend

#### Option A: Simple HTTP Server (Python)
```bash
cd frontend
python -m http.server 8080
# Open http://localhost:8080
```

#### Option B: Live Server (VS Code Extension)
1. Install "Live Server" extension
2. Right-click `index.html`
3. Select "Open with Live Server"

#### Option C: Node.js http-server
```bash
cd frontend
npx http-server -p 8080
# Open http://localhost:8080
```

### 3. Verify Configuration

Open browser console (F12) and check:
```javascript
console.log(ZUBID_CONFIG);
```

You should see:
```
🔧 ZUBID Configuration Loaded
┌─────────────┬──────────────────────────────┐
│ Environment │ Development                  │
│ API URL     │ http://localhost:5000/api    │
│ Base URL    │ http://localhost:5000        │
│ Debug Mode  │ true                         │
└─────────────┴──────────────────────────────┘
```

---

## 🐛 Troubleshooting

### Configuration Not Loading

1. Make sure `config.js` is loaded **before** `api.js`:
```html
<script src="config.js"></script>
<script src="api.js"></script>
```

2. Check browser console for errors

### Wrong Environment Detected

1. Clear localStorage:
```javascript
localStorage.removeItem('ZUBID_ENV');
location.reload();
```

2. Or force environment via URL:
```
?env=development
```

### CORS Errors

Make sure Flask backend has CORS enabled:
```python
from flask_cors import CORS
CORS(app, supports_credentials=True, origins=['http://localhost:8080'])
```

### API Not Reachable

1. Check backend is running: `http://localhost:5000/api/health`
2. Check firewall settings
3. Try custom API URL: `?api_url=http://127.0.0.1:5000`

---

## 📦 Production Deployment

### Build Configuration

No build step required! Just deploy the files with the correct environment auto-detection.

### Deployment Checklist

- [ ] Update `environments.production.apiUrl` in `config.js` if needed
- [ ] Test with `?env=production` locally
- [ ] Verify CORS settings on backend
- [ ] Test all API endpoints
- [ ] Check browser console for errors
- [ ] Verify image loading works
- [ ] Test authentication flow

---

## 🔒 Security Notes

1. **Never commit sensitive API keys** to `config.js`
2. **Use environment variables** on the server for secrets
3. **Enable HTTPS** in production
4. **Validate CORS origins** on backend
5. **Use secure cookies** for authentication

---

## 📚 Migration Guide

### From config.production.js to config.js

1. **Backup** your current `config.production.js`
2. **Update HTML files** to use `config.js`:
   ```html
   <script src="config.js"></script>
   ```
3. **Test locally** with `?env=development`
4. **Test production** with `?env=production`
5. **Deploy** when ready

### Backward Compatibility

The new `config.js` sets the same global variables as `config.production.js`:
- `window.API_BASE_URL`
- `window.API_BASE`
- `window.DEBUG_MODE`
- `window.ZUBID_CONFIG`

So existing code will continue to work without changes!

---

**Last Updated:** January 3, 2026

