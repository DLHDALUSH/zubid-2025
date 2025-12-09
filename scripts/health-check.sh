#!/bin/bash
# =============================================================================
# ZUBID Health Check Script
# Usage: bash health-check.sh [domain]
# =============================================================================

DOMAIN=${1:-"localhost"}
PROTOCOL=${2:-"https"}

if [ "$DOMAIN" == "localhost" ]; then
    PROTOCOL="http"
    URL="http://localhost:5000"
else
    URL="${PROTOCOL}://${DOMAIN}"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=============================================="
echo "    ZUBID Health Check - ${URL}"
echo "=============================================="

# Check if service is running
echo -n "ZUBID Service: "
if systemctl is-active --quiet zubid 2>/dev/null; then
    echo -e "${GREEN}RUNNING${NC}"
else
    echo -e "${RED}NOT RUNNING${NC}"
fi

# Check Nginx
echo -n "Nginx Service: "
if systemctl is-active --quiet nginx 2>/dev/null; then
    echo -e "${GREEN}RUNNING${NC}"
else
    echo -e "${RED}NOT RUNNING${NC}"
fi

# Check API endpoint
echo -n "API Health: "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${URL}/api/test" --max-time 10 2>/dev/null)
if [ "$RESPONSE" == "200" ]; then
    echo -e "${GREEN}OK (HTTP ${RESPONSE})${NC}"
else
    echo -e "${RED}FAILED (HTTP ${RESPONSE})${NC}"
fi

# Check frontend
echo -n "Frontend: "
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${URL}/" --max-time 10 2>/dev/null)
if [ "$RESPONSE" == "200" ]; then
    echo -e "${GREEN}OK (HTTP ${RESPONSE})${NC}"
else
    echo -e "${RED}FAILED (HTTP ${RESPONSE})${NC}"
fi

# Check disk space
echo -n "Disk Space: "
DISK_USAGE=$(df /opt/zubid 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
if [ -n "$DISK_USAGE" ]; then
    if [ "$DISK_USAGE" -lt 80 ]; then
        echo -e "${GREEN}${DISK_USAGE}% used${NC}"
    elif [ "$DISK_USAGE" -lt 90 ]; then
        echo -e "${YELLOW}${DISK_USAGE}% used (Warning)${NC}"
    else
        echo -e "${RED}${DISK_USAGE}% used (Critical!)${NC}"
    fi
else
    echo -e "${YELLOW}Unknown${NC}"
fi

# Check memory
echo -n "Memory: "
MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
if [ "$MEM_USAGE" -lt 80 ]; then
    echo -e "${GREEN}${MEM_USAGE}% used${NC}"
elif [ "$MEM_USAGE" -lt 90 ]; then
    echo -e "${YELLOW}${MEM_USAGE}% used (Warning)${NC}"
else
    echo -e "${RED}${MEM_USAGE}% used (Critical!)${NC}"
fi

# Check SSL certificate expiry
if [ "$PROTOCOL" == "https" ] && [ "$DOMAIN" != "localhost" ]; then
    echo -n "SSL Certificate: "
    EXPIRY=$(echo | openssl s_client -servername ${DOMAIN} -connect ${DOMAIN}:443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null)
        NOW_EPOCH=$(date +%s)
        DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
        if [ "$DAYS_LEFT" -gt 30 ]; then
            echo -e "${GREEN}Valid (${DAYS_LEFT} days left)${NC}"
        elif [ "$DAYS_LEFT" -gt 7 ]; then
            echo -e "${YELLOW}Expiring soon (${DAYS_LEFT} days left)${NC}"
        else
            echo -e "${RED}Critical! (${DAYS_LEFT} days left)${NC}"
        fi
    else
        echo -e "${YELLOW}Could not check${NC}"
    fi
fi

echo "=============================================="

