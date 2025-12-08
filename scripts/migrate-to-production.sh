#!/bin/bash
# =============================================================================
# ZUBID Data Migration Script
# =============================================================================
# Migrates data from SQLite (development) to PostgreSQL (production)
# Usage: bash migrate-to-production.sh
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="/opt/zubid"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ZUBID Data Migration${NC}"
echo -e "${GREEN}   SQLite -> PostgreSQL${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if SQLite database exists
SQLITE_DB="$APP_DIR/backend/instance/auction.db"
if [ ! -f "$SQLITE_DB" ]; then
    echo -e "${RED}Error: SQLite database not found at $SQLITE_DB${NC}"
    exit 1
fi

echo -e "${YELLOW}Found SQLite database:${NC} $SQLITE_DB"
echo ""

# Get PostgreSQL connection info
echo "Enter PostgreSQL connection details:"
read -p "Database host [localhost]: " PG_HOST
PG_HOST=${PG_HOST:-localhost}

read -p "Database name [zubid_db]: " PG_DB
PG_DB=${PG_DB:-zubid_db}

read -p "Database user [zubid_user]: " PG_USER
PG_USER=${PG_USER:-zubid_user}

read -sp "Database password: " PG_PASS
echo ""

PG_URI="postgresql://$PG_USER:$PG_PASS@$PG_HOST/$PG_DB"

echo ""
echo -e "${YELLOW}Testing PostgreSQL connection...${NC}"
cd $APP_DIR/backend
source venv/bin/activate

python3 << EOF
from sqlalchemy import create_engine, text
try:
    engine = create_engine("$PG_URI")
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("Connection successful!")
except Exception as e:
    print(f"Connection failed: {e}")
    exit(1)
EOF

echo ""
echo -e "${YELLOW}Creating backup of SQLite database...${NC}"
BACKUP_FILE="$APP_DIR/backend/instance/auction_backup_$(date +%Y%m%d_%H%M%S).db"
cp "$SQLITE_DB" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

echo ""
echo -e "${YELLOW}Running migration script...${NC}"
export POSTGRESQL_URI="$PG_URI"
export SQLITE_PATH="$SQLITE_DB"

python3 migrate_sqlite_to_postgresql.py

echo ""
echo -e "${YELLOW}Updating .env with PostgreSQL connection...${NC}"
if [ -f "$APP_DIR/backend/.env" ]; then
    sed -i "s|DATABASE_URI=sqlite:///.*|DATABASE_URI=$PG_URI|g" $APP_DIR/backend/.env
fi

echo ""
echo -e "${YELLOW}Restarting ZUBID service...${NC}"
systemctl restart zubid 2>/dev/null || echo "Service not running"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Migration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your data has been migrated to PostgreSQL."
echo "Backup file: $BACKUP_FILE"
echo ""

