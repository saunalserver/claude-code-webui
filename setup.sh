#!/bin/bash

# Claude Code WebUI - Interactive Setup Script

# Colors for better UI
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}   Claude Code WebUI - Setup Wizard    ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

# Prerequisite check
echo -e "${YELLOW}Checking prerequisites...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Note: 'node' not found. This project can also be run via Docker.${NC}"
fi
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Warning: 'docker' not found. Docker is recommended for this project.${NC}"
fi
echo "Done."
echo ""

# Configuration gathering
echo -e "${BLUE}--- Configuration ---${NC}"

# Port
read -p "Enter the server port [default: 3420]: " port
port=${port:-3420}

# Public URL
echo -e "Optional: Enter the public URL for serving images (e.g., https://claude.yourdomain.com)"
read -p "Public URL [leave empty if unknown]: " public_url

# Generate .env file
echo ""
echo -e "${YELLOW}Generating .env file...${NC}"
cat > .env << EOF
PORT=$port
PUBLIC_URL=$public_url
EOF

echo -e "${GREEN}Configuration saved to .env!${NC}"
echo ""

# Volume Reminder
echo -e "${BLUE}--- Important: Docker Volumes ---${NC}"
echo -e "This project mounts your ${YELLOW}~/.claude${NC} directory for authentication."
echo -e "Ensure this directory exists and has the correct permissions for the container user."
echo ""

# Installation
read -p "Would you like to build and start the Docker container now? (y/n): " docker_choice
if [[ "$docker_choice" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Building and starting container...${NC}"
    docker compose up -d --build
    echo -e "${GREEN}Container started successfully!${NC}"
else
    read -p "Would you like to install local dependencies instead? (y/n): " install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing dependencies...${NC}"
        npm install
        echo -e "${GREEN}Dependencies installed successfully!${NC}"
    fi
fi

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}   Setup Complete!                     ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""
echo -e "To start the application:"
echo -e "Docker: ${BLUE}docker compose up -d${NC}"
echo -e "Local:  ${BLUE}npm start${NC}"
echo ""
