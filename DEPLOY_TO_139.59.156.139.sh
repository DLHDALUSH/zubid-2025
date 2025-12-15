#!/bin/bash
# ZUBID Backend Deployment Script for 139.59.156.139
# This script automates the entire deployment process

set -e

SERVER_IP="139.59.156.139"
APP_DIR="/opt/zubid"
BACKEND_DIR="$APP_DIR/backend"
DOMAIN="zubidauction.duckdns.org"

echo "=========================================="
echo "ZUBID Backend Deployment"
echo "Server: $SERVER_IP"
echo "Domain: $DOMAIN"
echo "=========================================="
echo ""

# Step 1: SSH and setup
echo "Step 1: Connecting to server and creating directories..."
ssh -t root@$SERVER_IP << 'EOF'
mkdir -p /opt/zubid
chown $USER:$USER /opt/zubid
cd /opt/zubid
echo "✅ Directories created"
EOF

# Step 2: Clone repository
echo ""
echo "Step 2: Cloning repository..."
ssh -t root@$SERVER_IP << 'EOF'
cd /opt/zubid
git clone https://github.com/DLHDALUSH/zubid-2025.git .
cd backend
echo "✅ Repository cloned"
EOF

# Step 3: Setup Python environment
echo ""
echo "Step 3: Setting up Python environment..."
ssh -t root@$SERVER_IP << 'EOF'
cd /opt/zubid/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo "✅ Python environment ready"
EOF

# Step 4: Configure environment
echo ""
echo "Step 4: Configuring environment..."
ssh -t root@$SERVER_IP << 'EOF'
cd /opt/zubid/backend
cp .env.production .env

# Generate SECRET_KEY
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Update .env with values
sed -i "s/FLASK_ENV=.*/FLASK_ENV=production/" .env
sed -i "s/SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env
sed -i "s|CORS_ORIGINS=.*|CORS_ORIGINS=https://zubid-2025.onrender.com,https://zubidauction.duckdns.org|" .env
sed -i "s/CSRF_ENABLED=.*/CSRF_ENABLED=true/" .env
sed -i "s/HTTPS_ENABLED=.*/HTTPS_ENABLED=true/" .env

echo "✅ Environment configured"
echo "SECRET_KEY: $SECRET_KEY"
EOF

# Step 5: Create directories
echo ""
echo "Step 5: Creating application directories..."
ssh -t root@$SERVER_IP << 'EOF'
cd /opt/zubid/backend
mkdir -p logs uploads instance
echo "✅ Directories created"
EOF

# Step 6: Setup systemd service
echo ""
echo "Step 6: Setting up systemd service..."
ssh -t root@$SERVER_IP << 'EOF'
cd /opt/zubid/backend
sudo cp zubid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zubid
sudo systemctl start zubid
sleep 2
sudo systemctl status zubid
echo "✅ Service started"
EOF

# Step 7: Configure Nginx
echo ""
echo "Step 7: Configuring Nginx..."
ssh -t root@$SERVER_IP << 'EOF'
sudo tee /etc/nginx/sites-available/zubid > /dev/null << 'NGINX'
server {
    listen 80;
    server_name zubidauction.duckdns.org;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/zubid /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
echo "✅ Nginx configured"
EOF

# Step 8: Setup SSL
echo ""
echo "Step 8: Setting up SSL certificate..."
ssh -t root@$SERVER_IP << 'EOF'
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d zubidauction.duckdns.org --non-interactive --agree-tos -m admin@zubidauction.duckdns.org
echo "✅ SSL certificate installed"
EOF

# Step 9: Verify deployment
echo ""
echo "Step 9: Verifying deployment..."
ssh -t root@$SERVER_IP << 'EOF'
echo "Service status:"
sudo systemctl status zubid
echo ""
echo "Testing API endpoint..."
curl -s https://zubidauction.duckdns.org/api/csrf-token | head -c 100
echo ""
echo "✅ Deployment complete!"
EOF

echo ""
echo "=========================================="
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "=========================================="
echo ""
echo "Your backend is now running at:"
echo "  https://zubidauction.duckdns.org"
echo ""
echo "Next steps:"
echo "1. Test web frontend: https://zubid-2025.onrender.com/auctions.html"
echo "2. Test mobile app with baseUrl: https://zubidauction.duckdns.org/api"
echo "3. Monitor logs: ssh root@$SERVER_IP 'sudo journalctl -u zubid -f'"
echo ""

