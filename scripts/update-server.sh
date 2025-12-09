#!/bin/bash
# =============================================================================
# ZUBID Update Script - Pull latest changes and restart
# Usage: sudo bash update-server.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Updating ZUBID...${NC}"

cd /opt/zubid

# If using git, pull latest changes
if [ -d ".git" ]; then
    echo -e "${YELLOW}Pulling latest changes from git...${NC}"
    sudo -u zubid git pull origin main
fi

# Update Python dependencies
echo -e "${YELLOW}Updating Python dependencies...${NC}"
cd /opt/zubid/backend
sudo -u zubid /opt/zubid/backend/venv/bin/pip install -r requirements.txt

# Run database migrations if needed
echo -e "${YELLOW}Running database migrations...${NC}"
sudo -u zubid /opt/zubid/backend/venv/bin/python -c "from app import app, db; app.app_context().push(); db.create_all()"

# Restart services
echo -e "${YELLOW}Restarting services...${NC}"
systemctl restart zubid
systemctl reload nginx

echo -e "${GREEN}Update complete!${NC}"
echo -e "Check status: sudo systemctl status zubid"

