#!/bin/bash

# Update Nginx configuration to serve frontend files
cat > /etc/nginx/sites-available/zubid << 'EOF'
server {
    server_name zubidauction.duckdns.org;
    
    # Serve frontend static files
    location / {
        root /opt/zubid/frontend;
        try_files $uri $uri/ /index.html;
        expires 1h;
        add_header Cache-Control "public, max-age=3600";
    }
    
    # Serve API requests to backend
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }
    
    # Serve static assets with long cache
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /opt/zubid/frontend;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000, immutable";
    }

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/zubidauction.duckdns.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/zubidauction.duckdns.org/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
    if ($host = zubidauction.duckdns.org) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name zubidauction.duckdns.org;
    return 404;
}
EOF

# Test nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload nginx
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "✅ Nginx configuration updated successfully!"

