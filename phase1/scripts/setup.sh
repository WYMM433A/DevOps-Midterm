#!/bin/bash

set -e

echo "================================================"
echo "  Server Setup Script — Ubuntu 22.04"
echo "================================================"


# ── Update system packages ───
echo ""
sudo apt-get update -y && sudo apt-get upgrade -y

# ── Install NPM 
npm install

# ── Install Node.js 20 LTS ──
echo ""
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# ── Install Git ──
sudo apt-get install -y git

# ── Install MongoDB 6.0 ──
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

sudo apt-get update -y
sudo apt-get install -y mongodb-org

# Start and enable MongoDB to run on boot
sudo systemctl start mongod
sudo systemctl enable mongod

# ── Install PM2 process manager ──
sudo npm install -g pm2
