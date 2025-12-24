#!/bin/bash
# =============================================================================
# ZUBID Database Setup Script
# =============================================================================
# Usage: sudo bash setup-database.sh [sqlite|postgresql|mysql]
# 
# This script helps setup the database for ZUBID
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DB_TYPE=${1:-"postgresql"}
APP_DIR="/opt/zubid"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ZUBID Database Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

case $DB_TYPE in
    "sqlite")
        echo -e "${YELLOW}Setting up SQLite database...${NC}"
        echo ""
        
        # Create directory
        mkdir -p $APP_DIR/backend/instance
        
        # Update .env
        if [ -f "$APP_DIR/backend/.env" ]; then
            sed -i "s|DATABASE_URI=.*|DATABASE_URI=sqlite:///instance/auction.db|g" $APP_DIR/backend/.env
        fi
        
        echo -e "${GREEN}SQLite setup complete!${NC}"
        echo "Database will be created at: $APP_DIR/backend/instance/auction.db"
        ;;
        
    "postgresql")
        echo -e "${YELLOW}Setting up PostgreSQL database...${NC}"
        echo ""
        
        # Check if PostgreSQL is installed
        if ! command -v psql &> /dev/null; then
            echo "Installing PostgreSQL..."
            apt update && apt install -y postgresql postgresql-contrib
        fi
        
        # Get password
        read -sp "Enter password for PostgreSQL user 'zubid_user': " DB_PASSWORD
        echo ""
        
        # Create database and user
        echo "Creating database and user..."
        sudo -u postgres psql << EOF
CREATE DATABASE zubid_db;
CREATE USER zubid_user WITH PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE zubid_db TO zubid_user;
ALTER USER zubid_user CREATEDB;
\c zubid_db
GRANT ALL ON SCHEMA public TO zubid_user;
EOF
        
        # Install Python driver
        echo "Installing Python PostgreSQL driver..."
        cd $APP_DIR/backend
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        pip install psycopg2-binary
        
        # Update .env
        if [ -f "$APP_DIR/backend/.env" ]; then
            sed -i "s|DATABASE_URI=.*|DATABASE_URI=postgresql://zubid_user:$DB_PASSWORD@localhost/zubid_db|g" $APP_DIR/backend/.env
        fi
        
        echo ""
        echo -e "${GREEN}PostgreSQL setup complete!${NC}"
        echo ""
        echo "Connection string: postgresql://zubid_user:****@localhost/zubid_db"
        ;;
        
    "mysql")
        echo -e "${YELLOW}Setting up MySQL database...${NC}"
        echo ""
        
        # Check if MySQL is installed
        if ! command -v mysql &> /dev/null; then
            echo "Installing MySQL..."
            apt update && apt install -y mysql-server
            mysql_secure_installation
        fi
        
        # Get password
        read -sp "Enter password for MySQL user 'zubid_user': " DB_PASSWORD
        echo ""
        
        # Create database and user
        echo "Creating database and user..."
        mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS zubid_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'zubid_user'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON zubid_db.* TO 'zubid_user'@'localhost';
FLUSH PRIVILEGES;
EOF
        
        # Install Python driver
        echo "Installing Python MySQL driver..."
        cd $APP_DIR/backend
        source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
        pip install pymysql
        
        # Update .env
        if [ -f "$APP_DIR/backend/.env" ]; then
            sed -i "s|DATABASE_URI=.*|DATABASE_URI=mysql+pymysql://zubid_user:$DB_PASSWORD@localhost/zubid_db|g" $APP_DIR/backend/.env
        fi
        
        echo ""
        echo -e "${GREEN}MySQL setup complete!${NC}"
        ;;
        
    *)
        echo -e "${RED}Unknown database type: $DB_TYPE${NC}"
        echo "Usage: bash setup-database.sh [sqlite|postgresql|mysql]"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}Restarting ZUBID service...${NC}"
systemctl restart zubid 2>/dev/null || echo "Service not running - start manually"

echo ""
echo -e "${GREEN}Database setup complete!${NC}"

