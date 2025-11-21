# ZUBID Production Deployment Guide

This guide walks you through deploying ZUBID to a production server.

## Prerequisites

- Ubuntu 20.04+ or similar Linux distribution
- Python 3.8+ installed
- Root or sudo access
- Domain name (optional but recommended)
- SSH access to server

## Step 1: Server Setup

### 1.1 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 Install Required Packages
```bash
sudo apt install -y python3-pip python3-venv nginx postgresql postgresql-contrib git
```

### 1.3 Create Application User
```bash
sudo useradd -m -s /bin/bash zubid
sudo usermod -aG sudo zubid
```

## Step 2: Database Setup

### 2.1 Create PostgreSQL Database
```bash
sudo -u postgres psql
```

```sql
CREATE DATABASE zubid_db;
CREATE USER zubid_user WITH PASSWORD 'your_secure_password_here';
ALTER ROLE zubid_user SET client_encoding TO 'utf8';
ALTER ROLE zubid_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE zubid_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE zubid_db TO zubid_user;
\q
```

### 2.2 Install PostgreSQL Python Driver
```bash
sudo apt install -y libpq-dev python3-dev
```

## Step 3: Application Deployment

### 3.1 Clone Repository
```bash
sudo mkdir -p /opt/zubid
sudo chown zubid:zubid /opt/zubid
sudo su - zubid
cd /opt/zubid
git clone https://github.com/yourusername/zubid.git .
# Or upload files via SCP/SFTP
```

### 3.2 Create Virtual Environment
```bash
cd /opt/zubid/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 3.3 Configure Environment Variables
```bash
cp env.example .env
nano .env
```

Update these critical values:
```env
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=your-strong-random-secret-key-here
DATABASE_URI=postgresql://zubid_user:your_secure_password_here@localhost/zubid_db
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
BASE_URL=https://yourdomain.com
HTTPS_ENABLED=true
CSRF_ENABLED=true
RATE_LIMIT_ENABLED=true
LOG_LEVEL=INFO
```

### 3.4 Initialize Database
```bash
cd /opt/zubid/backend
source venv/bin/activate
python -c "from app import app, db; app.app_context().push(); db.create_all()"
```

## Step 4: Configure Gunicorn

### 4.1 Test Gunicorn
```bash
cd /opt/zubid/backend
source venv/bin/activate
gunicorn -c gunicorn_config.py app:app
```

### 4.2 Create Systemd Service
```bash
sudo cp /opt/zubid/backend/zubid.service /etc/systemd/system/
sudo nano /etc/systemd/system/zubid.service
# Update paths if different from /opt/zubid
```

### 4.3 Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
sudo systemctl status zubid
```

## Step 5: Configure Nginx

### 5.1 Copy Nginx Configuration
```bash
sudo cp /opt/zubid/nginx/zubid.conf /etc/nginx/sites-available/zubid
sudo nano /etc/nginx/sites-available/zubid
# Update server_name with your domain
```

### 5.2 Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Step 6: SSL Certificate (Let's Encrypt)

### 6.1 Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 6.2 Obtain Certificate
```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### 6.3 Update Nginx Config
Uncomment HTTPS server block in `/etc/nginx/sites-available/zubid`
Update SSL certificate paths
Reload Nginx: `sudo systemctl reload nginx`

## Step 7: Firewall Configuration

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Step 8: Final Checks

### 8.1 Verify Services
```bash
sudo systemctl status zubid
sudo systemctl status nginx
sudo systemctl status postgresql
```

### 8.2 Check Logs
```bash
sudo journalctl -u zubid -f
sudo tail -f /opt/zubid/backend/logs/zubid.log
sudo tail -f /var/log/nginx/error.log
```

### 8.3 Test Application
- Visit http://yourdomain.com
- Test registration
- Test auction creation
- Test bidding
- Check API endpoints

## Step 9: Maintenance

### 9.1 Database Backups
Create backup script: `/opt/zubid/scripts/backup_db.sh`
```bash
#!/bin/bash
BACKUP_DIR="/opt/zubid/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
pg_dump -U zubid_user zubid_db > $BACKUP_DIR/zubid_$DATE.sql
# Keep only last 7 days
find $BACKUP_DIR -name "zubid_*.sql" -mtime +7 -delete
```

Add to crontab:
```bash
crontab -e
# Add: 0 2 * * * /opt/zubid/scripts/backup_db.sh
```

### 9.2 Update Application
```bash
cd /opt/zubid
git pull
cd backend
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart zubid
```

## Troubleshooting

### Application won't start
- Check logs: `sudo journalctl -u zubid -n 50`
- Verify .env file exists and has correct values
- Check database connection
- Verify Python dependencies installed

### Nginx 502 Bad Gateway
- Check if Gunicorn is running: `sudo systemctl status zubid`
- Verify port 5000 is accessible
- Check Nginx error logs: `sudo tail -f /var/log/nginx/error.log`

### Database Connection Errors
- Verify PostgreSQL is running: `sudo systemctl status postgresql`
- Check database credentials in .env
- Test connection: `psql -U zubid_user -d zubid_db`

### Permission Errors
- Check file ownership: `sudo chown -R zubid:zubid /opt/zubid`
- Verify directory permissions: `sudo chmod -R 755 /opt/zubid`

## Security Checklist

- [ ] Strong SECRET_KEY set
- [ ] FLASK_DEBUG=False
- [ ] CSRF_ENABLED=true
- [ ] CORS_ORIGINS restricted to your domain
- [ ] HTTPS enabled
- [ ] Database credentials secure
- [ ] Firewall configured
- [ ] Regular backups scheduled
- [ ] Logs monitored
- [ ] Default admin password changed

## Performance Optimization

### Redis for Rate Limiting (Optional)
```bash
sudo apt install redis-server
sudo systemctl enable redis
sudo systemctl start redis
```

Update .env:
```env
RATELIMIT_STORAGE_URL=redis://localhost:6379/0
```

### Database Optimization
- Add indexes on frequently queried columns
- Regular VACUUM and ANALYZE
- Monitor slow queries

### Caching
- Consider adding Redis for caching
- Implement CDN for static assets

## Support

For issues, check:
- Application logs: `/opt/zubid/backend/logs/zubid.log`
- System logs: `sudo journalctl -u zubid`
- Nginx logs: `/var/log/nginx/`

