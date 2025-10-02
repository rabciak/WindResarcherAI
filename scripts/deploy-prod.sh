#!/bin/bash

# ===========================
# WindNewsMapper - Production Deployment Script
# ===========================
# This script deploys the application to the production environment
# Target: windnews.rabciak.site

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEPLOY_ENV="production"
BRANCH="main"
COMPOSE_FILE="docker-compose.prod.yml"  # Use production compose file
PROJECT_DIR="/opt/windnewsmapper"  # Adjust to your server path
BACKUP_DIR="/opt/backups/windnewsmapper"

echo -e "${RED}========================================${NC}"
echo -e "${RED}WindNewsMapper - PRODUCTION Deployment${NC}"
echo -e "${RED}========================================${NC}"

# Safety confirmation
echo -e "${YELLOW}⚠  WARNING: This will deploy to PRODUCTION!${NC}"
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^yes$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

# Check if running on server
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    echo -e "${GREEN}✓${NC} Changed to project directory: $PROJECT_DIR"
else
    echo -e "${RED}✗${NC} Project directory not found: $PROJECT_DIR"
    echo -e "${YELLOW}  Are you running this on the production server?${NC}"
    exit 1
fi

# Step 1: Create backup
echo -e "\n${YELLOW}[1/9]${NC} Creating database backup"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"
docker-compose -f "$COMPOSE_FILE" exec -T db pg_dump -U winduser_prod windnewsdb_prod > "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Backup created: $BACKUP_FILE"

# Step 2: Pull latest code
echo -e "\n${YELLOW}[2/9]${NC} Pulling latest code from branch: $BRANCH"
git fetch origin
git checkout "$BRANCH"

# Store current commit for rollback
PREVIOUS_COMMIT=$(git rev-parse HEAD)
echo -e "${BLUE}  Current commit: $PREVIOUS_COMMIT${NC}"

git pull origin "$BRANCH"
echo -e "${GREEN}✓${NC} Code updated"

# Step 3: Check environment file
echo -e "\n${YELLOW}[3/9]${NC} Checking environment configuration"
if [ ! -f ".env.production" ]; then
    echo -e "${RED}✗${NC} .env.production file not found!"
    echo -e "${YELLOW}  Please create .env.production from .env.production.example${NC}"
    exit 1
fi

# Validate critical environment variables
if ! grep -q "DEBUG=False" .env.production; then
    echo -e "${RED}✗${NC} WARNING: DEBUG should be False in production!"
    read -p "Continue anyway? (yes/no): " -r
    if [[ ! $REPLY =~ ^yes$ ]]; then
        exit 1
    fi
fi
echo -e "${GREEN}✓${NC} Environment configuration validated"

# Step 4: Build new images
echo -e "\n${YELLOW}[4/9]${NC} Building Docker images"
docker-compose -f "$COMPOSE_FILE" build --no-cache
echo -e "${GREEN}✓${NC} Images built"

# Step 5: Stop running containers (gracefully)
echo -e "\n${YELLOW}[5/9]${NC} Stopping running containers"
docker-compose -f "$COMPOSE_FILE" down --timeout 30
echo -e "${GREEN}✓${NC} Containers stopped"

# Step 6: Start new containers
echo -e "\n${YELLOW}[6/9]${NC} Starting new containers"
docker-compose -f "$COMPOSE_FILE" up -d
echo -e "${GREEN}✓${NC} Containers started"

# Step 7: Wait for services to be ready
echo -e "\n${YELLOW}[7/9]${NC} Waiting for services to be ready"
sleep 10
echo -e "${GREEN}✓${NC} Services should be ready"

# Step 8: Run database migrations
echo -e "\n${YELLOW}[8/9]${NC} Running database migrations"
docker-compose -f "$COMPOSE_FILE" exec -T backend alembic upgrade head
echo -e "${GREEN}✓${NC} Migrations completed"

# Step 9: Health check
echo -e "\n${YELLOW}[9/9]${NC} Performing health check"
HEALTH_CHECK_PASSED=true

# Check backend health
echo -e "  Checking backend..."
if curl -f http://localhost:8000/health &> /dev/null; then
    echo -e "${GREEN}✓${NC} Backend is healthy"
else
    echo -e "${RED}✗${NC} Backend health check failed"
    HEALTH_CHECK_PASSED=false
fi

# Check if we can reach the API
echo -e "  Checking API endpoints..."
if curl -f http://localhost:8000/api/stats &> /dev/null; then
    echo -e "${GREEN}✓${NC} API is responding"
else
    echo -e "${RED}✗${NC} API health check failed"
    HEALTH_CHECK_PASSED=false
fi

# If health check failed, offer rollback
if [ "$HEALTH_CHECK_PASSED" = false ]; then
    echo -e "\n${RED}========================================${NC}"
    echo -e "${RED}HEALTH CHECK FAILED!${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "${YELLOW}Check logs with: docker-compose -f $COMPOSE_FILE logs${NC}"

    read -p "Do you want to rollback to previous version? (yes/no): " -r
    if [[ $REPLY =~ ^yes$ ]]; then
        echo -e "\n${YELLOW}Rolling back to commit: $PREVIOUS_COMMIT${NC}"
        git reset --hard "$PREVIOUS_COMMIT"
        docker-compose -f "$COMPOSE_FILE" up -d --build
        echo -e "${GREEN}✓${NC} Rollback completed"
        exit 1
    fi
fi

# Display container status
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Status${NC}"
echo -e "${GREEN}========================================${NC}"
docker-compose -f "$COMPOSE_FILE" ps

# Display logs command
echo -e "\n${YELLOW}View logs with:${NC}"
echo -e "  docker-compose -f $COMPOSE_FILE logs -f"

# Display URLs
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Production URLs${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Frontend:   ${GREEN}https://windnews.rabciak.site${NC}"
echo -e "Backend:    ${GREEN}https://api.windnews.rabciak.site${NC}"
echo -e "API Docs:   ${GREEN}https://api.windnews.rabciak.site/docs${NC}"

# Cleanup old backups (keep last 30 days)
echo -e "\n${YELLOW}Cleaning up old backups...${NC}"
find "$BACKUP_DIR" -name "backup_*.sql" -mtime +30 -delete
echo -e "${GREEN}✓${NC} Old backups cleaned"

echo -e "\n${GREEN}✓ Production deployment completed successfully!${NC}\n"

# Send notification (optional - uncomment if you have a notification system)
# curl -X POST -H 'Content-type: application/json' \
#   --data '{"text":"✓ WindNewsMapper deployed to production"}' \
#   YOUR_WEBHOOK_URL
