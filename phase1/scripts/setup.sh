#!/bin/bash
set -e

echo "================================================="
echo "   Phase 2 Setup Script (with Auto-HTTPS)"
echo "================================================="

# 1. Update system packages
sudo apt-get update -y && sudo apt-get upgrade -y

# 2. Install Node.js 20 LTS
echo "--> Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
hash -r

# 3. Add MongoDB 7.0 Repository
echo "--> Adding MongoDB 7.0 Repository..."
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg --yes
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update -y

# 4. Install MongoDB
echo "--> Installing MongoDB..."
ssudo apt-get install -y mongodb-org
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl enable mongod

# 5. Install PM2
echo "--> Installing PM2..."
sudo npm install -g pm2

# 6. Project Setup
echo "--> Setting up application..."
if [ -d "$HOME/DevOps-Midterm/app" ]; then
    cd "$HOME/DevOps-Midterm/app"
    npm install
else
    echo "❌ Error: Directory ~/DevOps-Midterm/app not found!"
    exit 1
fi

# 7. Create .env if it doesn't exist
echo "--> Checking .env file..."
if [ ! -f "$HOME/DevOps-Midterm/app/.env" ]; then
    echo "    ⚠️  No .env found — creating default..."
    cat <<EOL > "$HOME/DevOps-Midterm/app/.env"
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
EOL
    echo "    ✓ .env created"
else
    echo "    ✓ .env already exists"
fi

# 8. Clear Port 3000
echo "--> Clearing Port 3000..."
sudo fuser -k 3000/tcp || true

# 9. Start the app with PM2
echo "--> Starting app with PM2..."
pm2 delete midterm-app || true 
pm2 start main.js --name "midterm-app"
pm2 save
pm2 startup | tail -n 1 | bash

# 10. Install Nginx and Certbot
echo "--> Installing Nginx and SSL tools..."
sudo apt-get install -y nginx certbot python3-certbot-nginx

# 11. Create Nginx Configuration
echo "--> Configuring Nginx for wymm.online..."
cat <<EOF | sudo tee /etc/nginx/sites-available/wymm-app
server {
    listen 80;
    server_name wymm.online www.wymm.online;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# 12. Enable config and restart Nginx
sudo ln -sf /etc/nginx/sites-available/wymm-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# 13. Automate SSL Certificate Generation
# The --redirect flag forces all traffic from HTTP to HTTPS
echo "--> Securing domain with Let's Encrypt (HTTPS)..."
sudo certbot --nginx \
    -d wymm.online -d www.wymm.online \
    --non-interactive \
    --agree-tos \
    -m admin@wymm.online \
    --redirect

echo "================================================="
echo "   Phase 2 Setup Complete!"
echo "   Your site is now secured with HTTPS."
echo "================================================="



