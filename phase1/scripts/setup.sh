#!/bin/bash
set -e

echo "================================================="
echo "   Server Setup Script — Ubuntu 22.04"
echo "================================================="

# 1. Update system packages
sudo apt-get update -y && sudo apt-get upgrade -y

# 2. Install Node.js 20 LTS
echo "--> Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
hash -r

# 3. Install MongoDB & Tools
sudo apt-get install -y git mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# 4. Install PM2 globally
sudo npm install -g pm2

# 5. Project Setup
echo "--> Setting up application..."
cd ~/DevOps-Midterm/app

# Install dependencies (fixes the 'dotenv' error)
npm install

# 6. FIX FOR EADDRINUSE: Kill anything on Port 3000 before starting
echo "--> Clearing Port 3000..."
sudo fuser -k 3000/tcp || true

# 7. Start the app with PM2
echo "--> Starting app with PM2..."
pm2 delete midterm-app || true  # Delete old instance if it exists
pm2 start main.js --name "midterm-app"

echo "================================================="
echo "   Success! App is running on port 3000."
echo "   Use 'pm2 logs' to see the output."
echo "================================================="