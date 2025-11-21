#!/bin/bash
# Database Backup Script for ZUBID
# This script creates a backup of the database (PostgreSQL or SQLite)

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/opt/zubid/backups}"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Database type detection
DB_TYPE="${DB_TYPE:-postgresql}"  # postgresql or sqlite
DB_NAME="${DB_NAME:-zubid_db}"
DB_USER="${DB_USER:-zubid_user}"
SQLITE_DB_PATH="${SQLITE_DB_PATH:-instance/auction.db}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Creating database backup..."
echo "Database type: $DB_TYPE"

if [ "$DB_TYPE" = "postgresql" ]; then
    # PostgreSQL backup
    if ! command -v pg_dump &> /dev/null; then
        echo "ERROR: pg_dump not found. Please install PostgreSQL client tools."
        exit 1
    fi
    
    BACKUP_FILE="$BACKUP_DIR/zubid_$DATE.sql"
    PGPASSWORD="${DB_PASSWORD}" pg_dump -U "$DB_USER" -h localhost "$DB_NAME" > "$BACKUP_FILE"
    
    if [ ! -f "$BACKUP_FILE" ] || [ ! -s "$BACKUP_FILE" ]; then
        echo "ERROR: PostgreSQL backup failed!"
        exit 1
    fi
    
    # Compress backup
    gzip "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE.gz"
    
    # Remove old backups
    echo "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    find "$BACKUP_DIR" -name "zubid_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    
elif [ "$DB_TYPE" = "sqlite" ]; then
    # SQLite backup
    if [ ! -f "$SQLITE_DB_PATH" ]; then
        echo "ERROR: SQLite database not found at: $SQLITE_DB_PATH"
        exit 1
    fi
    
    BACKUP_FILE="$BACKUP_DIR/zubid_$DATE.db"
    
    # Copy SQLite database file
    cp "$SQLITE_DB_PATH" "$BACKUP_FILE"
    
    if [ ! -f "$BACKUP_FILE" ] || [ ! -s "$BACKUP_FILE" ]; then
        echo "ERROR: SQLite backup failed!"
        exit 1
    fi
    
    # Compress backup
    gzip "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE.gz"
    
    # Remove old backups
    echo "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    find "$BACKUP_DIR" -name "zubid_*.db.gz" -mtime +$RETENTION_DAYS -delete
    
else
    echo "ERROR: Unknown database type: $DB_TYPE"
    echo "Supported types: postgresql, sqlite"
    exit 1
fi

echo "Backup completed successfully!"

