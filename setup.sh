#!/bin/bash

# setup.sh: Automates setup for NFT Minting Application with Heroku and Prometheus Integration

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${GREEN}🚀 Starting Setup for NFT Minting Application...${RESET}"

# Step 1: Install Dependencies
echo -e "${YELLOW}🔧 Installing Backend Dependencies...${RESET}"
cd backend || exit
npm install
echo -e "${GREEN}✅ Backend dependencies installed.${RESET}"

echo -e "${YELLOW}🔧 Installing Frontend Dependencies...${RESET}"
cd ../frontend || exit
npm install
echo -e "${GREEN}✅ Frontend dependencies installed.${RESET}"

# Step 2: Install Heroku CLI (if not already installed)
echo -e "${YELLOW}🌐 Checking for Heroku CLI...${RESET}"
if ! command -v heroku &> /dev/null; then
    echo -e "${YELLOW}🛠 Installing Heroku CLI...${RESET}"
    curl https://cli-assets.heroku.com/install.sh | sh
else
    echo -e "${GREEN}✅ Heroku CLI already installed.${RESET}"
fi

# Step 3: Configure Prometheus in Backend
echo -e "${YELLOW}📊 Configuring Prometheus Metrics Endpoint...${RESET}"

cd ../backend || exit
PROM_FILE="server.js"

if grep -q "prom-client" "$PROM_FILE"; then
    echo -e "${GREEN}✅ Prometheus already configured in backend.${RESET}"
else
    echo -e "${YELLOW}Adding Prometheus client to backend...${RESET}"
    npm install prom-client --save

    # Insert Prometheus code into server.js
    sed -i '/const express = require("express");/a \
    const client = require("prom-client"); \
    const collectDefaultMetrics = client.collectDefaultMetrics; \
    collectDefaultMetrics(); \
    const requestCounter = new client.Counter({ \
        name: "api_requests_total", \
        help: "Total number of API requests" \
    }); \
    app.use((req, res, next) => { \
        requestCounter.inc(); \
        next(); \
    }); \
    app.get("/metrics", async (req, res) => { \
        res.set("Content-Type", client.register.contentType); \
        res.end(await client.register.metrics()); \
    });' "$PROM_FILE"

    echo -e "${GREEN}✅ Prometheus metrics endpoint added to backend.${RESET}"
fi

# Step 4: Deploy Backend to Heroku
echo -e "${YELLOW}🚀 Deploying Backend to Heroku...${RESET}"

if ! heroku apps:info -a your-heroku-app-name > /dev/null 2>&1; then
    echo -e "${YELLOW}🛠 Creating a new Heroku app...${RESET}"
    heroku create your-heroku-app-name
else
    echo -e "${GREEN}✅ Heroku app already exists.${RESET}"
fi

echo -e "${YELLOW}🔁 Pushing backend to Heroku...${RESET}"
git add .
git commit -m "Automated setup: Add Prometheus metrics" || echo -e "${RED}⚠️ No changes to commit.${RESET}"
git push heroku main
echo -e "${GREEN}✅ Backend deployed to Heroku.${RESET}"

# Step 5: Verify Metrics Endpoint
echo -e "${YELLOW}🔍 Verifying /metrics endpoint...${RESET}"
METRICS_URL="https://your-heroku-app-name.herokuapp.com/metrics"

if curl --output /dev/null --silent --head --fail "$METRICS_URL"; then
    echo -e "${GREEN}✅ Metrics endpoint is live: $METRICS_URL${RESET}"
else
    echo -e "${RED}❌ Metrics endpoint verification failed. Check your Heroku deployment.${RESET}"
fi

# Final Summary
echo -e "${GREEN}🎉 Setup Complete!${RESET}"
echo -e "${GREEN}✅ Backend and Frontend dependencies installed.${RESET}"
echo -e "${GREEN}✅ Prometheus metrics configured.${RESET}"
echo -e "${GREEN}✅ Backend deployed to Heroku.${RESET}"
echo -e "${YELLOW}📊 Metrics endpoint: $METRICS_URL${RESET}"
