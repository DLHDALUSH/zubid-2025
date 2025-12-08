#!/bin/bash
# =============================================================================
# ZUBID Health Check Script
# =============================================================================
# Usage: bash health-check.sh
# Checks the status of all ZUBID services
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN=${1:-"localhost"}
APP_DIR="/opt/zubid"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ZUBID Health Check${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check ZUBID service
echo -n "ZUBID Service:        "
if systemctl is-active --quiet zubid 2>/dev/null; then
    echo -e "${GREEN}[RUNNING]${NC}"
else
    echo -e "${RED}[STOPPED]${NC}"
fi

# Check Nginx
echo -n "Nginx:                "
if systemctl is-active --quiet nginx 2>/dev/null; then
    echo -e "${GREEN}[RUNNING]${NC}"
else
    echo -e "${RED}[STOPPED]${NC}"
fi

# Check PostgreSQL
echo -n "PostgreSQL:           "
if systemctl is-active --quiet postgresql 2>/dev/null; then
    echo -e "${GREEN}[RUNNING]${NC}"
else
    echo -e "${YELLOW}[NOT RUNNING/USING SQLITE]${NC}"
fi

# Check API endpoint
echo -n "API Health:           "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5000/api/test 2>/dev/null || echo "000")
if [ "$HTTP_CODE" == "200" ]; then
    echo -e "${GREEN}[OK] (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}[FAILED] (HTTP $HTTP_CODE)${NC}"
fi

# Check SSL certificate
if [ "$DOMAIN" != "localhost" ]; then
    echo -n "SSL Certificate:      "
    CERT_EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$CERT_EXPIRY" ]; then
        echo -e "${GREEN}[VALID] Expires: $CERT_EXPIRY${NC}"
    else
        echo -e "${YELLOW}[NOT CONFIGURED]${NC}"
    fi
fi

# Check disk space
echo ""
echo -e "${YELLOW}Disk Usage:${NC}"
df -h $APP_DIR 2>/dev/null || df -h /

# Check memory
echo ""
echo -e "${YELLOW}Memory Usage:${NC}"
free -h

# Check recent errors
echo ""
echo -e "${YELLOW}Recent Errors (last 5):${NC}"
journalctl -u zubid --no-pager -p err -n 5 2>/dev/null || echo "No errors found"

# Check uptime
echo ""
echo -e "${YELLOW}Service Uptime:${NC}"
systemctl show zubid --property=ActiveEnterTimestamp 2>/dev/null | cut -d= -f2 || echo "Service not running"

echo ""
echo -e "${GREEN}========================================${NC}"
echo "Run 'journalctl -u zubid -f' to view live logs"
echo ""

