# ZUBID Production Deployment Guide

## Quick Start Checklist

### 1. Environment Setup
```bash
# Generate SECRET_KEY
python -c "import secrets; print(secrets.token_hex(32))"

# Copy environment template
cp backend/env.example backend/.env

# Edit .env with production values
nano backend/.env
```

### 2. Required Environment Variables
```bash
# REQUIRED
FLASK_ENV=production
SECRET_KEY=<generated-secret-key>
DATABASE_URI=postgresql://user:password@localhost/zubid
CORS_ORIGINS=https://yourdomain.com

# RECOMMENDED
RATELIMIT_STORAGE_URL=redis://localhost:6379/0
BASE_URL=https://yourdomain.com
HTTPS_ENABLED=true
LOG_LEVEL=INFO
```

### 3. Database Setup
```bash
# PostgreSQL (Recommended)
createdb zubid
psql zubid < schema.sql  # If you have one

# Or let the app create tables automatically
python backend/app.py  # Runs init_db() automatically
```

### 4. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
pip install -r requirements-postgresql.txt  # If using PostgreSQL
```

### 5. Start Production Server

#### Option A: Using Gunicorn (Recommended)
```bash
cd backend
gunicorn -c gunicorn_config.py app:app
```

#### Option B: Using Systemd Service (Linux)
```bash
sudo cp backend/zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
```

#### Option C: Using Production Script
```bash
cd backend
./start_production.sh  # Linux/Mac
# or
start_production.bat   # Windows
```

### 6. Nginx Configuration
```bash
# Copy nginx config
sudo cp nginx/zubid.conf /etc/nginx/sites-available/zubid
sudo ln -s /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/

# Edit config with your domain
sudo nano /etc/nginx/sites-available/zubid

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### 7. SSL Certificate (Let's Encrypt)
```bash
sudo certbot --nginx -d yourdomain.com
```

## Verification Steps

1. **Health Check**
   ```bash
   curl https://yourdomain.com/api/health
   ```

2. **Test API**
   ```bash
   curl https://yourdomain.com/api/test
   ```

3. **Check Logs**
   ```bash
   tail -f backend/logs/zubid.log
   ```

## Security Checklist

- [ ] SECRET_KEY is set and strong
- [ ] CORS_ORIGINS is restricted to your domain
- [ ] CSRF_ENABLED=true in production
- [ ] HTTPS is enabled
- [ ] Database credentials are secure
- [ ] File upload directory has proper permissions
- [ ] Rate limiting is enabled
- [ ] Debug mode is OFF

## Monitoring

### Health Check Endpoint
- URL: `/api/health`
- Returns: Database status, upload directory status
- Use for: Load balancer health checks, monitoring tools

### Log Files
- Location: `backend/logs/zubid.log`
- Rotation: Automatic (10MB, 10 backups)
- Level: Set via `LOG_LEVEL` environment variable

## Troubleshooting

### Server Won't Start
1. Check SECRET_KEY is set
2. Check database connection
3. Check port is not in use
4. Review logs: `backend/logs/zubid.log`

### Database Issues
1. Verify DATABASE_URI is correct
2. Check database server is running
3. Verify user has proper permissions
4. Check migrations ran: Look for "[OK]" messages in startup logs

### File Upload Issues
1. Check uploads directory exists and is writable
2. Verify MAX_CONTENT_LENGTH is sufficient
3. Check file permissions: `chmod 755 uploads`

## Backup Strategy

### Database Backup
```bash
# PostgreSQL
pg_dump zubid > backup_$(date +%Y%m%d).sql

# SQLite
cp instance/auction.db backup_$(date +%Y%m%d).db
```

### Automated Backups
Use the provided script:
```bash
./scripts/backup_db.sh
```

Schedule with cron:
```bash
0 2 * * * /path/to/scripts/backup_db.sh
```

## Performance Tuning

### Gunicorn Workers
```bash
# Recommended: (2 x CPU cores) + 1
workers = 9  # For 4-core server
```

### Database Connection Pool
Already configured in `app.py`:
- pool_size: 10
- max_overflow: 20
- pool_recycle: 3600

### Redis for Rate Limiting
```bash
# Install Redis
sudo apt-get install redis-server

# Update .env
RATELIMIT_STORAGE_URL=redis://localhost:6379/0
```

## Rollback Procedure

1. Stop the service
2. Restore database from backup
3. Restore previous code version
4. Restart service
5. Verify functionality

## Support

For issues, check:
1. Application logs: `backend/logs/zubid.log`
2. Nginx logs: `/var/log/nginx/error.log`
3. System logs: `journalctl -u zubid`

