#!/bin/bash
# =============================================================================
# ZUBID VPS Deployment Script
# Run this on your fresh VPS (Ubuntu 20.04+ / Debian 11+)
# Usage: curl -sSL https://your-repo/scripts/deploy-vps.sh | sudo bash
#    Or: sudo bash deploy-vps.sh
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "=============================================="
echo "    ZUBID VPS Deployment Script"
echo "=============================================="
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (sudo bash deploy-vps.sh)${NC}"
    exit 1
fi

# Get domain name
read -p "Enter your domain name (e.g., zubid.com): " DOMAIN_NAME
read -p "Enter your email for SSL certificate: " SSL_EMAIL
read -p "Enter admin password for ZUBID: " ADMIN_PASSWORD

# Generate random secret key
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))" 2>/dev/null || openssl rand -hex 32)

echo -e "\n${YELLOW}Step 1: Updating system...${NC}"
apt update && apt upgrade -y

echo -e "\n${YELLOW}Step 2: Installing required packages...${NC}"
apt install -y python3 python3-pip python3-venv nginx certbot python3-certbot-nginx \
    git curl ufw fail2ban sqlite3

echo -e "\n${YELLOW}Step 3: Setting up firewall...${NC}"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable

echo -e "\n${YELLOW}Step 4: Creating zubid user...${NC}"
if ! id "zubid" &>/dev/null; then
    useradd -m -s /bin/bash zubid
    echo "zubid ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/zubid
fi

echo -e "\n${YELLOW}Step 5: Setting up application directory...${NC}"
mkdir -p /opt/zubid
chown -R zubid:zubid /opt/zubid

echo -e "\n${YELLOW}Step 6: Copying application files...${NC}"
# If running from repo directory, copy files
if [ -d "./backend" ] && [ -d "./frontend" ]; then
    cp -r ./backend /opt/zubid/
    cp -r ./frontend /opt/zubid/
    cp -r ./uploads /opt/zubid/ 2>/dev/null || mkdir -p /opt/zubid/uploads
    chown -R zubid:zubid /opt/zubid
else
    echo -e "${RED}Please run this script from the ZUBID repository root directory${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 7: Setting up Python virtual environment...${NC}"
cd /opt/zubid/backend
sudo -u zubid python3 -m venv venv
sudo -u zubid /opt/zubid/backend/venv/bin/pip install --upgrade pip
sudo -u zubid /opt/zubid/backend/venv/bin/pip install -r requirements.txt

echo -e "\n${YELLOW}Step 8: Creating production environment file...${NC}"
cat > /opt/zubid/backend/.env << EOF
# ZUBID Production Configuration
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=${SECRET_KEY}
DATABASE_URI=sqlite:///auction.db
CORS_ORIGINS=https://${DOMAIN_NAME},https://www.${DOMAIN_NAME}
BASE_URL=https://${DOMAIN_NAME}
HTTPS_ENABLED=true
CSRF_ENABLED=true
RATE_LIMIT_ENABLED=true
RATELIMIT_STORAGE_URL=memory://
HOST=127.0.0.1
PORT=5000
LOG_LEVEL=INFO
LOG_DIR=/opt/zubid/backend/logs
UPLOAD_FOLDER=/opt/zubid/backend/uploads
ADMIN_USERNAME=admin
ADMIN_PASSWORD=${ADMIN_PASSWORD}
ADMIN_EMAIL=admin@${DOMAIN_NAME}
ADMIN_ID_NUMBER=ADMIN001
WORKERS=4
TIMEOUT=120
EOF
chown zubid:zubid /opt/zubid/backend/.env
chmod 600 /opt/zubid/backend/.env

echo -e "\n${YELLOW}Step 9: Creating directories...${NC}"
mkdir -p /opt/zubid/backend/logs
mkdir -p /opt/zubid/backend/uploads
mkdir -p /opt/zubid/backend/instance
chown -R zubid:zubid /opt/zubid/backend/logs
chown -R zubid:zubid /opt/zubid/backend/uploads
chown -R zubid:zubid /opt/zubid/backend/instance

echo -e "\n${YELLOW}Step 10: Initializing database...${NC}"
cd /opt/zubid/backend
sudo -u zubid /opt/zubid/backend/venv/bin/python -c "from app import app, db, init_db; app.app_context().push(); init_db()"

echo -e "\n${GREEN}Base setup complete! Run setup-nginx-ssl.sh next.${NC}"

