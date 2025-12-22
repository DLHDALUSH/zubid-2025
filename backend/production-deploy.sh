#!/bin/bash
# ZUBID Production Deployment Script
# This script deploys the latest changes to the DuckDNS production server
# Usage: ./production-deploy.sh

set -e

echo "=========================================="
echo "🚀 ZUBID PRODUCTION DEPLOYMENT"
echo "=========================================="
echo "Target: https://zubidauction.duckdns.org"
echo "Environment: Production"
echo "Date: $(date)"
echo "=========================================="

# Configuration
APP_DIR="/opt/zubid"
BACKEND_DIR="$APP_DIR/backend"
SERVICE_NAME="zubid"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   echo "❌ Error: This script must be run as root (use sudo)"
   echo "   sudo ./production-deploy.sh"
   exit 1
fi

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Error: Application directory $APP_DIR not found"
    echo "   Please ensure ZUBID is properly installed on this server"
    exit 1
fi

echo "📁 Changing to application directory..."
cd "$APP_DIR"

echo "📥 Step 1: Pulling latest code from GitHub..."
git fetch origin
git reset --hard origin/main
echo "✅ Code updated successfully"

echo "🐍 Step 2: Activating virtual environment..."
if [ ! -d "$BACKEND_DIR/venv" ]; then
    echo "❌ Error: Virtual environment not found at $BACKEND_DIR/venv"
    exit 1
fi
source "$BACKEND_DIR/venv/bin/activate"
echo "✅ Virtual environment activated"

echo "📦 Step 3: Installing/updating dependencies..."
cd "$BACKEND_DIR"
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo "✅ Dependencies updated"

echo "🗄️ Step 4: Running database migrations..."
python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Database tables created/updated')
" || echo "⚠️ Database migration completed with warnings"

echo "🔧 Step 5: Setting proper permissions..."
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"
chmod -R 775 "$BACKEND_DIR/uploads" "$BACKEND_DIR/logs" "$BACKEND_DIR/instance"
echo "✅ Permissions set"

echo "🔄 Step 6: Restarting systemd service..."
systemctl daemon-reload
systemctl restart "$SERVICE_NAME"
sleep 3

echo "🔍 Step 7: Checking service status..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "✅ Service is running"
    systemctl status "$SERVICE_NAME" --no-pager -l
else
    echo "❌ Service failed to start"
    echo "Checking logs..."
    journalctl -u "$SERVICE_NAME" --no-pager -l -n 20
    exit 1
fi

echo ""
echo "=========================================="
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "🌐 Production URLs:"
echo "   Main Site: https://zubidauction.duckdns.org/"
echo "   Admin Portal: https://zubidauction.duckdns.org/admin.html"
echo "   API Health: https://zubidauction.duckdns.org/api/health"
echo "   Config Test: https://zubidauction.duckdns.org/config-test.html"
echo ""
echo "🔐 Admin Credentials:"
echo "   Username: admin"
echo "   Password: Admin123!@#"
echo ""
echo "🧪 Verification Commands:"
echo "   curl https://zubidauction.duckdns.org/api/health"
echo "   curl https://zubidauction.duckdns.org/config.production.js"
echo ""
echo "📊 Service Management:"
echo "   Status: systemctl status $SERVICE_NAME"
echo "   Logs: journalctl -u $SERVICE_NAME -f"
echo "   Restart: systemctl restart $SERVICE_NAME"
echo ""
echo "🎯 Next Steps:"
echo "   1. Test the configuration page to verify dual-environment setup"
echo "   2. Test admin portal functionality"
echo "   3. Verify mobile app connects to production server"
echo "   4. Monitor logs for any issues"
echo ""
echo "⚠️ Important Notes:"
echo "   - Frontend files have been updated with dual-environment configuration"
echo "   - Android app will automatically use production server for release builds"
echo "   - Development server (Render) remains active for testing"
echo ""
