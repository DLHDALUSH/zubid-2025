#!/bin/bash
# ZUBID Backend Automated Deployment Script
# Usage: ./deploy.sh [production|staging]

set -e

ENVIRONMENT=${1:-production}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/opt/zubid"
BACKEND_DIR="$APP_DIR/backend"

echo "=========================================="
echo "ZUBID Backend Deployment Script"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

# Check if running as root for systemd operations
if [ "$ENVIRONMENT" = "production" ] && [ "$EUID" -ne 0 ]; then 
   echo "Production deployment requires root privileges"
   exit 1
fi

# Step 1: Pull latest code
echo "Step 1: Pulling latest code from GitHub..."
cd "$APP_DIR"
git pull origin main

# Step 2: Activate virtual environment
echo "Step 2: Activating virtual environment..."
source "$BACKEND_DIR/venv/bin/activate"

# Step 3: Install dependencies
echo "Step 3: Installing dependencies..."
cd "$BACKEND_DIR"
pip install -q -r requirements.txt

# Step 4: Run database migrations
echo "Step 4: Running database migrations..."
python -c "from app import app, db; app.app_context().push(); db.create_all()" || true

# Step 5: Restart service
if [ "$ENVIRONMENT" = "production" ]; then
    echo "Step 5: Restarting systemd service..."
    systemctl restart zubid
    sleep 2
    systemctl status zubid
else
    echo "Step 5: Skipping systemd restart (staging mode)"
fi

echo ""
echo "=========================================="
echo "✅ Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Verify deployment:"
echo "  curl https://zubidauction.duckdns.org/api/csrf-token"
echo ""

