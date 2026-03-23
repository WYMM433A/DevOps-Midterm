#!/bin/bash
set -e

echo "================================================="
echo "   Pure Docker Deployment Script (with Auto-HTTPS)"
echo "   Domain: vestarex20.shop"
echo "================================================="


# 1. Update system packages
echo "--> Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# 2. Install Docker & Docker Compose
echo "--> Installing Docker..."
sudo apt-get install -y docker.io docker-compose-v2
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu || true

# 3. Install Nginx and Certbot
echo "--> Installing Nginx and SSL tools..."
sudo apt-get install -y nginx certbot python3-certbot-nginx

# 4. Project Setup & Git Pull
echo "--> Setting up application repository..."
if [ -d "$HOME/DevOps-Midterm/app" ]; then
    cd "$HOME/DevOps-Midterm/app"
    git pull origin main 
else
    echo "❌ Error: Directory ~/DevOps-Midterm/app not found!"
    exit 1
fi

# 5. Create .env if it doesn't exist (Updated for Docker network)
echo "--> Checking .env file..."
if [ ! -f "$HOME/DevOps-Midterm/app/.env" ]; then
    echo "    ⚠️  No .env found — creating default for Docker..."
    cat <<EOL > "$HOME/DevOps-Midterm/app/.env"
PORT=3000
# IMPORTANT: Points to the Docker service name 'database', not localhost
MONGO_URI=mongodb://database:27017/products_db
EOL
    echo "    ✓ .env created"
else
    echo "    ✓ .env already exists"
fi

# 6. Clear Port 3000 (Safety check)
echo "--> Clearing Port 3000..."
sudo fuser -k 3000/tcp || true

# 7. Pull Images and Deploy via Docker Compose
echo "--> Deploying Docker containers..."
# Use sudo here to ensure the usermod group change doesn't cause a permission hiccup on first run
cd "$HOME/DevOps-Midterm/phase3"
sudo docker compose pull
sudo docker compose up -d

# 8. Create Nginx Configuration
echo "--> Configuring Nginx for vestarex20.shop..."
cat <<EOF | sudo tee /etc/nginx/sites-available/vesta-app
server {
    listen 80;
    server_name vestarex20.shop www.vestarex20.shop;

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

# 9. Enable Nginx config and restart
sudo ln -sf /etc/nginx/sites-available/vesta-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# 10. Automate SSL Certificate Generation
echo "--> Securing domain with Let's Encrypt (HTTPS)..."
sudo certbot --nginx \
    -d vestarex20.shop -d www.vestarex20.shop \
    --non-interactive \
    --agree-tos \
    -m admin@vestarex20.shop \
    --redirect

echo "================================================="
echo "   Deployment Complete!"
echo "   App is running in Docker and secured with HTTPS."
echo "================================================="