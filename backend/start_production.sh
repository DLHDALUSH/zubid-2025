#!/bin/bash
# ZUBID Production Server Startup Script
# This script starts the Flask application using Gunicorn

echo "=========================================="
echo "ZUBID Production Server Starting..."
echo "=========================================="

# Change to backend directory
cd "$(dirname "$0")"

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default values if not set
export PORT=${PORT:-5000}
export WORKERS=${WORKERS:-4}
export TIMEOUT=${TIMEOUT:-120}
export BIND=${BIND:-0.0.0.0:$PORT}

echo "Configuration:"
echo "  Port: $PORT"
echo "  Workers: $WORKERS"
echo "  Timeout: $TIMEOUT seconds"
echo "  Bind: $BIND"
echo ""

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo "Activating virtual environment..."
    source venv/bin/activate
fi

# Install/upgrade dependencies
echo "Checking dependencies..."
pip install -q -r requirements.txt

# Create necessary directories
mkdir -p logs uploads

# Start Gunicorn
echo "Starting Gunicorn server..."
exec gunicorn \
    -w $WORKERS \
    -b $BIND \
    --timeout $TIMEOUT \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --preload \
    app:app

