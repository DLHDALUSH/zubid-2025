#!/bin/bash
# =============================================================================
# ZUBID SSL Certificate Setup Script
# =============================================================================
# Usage: sudo bash setup-ssl.sh yourdomain.com
# 
# This script will:
# 1. Get SSL certificate from Let's Encrypt
# 2. Configure Nginx for HTTPS
# 3. Setup auto-renewal
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN=$1
APP_DIR="/opt/zubid"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ZUBID SSL Certificate Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root${NC}"
    exit 1
fi

# Check domain argument
if [ -z "$DOMAIN" ]; then
    read -p "Enter your domain name (e.g., zubid.com): " DOMAIN
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}Error: Domain name is required${NC}"
        exit 1
    fi
fi

# Get email for Let's Encrypt
read -p "Enter your email for SSL certificate notifications: " EMAIL
if [ -z "$EMAIL" ]; then
    echo -e "${RED}Error: Email is required${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 1: Verifying DNS configuration...${NC}"
echo "Please ensure your DNS A records point to this server:"
echo "  $DOMAIN -> $(curl -s ifconfig.me)"
echo "  www.$DOMAIN -> $(curl -s ifconfig.me)"
echo ""
read -p "Press Enter to continue once DNS is configured..."

echo ""
echo -e "${YELLOW}Step 2: Obtaining SSL certificate...${NC}"
certbot --nginx \
    -d $DOMAIN \
    -d www.$DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --non-interactive \
    --redirect

echo ""
echo -e "${YELLOW}Step 3: Updating backend configuration...${NC}"
if [ -f "$APP_DIR/backend/.env" ]; then
    sed -i "s|BASE_URL=http://|BASE_URL=https://|g" $APP_DIR/backend/.env
    sed -i "s|HTTPS_ENABLED=false|HTTPS_ENABLED=true|g" $APP_DIR/backend/.env
fi

echo ""
echo -e "${YELLOW}Step 4: Restarting services...${NC}"
systemctl restart nginx
systemctl restart zubid 2>/dev/null || echo "Note: zubid service may not be running"

echo ""
echo -e "${YELLOW}Step 5: Testing auto-renewal...${NC}"
certbot renew --dry-run

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   SSL Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Your site is now secure at: ${GREEN}https://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}Certificate Info:${NC}"
certbot certificates --cert-name $DOMAIN 2>/dev/null || true
echo ""
echo "Certificate will auto-renew before expiration."
echo ""

