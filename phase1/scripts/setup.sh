#!/bin/bash
set -e

echo "================================================="
echo "   EC2 Setup Script — Ubuntu 22.04"
echo "================================================="

# 1. Update system packages
sudo apt-get update -y && sudo apt-get upgrade -y

# 2. Install Node.js 20 LTS
echo "--> Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
hash -r

# 3. Add MongoDB Repository (Crucial for EC2/Ubuntu)
echo "--> Adding MongoDB 7.0 Repository..."
sudo apt-get install -y gnupg curl

# Import the GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg --yes

# Add the source list for Ubuntu 22.04 (jammy)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update package list again
sudo apt-get update -y

# 4. Install MongoDB, Git & Tools
echo "--> Installing MongoDB and Git..."
sudo apt-get install -y git mongodb-org

# Start and enable MongoDB
sudo systemctl daemon-reload
sudo systemctl start mongod
sudo systemctl enable mongod

# 5. Install PM2 globally
sudo npm install -g pm2

# 6. Project Setup
echo "--> Setting up application..."
# Note: Ensure you have cloned your repo to ~/DevOps-Midterm before running this
if [ -d "$HOME/DevOps-Midterm/app" ]; then
    cd "$HOME/DevOps-Midterm/app"
    npm install
else
    echo "❌ Error: Directory ~/DevOps-Midterm/app not found!"
    exit 1
fi

# 7. FIX FOR EADDRINUSE
echo "--> Clearing Port 3000..."
sudo fuser -k 3000/tcp || true

# 8. Start the app with PM2
echo "--> Starting app with PM2..."
pm2 delete midterm-app || true 
pm2 start main.js --name "midterm-app"

# 9. Final Health Check
echo "--> Verifying deployment..."
sleep 5 # Give the app a second to boot
if curl -s --head  --request GET http://localhost:3000 | grep "200 OK" > /dev/null; then 
   echo "✅ SUCCESS: App is responding on Port 3000!"
else
   echo "⚠️ WARNING: App started but is not responding on Port 3000. Check 'pm2 logs'."
fi

echo "================================================="
echo "   REMINDER: Update your EC2 Security Group!"
echo "   Allow Inbound TCP traffic on Port 3000."
echo "================================================="