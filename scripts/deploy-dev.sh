#!/bin/bash

# ===========================
# WindNewsMapper - Development Deployment Script
# ===========================
# This script deploys the application to the development environment
# Target: dev.windnews.rabciak.site

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DEPLOY_ENV="development"
BRANCH="develop"
COMPOSE_FILE="docker-compose.yml"
PROJECT_DIR="/opt/windnewsmapper-dev"  # Adjust to your server path

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WindNewsMapper - Development Deployment${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if running on server or locally
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    echo -e "${GREEN}✓${NC} Changed to project directory: $PROJECT_DIR"
else
    echo -e "${YELLOW}⚠${NC}  Running locally (not on server)"
    PROJECT_DIR="."
fi

# Step 1: Pull latest code
echo -e "\n${YELLOW}[1/7]${NC} Pulling latest code from branch: $BRANCH"
git fetch origin
git checkout "$BRANCH"
git pull origin "$BRANCH"
echo -e "${GREEN}✓${NC} Code updated"

# Step 2: Check environment file
echo -e "\n${YELLOW}[2/7]${NC} Checking environment configuration"
if [ ! -f ".env" ]; then
    echo -e "${RED}✗${NC} .env file not found!"
    echo -e "${YELLOW}  Creating from .env.development.example...${NC}"
    cp .env.development.example .env
    echo -e "${RED}  Please edit .env with correct values and run this script again.${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Environment configuration found"

# Step 3: Stop running containers
echo -e "\n${YELLOW}[3/7]${NC} Stopping running containers"
docker-compose -f "$COMPOSE_FILE" down
echo -e "${GREEN}✓${NC} Containers stopped"

# Step 4: Build new images
echo -e "\n${YELLOW}[4/7]${NC} Building Docker images"
docker-compose -f "$COMPOSE_FILE" build --no-cache
echo -e "${GREEN}✓${NC} Images built"

# Step 5: Start containers
echo -e "\n${YELLOW}[5/7]${NC} Starting containers"
docker-compose -f "$COMPOSE_FILE" up -d
echo -e "${GREEN}✓${NC} Containers started"

# Step 6: Run database migrations
echo -e "\n${YELLOW}[6/7]${NC} Running database migrations"
sleep 5  # Wait for database to be ready
docker-compose -f "$COMPOSE_FILE" exec -T backend alembic upgrade head
echo -e "${GREEN}✓${NC} Migrations completed"

# Step 7: Health check
echo -e "\n${YELLOW}[7/7]${NC} Performing health check"
sleep 5  # Wait for services to start

# Check backend health
if command -v curl &> /dev/null; then
    echo -e "  Checking backend..."
    if curl -f http://localhost:8000/health &> /dev/null; then
        echo -e "${GREEN}✓${NC} Backend is healthy"
    else
        echo -e "${RED}✗${NC} Backend health check failed"
        echo -e "${YELLOW}  Check logs with: docker-compose logs backend${NC}"
    fi
else
    echo -e "${YELLOW}⚠${NC}  curl not found, skipping health check"
fi

# Display container status
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Status${NC}"
echo -e "${GREEN}========================================${NC}"
docker-compose -f "$COMPOSE_FILE" ps

# Display logs command
echo -e "\n${YELLOW}View logs with:${NC}"
echo -e "  docker-compose logs -f"
echo -e "  docker-compose logs -f backend"
echo -e "  docker-compose logs -f frontend"

# Display URLs
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Development URLs${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Frontend:   ${GREEN}http://localhost:5173${NC}"
echo -e "Backend:    ${GREEN}http://localhost:8000${NC}"
echo -e "API Docs:   ${GREEN}http://localhost:8000/docs${NC}"

echo -e "\n${GREEN}✓ Development deployment completed!${NC}\n"
