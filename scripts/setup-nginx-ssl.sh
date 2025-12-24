#!/bin/bash
# =============================================================================
# ZUBID Nginx and SSL Setup Script
# Run this after deploy-vps.sh
# Usage: sudo bash setup-nginx-ssl.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "=============================================="
echo "    ZUBID Nginx & SSL Setup"
echo "=============================================="
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

read -p "Enter your domain name (e.g., zubid.com): " DOMAIN_NAME
read -p "Enter your email for SSL certificate: " SSL_EMAIL

echo -e "\n${YELLOW}Step 1: Creating systemd service...${NC}"
cat > /etc/systemd/system/zubid.service << EOF
[Unit]
Description=ZUBID Auction Platform
After=network.target

[Service]
User=zubid
Group=zubid
WorkingDirectory=/opt/zubid/backend
Environment="PATH=/opt/zubid/backend/venv/bin"
EnvironmentFile=/opt/zubid/backend/.env
ExecStart=/opt/zubid/backend/venv/bin/gunicorn -c gunicorn_config.py app:app
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=always
RestartSec=5
StandardOutput=append:/opt/zubid/backend/logs/gunicorn.log
StandardError=append:/opt/zubid/backend/logs/gunicorn-error.log

[Install]
WantedBy=multi-user.target
EOF

echo -e "\n${YELLOW}Step 2: Configuring Nginx...${NC}"
cat > /etc/nginx/sites-available/zubid << EOF
upstream zubid_backend {
    server 127.0.0.1:5000;
    keepalive 32;
}

server {
    listen 80;
    server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    client_max_body_size 16M;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;
    
    # Frontend static files
    location / {
        root /opt/zubid/frontend;
        try_files \$uri \$uri/ /index.html;
        expires 1d;
        add_header Cache-Control "public";
    }
    
    # Backend API
    location /api {
        proxy_pass http://zubid_backend;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Uploaded files
    location /uploads {
        alias /opt/zubid/backend/uploads;
        expires 30d;
        add_header Cache-Control "public";
    }
    
    # Static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /opt/zubid/frontend;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location ~ /\. {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx

echo -e "\n${YELLOW}Step 3: Starting ZUBID service...${NC}"
systemctl daemon-reload
systemctl enable zubid
systemctl start zubid

echo -e "\n${YELLOW}Step 4: Setting up SSL certificate...${NC}"
certbot --nginx -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME} --non-interactive --agree-tos -m ${SSL_EMAIL}

echo -e "\n${YELLOW}Step 5: Setting up auto-renewal...${NC}"
systemctl enable certbot.timer
systemctl start certbot.timer

echo -e "\n${GREEN}=============================================="
echo "    DEPLOYMENT COMPLETE!"
echo "=============================================="
echo -e "${NC}"
echo -e "Your ZUBID platform is now live at:"
echo -e "  ${BLUE}https://${DOMAIN_NAME}${NC}"
echo -e "\nAdmin login:"
echo -e "  Username: admin"
echo -e "  Password: (the one you entered)"
echo -e "\nUseful commands:"
echo -e "  ${YELLOW}sudo systemctl status zubid${NC} - Check status"
echo -e "  ${YELLOW}sudo systemctl restart zubid${NC} - Restart service"
echo -e "  ${YELLOW}sudo journalctl -u zubid -f${NC} - View logs"
echo -e "  ${YELLOW}sudo tail -f /opt/zubid/backend/logs/zubid.log${NC} - App logs"

