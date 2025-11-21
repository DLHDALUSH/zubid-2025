# Gunicorn Configuration File
# Usage: gunicorn -c gunicorn_config.py app:app

import multiprocessing
import os

# Server socket
bind = f"0.0.0.0:{os.getenv('PORT', '5000')}"
backlog = 2048

# Worker processes
workers = int(os.getenv('WORKERS', multiprocessing.cpu_count() * 2 + 1))
worker_class = 'sync'
worker_connections = 1000
timeout = int(os.getenv('TIMEOUT', '120'))
keepalive = 5

# Logging
accesslog = '-'
errorlog = '-'
loglevel = os.getenv('LOG_LEVEL', 'info').lower()
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'zubid'

# Server mechanics
daemon = False
pidfile = None
umask = 0o022  # Restrictive permissions: 0o755 for dirs, 0o644 for files (prevents world-writable files)
user = None
group = None
tmp_upload_dir = None

# SSL (if needed)
# keyfile = None
# certfile = None

# Preload app for better performance
preload_app = True

# Worker timeout
graceful_timeout = 30

# Maximum requests per worker before restart (prevent memory leaks)
max_requests = 1000
max_requests_jitter = 50

# Logging
capture_output = True
enable_stdio_inheritance = True

