#!/bin/bash
# =============================================================================
# ZUBID Server Deployment Script for Ubuntu/Debian
# =============================================================================
# Usage: sudo bash deploy-server.sh
# 
# This script will:
# 1. Install all required packages
# 2. Setup PostgreSQL database
# 3. Deploy the application
# 4. Configure Nginx
# 5. Setup systemd service
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_USER="zubid"
APP_DIR="/opt/zubid"
REPO_URL="https://github.com/DLHDALUSH/zubid-2025.git"
DOMAIN=""  # Will be set interactively

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ZUBID Server Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root (sudo bash deploy-server.sh)${NC}"
    exit 1
fi

# Get domain name
read -p "Enter your domain name (e.g., zubid.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: Domain name is required${NC}"
    exit 1
fi

# Get database password
read -sp "Enter PostgreSQL password for zubid_user: " DB_PASSWORD
echo ""
if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}Error: Database password is required${NC}"
    exit 1
fi

# Generate secret key
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

echo ""
echo -e "${YELLOW}Step 1: Updating system packages...${NC}"
apt update && apt upgrade -y

echo ""
echo -e "${YELLOW}Step 2: Installing required packages...${NC}"
apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    postgresql \
    postgresql-contrib \
    git \
    certbot \
    python3-certbot-nginx \
    ufw

echo ""
echo -e "${YELLOW}Step 3: Setting up PostgreSQL...${NC}"
sudo -u postgres psql -c "CREATE DATABASE zubid_db;" 2>/dev/null || echo "Database may already exist"
sudo -u postgres psql -c "CREATE USER zubid_user WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || echo "User may already exist"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE zubid_db TO zubid_user;"
sudo -u postgres psql -c "ALTER USER zubid_user CREATEDB;"

echo ""
echo -e "${YELLOW}Step 4: Creating application user...${NC}"
id -u $APP_USER &>/dev/null || useradd -r -s /bin/bash -d $APP_DIR $APP_USER

echo ""
echo -e "${YELLOW}Step 5: Cloning repository...${NC}"
if [ -d "$APP_DIR" ]; then
    echo "Directory exists, pulling latest changes..."
    cd $APP_DIR && git pull origin main
else
    git clone $REPO_URL $APP_DIR
fi
chown -R $APP_USER:$APP_USER $APP_DIR

echo ""
echo -e "${YELLOW}Step 6: Setting up Python environment...${NC}"
cd $APP_DIR/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements-postgresql.txt
pip install gunicorn

echo ""
echo -e "${YELLOW}Step 7: Creating .env file...${NC}"
cat > $APP_DIR/backend/.env << EOF
# ZUBID Production Configuration
FLASK_ENV=production
FLASK_DEBUG=False

# Security
SECRET_KEY=$SECRET_KEY

# Admin
ADMIN_USERNAME=admin
ADMIN_PASSWORD=ChangeThisPassword123!
ADMIN_EMAIL=admin@$DOMAIN
ADMIN_ID_NUMBER=ADMIN001

# Database
DATABASE_URI=postgresql://zubid_user:$DB_PASSWORD@localhost/zubid_db

# CORS
CORS_ORIGINS=https://$DOMAIN,https://www.$DOMAIN

# Server
HOST=0.0.0.0
PORT=5000
BASE_URL=https://$DOMAIN
HTTPS_ENABLED=true

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATELIMIT_STORAGE_URL=memory://

# Gunicorn
WORKERS=4
TIMEOUT=120
EOF
chown $APP_USER:$APP_USER $APP_DIR/backend/.env
chmod 600 $APP_DIR/backend/.env

echo ""
echo -e "${YELLOW}Step 8: Creating directories...${NC}"
mkdir -p $APP_DIR/backend/logs $APP_DIR/backend/uploads $APP_DIR/backend/instance
chown -R $APP_USER:$APP_USER $APP_DIR

echo ""
echo -e "${YELLOW}Step 9: Configuring Nginx...${NC}"
cat > /etc/nginx/sites-available/zubid << EOF
upstream zubid_backend {
    server 127.0.0.1:5000;
    keepalive 32;
}

server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    client_max_body_size 10M;
    
    location / {
        root $APP_DIR/frontend;
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api {
        proxy_pass http://zubid_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /uploads {
        alias $APP_DIR/backend/uploads;
        expires 30d;
    }
}
EOF

ln -sf /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

echo ""
echo -e "${YELLOW}Step 10: Setting up systemd service...${NC}"
cat > /etc/systemd/system/zubid.service << EOF
[Unit]
Description=ZUBID Auction Platform
After=network.target postgresql.service

[Service]
Type=exec
User=$APP_USER
Group=$APP_USER
WorkingDirectory=$APP_DIR/backend
Environment="PATH=$APP_DIR/backend/venv/bin"
ExecStart=$APP_DIR/backend/venv/bin/gunicorn -c gunicorn_config.py app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable zubid
systemctl start zubid

echo ""
echo -e "${YELLOW}Step 11: Configuring firewall...${NC}"
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Your site is now running at: ${YELLOW}http://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update DNS A records to point to this server's IP"
echo "2. Run: sudo bash scripts/setup-ssl.sh $DOMAIN"
echo "3. Change the admin password in .env file"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  Check status:  sudo systemctl status zubid"
echo "  View logs:     sudo journalctl -u zubid -f"
echo "  Restart:       sudo systemctl restart zubid"
echo ""

