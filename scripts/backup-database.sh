#!/bin/bash
# =============================================================================
# ZUBID Database Backup Script
# Usage: sudo bash backup-database.sh
# Add to cron for automatic backups:
#   sudo crontab -e
#   0 2 * * * /opt/zubid/scripts/backup-database.sh
# =============================================================================

set -e

BACKUP_DIR="/opt/zubid/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_PATH="/opt/zubid/backend/instance/auction.db"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup SQLite database
if [ -f "$DB_PATH" ]; then
    echo "Backing up database..."
    cp $DB_PATH $BACKUP_DIR/auction_${DATE}.db
    
    # Compress backup
    gzip $BACKUP_DIR/auction_${DATE}.db
    
    # Keep only last 30 backups
    ls -t $BACKUP_DIR/*.gz | tail -n +31 | xargs -r rm
    
    echo "Backup complete: $BACKUP_DIR/auction_${DATE}.db.gz"
else
    echo "Database not found at $DB_PATH"
fi

# Backup uploads folder
echo "Backing up uploads..."
tar -czf $BACKUP_DIR/uploads_${DATE}.tar.gz -C /opt/zubid/backend uploads

# Keep only last 7 upload backups
ls -t $BACKUP_DIR/uploads_*.tar.gz | tail -n +8 | xargs -r rm

echo "All backups complete!"
ls -la $BACKUP_DIR/

