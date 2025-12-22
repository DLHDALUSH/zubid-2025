# 🚀 ZUBID Production Deployment Guide

## 📋 Overview

This guide will help you deploy the latest ZUBID updates to your production server at `https://zubidauction.duckdns.org`.

## 🎯 What This Deployment Includes

### ✅ New Features:
- **Dual-Environment Architecture**: Automatic detection between Production (DuckDNS) and Development (Render)
- **Smart API Routing**: Frontend automatically connects to correct backend based on domain
- **Mobile App Environment Detection**: Debug builds use development, release builds use production
- **Enhanced Configuration System**: Centralized configuration management
- **Updated Admin Portal**: All previous enhancements included

### 🔧 Technical Updates:
- Updated `config.production.js` with dual-environment support
- Modified Android `ApiClient.kt` for build-based server selection
- Enhanced error handling and logging
- Improved security configurations

## 🖥️ Server Requirements

- **Operating System**: Linux (Ubuntu/Debian recommended)
- **Python**: 3.8+ with virtual environment
- **Web Server**: Nginx or Apache (for SSL termination)
- **Service Manager**: systemd
- **Git**: For code updates
- **SSL Certificate**: For HTTPS (Let's Encrypt recommended)

## 🚀 Deployment Methods

### Method 1: Automated Deployment (Recommended)

If you have SSH access to your DuckDNS server:

```bash
# 1. SSH into your server
ssh your-username@your-server-ip

# 2. Navigate to the ZUBID directory
cd /opt/zubid

# 3. Make the deployment script executable
chmod +x backend/production-deploy.sh

# 4. Run the automated deployment
sudo ./backend/production-deploy.sh
```

### Method 2: Manual Deployment

If you prefer manual control:

```bash
# 1. SSH into your server
ssh your-username@your-server-ip

# 2. Navigate to app directory
cd /opt/zubid

# 3. Pull latest code
git pull origin main

# 4. Activate virtual environment
source backend/venv/bin/activate

# 5. Update dependencies
cd backend
pip install -r requirements.txt

# 6. Run database migrations
python -c "from app import app, db; app.app_context().push(); db.create_all()"

# 7. Set permissions
sudo chown -R www-data:www-data /opt/zubid
sudo chmod -R 775 backend/uploads backend/logs backend/instance

# 8. Restart service
sudo systemctl restart zubid
sudo systemctl status zubid
```

## ⚙️ Environment Configuration

### Production Environment File

Copy the production environment template:

```bash
# On your server
cd /opt/zubid/backend
cp .env.production .env

# Edit the configuration
nano .env
```

### Critical Settings to Update:

1. **SECRET_KEY**: Generate a secure key
   ```bash
   python -c "import secrets; print(secrets.token_hex(32))"
   ```

2. **Database**: Consider upgrading to PostgreSQL for production
3. **CORS_ORIGINS**: Ensure only your domains are allowed
4. **Admin Credentials**: Change default admin password

## 🔍 Verification Steps

After deployment, verify everything is working:

### 1. Service Status
```bash
sudo systemctl status zubid
```

### 2. API Health Check
```bash
curl https://zubidauction.duckdns.org/api/health
```

### 3. Configuration Test
Visit: `https://zubidauction.duckdns.org/config-test.html`

Should show:
- Environment: **Production**
- API URL: `https://zubidauction.duckdns.org/api`
- All environment detection working correctly

### 4. Admin Portal
Visit: `https://zubidauction.duckdns.org/admin.html`
Login with: `admin` / `Admin123!@#`

### 5. Main Website
Visit: `https://zubidauction.duckdns.org/`
Test user registration, login, and auction functionality

## 📱 Mobile App Testing

After production deployment:

1. **Install Updated APK**: Use the rebuilt Android app
2. **Debug Build**: Should connect to development server (Render)
3. **Release Build**: Should connect to production server (DuckDNS)

## 🔧 Troubleshooting

### Service Won't Start
```bash
# Check logs
sudo journalctl -u zubid -f

# Check configuration
cd /opt/zubid/backend
source venv/bin/activate
python -c "from app import app; print('Config OK')"
```

### Permission Issues
```bash
sudo chown -R www-data:www-data /opt/zubid
sudo chmod -R 755 /opt/zubid
sudo chmod -R 775 /opt/zubid/backend/uploads
sudo chmod -R 775 /opt/zubid/backend/logs
sudo chmod -R 775 /opt/zubid/backend/instance
```

### Database Issues
```bash
cd /opt/zubid/backend
source venv/bin/activate
python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Database initialized')
"
```

## 🎉 Expected Results

After successful deployment:

### ✅ Production Environment (DuckDNS):
- **URL**: https://zubidauction.duckdns.org
- **Purpose**: Live users, production data
- **Features**: Enhanced security, optimized performance
- **Mobile**: Release builds connect here

### 🧪 Development Environment (Render):
- **URL**: https://zubid-2025.onrender.com  
- **Purpose**: Testing, development
- **Features**: Debug logging, development tools
- **Mobile**: Debug builds connect here

### 🔄 Smart Environment Detection:
- **Web Frontend**: Automatically detects domain and routes to correct API
- **Android App**: Build type determines server connection
- **Configuration**: Centralized and environment-aware

## 📞 Support

If you encounter issues during deployment:

1. **Check the logs**: `sudo journalctl -u zubid -f`
2. **Verify configuration**: Ensure `.env` file is properly configured
3. **Test connectivity**: Ensure server can reach GitHub for code updates
4. **Check permissions**: Ensure www-data has proper access to files

## 🔐 Security Notes

- **Change default admin password** immediately after deployment
- **Generate secure SECRET_KEY** for production
- **Restrict CORS origins** to your domains only
- **Enable HTTPS** and secure headers
- **Regular backups** of database and uploads
- **Monitor logs** for suspicious activity

---

**🎯 Ready to deploy? Run the automated deployment script or follow the manual steps above!**
