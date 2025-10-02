# WindNewsMapper - Deployment Guide

This document provides comprehensive deployment instructions for the WindNewsMapper application.

## Table of Contents

- [Branching Strategy](#branching-strategy)
- [Development Workflow](#development-workflow)
- [Environment Setup](#environment-setup)
- [Local Development](#local-development)
- [Deployment to Development (OVH)](#deployment-to-development-ovh)
- [Deployment to Production (OVH)](#deployment-to-production-ovh)
- [Rollback Procedures](#rollback-procedures)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting](#troubleshooting)

---

## Branching Strategy

We follow a **Git Flow** branching model with two main branches:

```
main (production)
  └── develop (staging/development)
       └── feature/* (feature branches)
       └── bugfix/* (bug fix branches)
       └── hotfix/* (urgent production fixes)
```

### Branch Protection Rules

**main branch:**
- ✅ Requires pull request before merging
- ✅ Requires status checks to pass (CI/CD)
- ✅ Requires review from code owner
- ✅ No direct pushes allowed
- ✅ Force push disabled

**develop branch:**
- ✅ Requires pull request before merging
- ✅ Requires status checks to pass (CI/CD)
- ⚠️ Force push disabled

### Branch Naming Conventions

- `feature/description` - New features (e.g., `feature/add-news-filtering`)
- `bugfix/description` - Bug fixes (e.g., `bugfix/fix-map-markers`)
- `hotfix/description` - Urgent production fixes (e.g., `hotfix/security-patch`)
- `docs/description` - Documentation updates (e.g., `docs/update-api-docs`)
- `refactor/description` - Code refactoring (e.g., `refactor/optimize-scraper`)

---

## Development Workflow

### 1. Creating a Feature Branch

```bash
# Ensure you're on develop and up to date
git checkout develop
git pull origin develop

# Create a new feature branch
git checkout -b feature/your-feature-name

# Make your changes...

# Commit using Conventional Commits
git add .
git commit -m "feat: add news filtering by category"

# Push to remote
git push origin feature/your-feature-name
```

### 2. Conventional Commits

All commits should follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

**Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting (no functional changes)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements
- `ci:` - CI/CD changes

**Examples:**
```bash
git commit -m "feat(backend): add pagination to news endpoint"
git commit -m "fix(frontend): resolve map marker positioning bug"
git commit -m "docs: update deployment instructions"
git commit -m "refactor(scraper): optimize HTML parsing logic"
```

### 3. Submitting a Pull Request

1. **Push your branch** to GitHub
2. **Navigate** to the repository on GitHub
3. **Click** "New Pull Request"
4. **Select** base branch (`develop` for features, `main` for hotfixes)
5. **Fill out** the PR template completely
6. **Assign** reviewers
7. **Add** labels (bug, enhancement, documentation, etc.)
8. **Wait** for CI/CD checks to pass
9. **Address** review feedback
10. **Merge** once approved

### 4. Code Review Checklist

Reviewers should check:
- [ ] Code follows project conventions (PEP 8, ESLint)
- [ ] No security vulnerabilities introduced
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or properly documented)
- [ ] Performance implications considered
- [ ] Error handling is appropriate

---

## Environment Setup

### Environment Variables

The project uses three environment configurations:

1. **`.env.example`** - Template with all available variables
2. **`.env.development.example`** - Development-specific settings
3. **`.env.production.example`** - Production-specific settings

**Setup for local development:**
```bash
# Copy the example file
cp .env.development.example .env

# Edit with your values
vim .env  # or nano, code, etc.
```

**Critical variables to configure:**
- `DATABASE_URL` - PostgreSQL connection string
- `CORS_ORIGINS` - Allowed frontend origins
- `SECRET_KEY` - Session/JWT secret (generate with `openssl rand -hex 32`)
- `VITE_API_URL` - Backend API URL (frontend)

---

## Local Development

### Option 1: Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild after code changes
docker-compose up -d --build
```

**Access points:**
- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Database: localhost:5432

### Option 2: Local Development (Without Docker)

**Backend:**
```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
alembic upgrade head

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Frontend:**
```bash
cd frontend

# Install dependencies
npm install

# Start dev server
npm run dev
```

**Database (PostgreSQL):**
```bash
# Install PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Create database
sudo -u postgres psql
CREATE DATABASE windnewsdb;
CREATE USER winduser WITH PASSWORD 'windpass';
GRANT ALL PRIVILEGES ON DATABASE windnewsdb TO winduser;
\q
```

### Running Tests

**Backend:**
```bash
cd backend

# Install test dependencies
pip install pytest pytest-asyncio pytest-cov

# Run tests
pytest tests/ -v

# With coverage
pytest tests/ -v --cov=app --cov-report=html
```

**Frontend:**
```bash
cd frontend

# Run linter
npm run lint

# Run tests (when implemented)
npm test
```

---

## Deployment to Development (OVH)

**Target:** dev.windnews.rabciak.site
**Branch:** `develop`
**Trigger:** Push to develop or manual deployment

### Automated Deployment (CI/CD)

When you push to the `develop` branch, GitHub Actions automatically:
1. ✅ Runs linting (Python: flake8, black; TypeScript: ESLint)
2. ✅ Runs tests (pytest for backend)
3. ✅ Builds Docker images
4. 🚀 Deploys to dev server (when configured)

### Manual Deployment

**Using deployment script:**
```bash
# SSH into development server
ssh deploy@dev.windnews.rabciak.site

# Navigate to project directory
cd /opt/windnewsmapper-dev

# Run deployment script
./scripts/deploy-dev.sh
```

**What the script does:**
1. Pulls latest code from `develop`
2. Checks environment configuration
3. Stops running containers
4. Builds new Docker images
5. Starts new containers
6. Runs database migrations
7. Performs health check

### First-Time Server Setup

**1. Install Docker and Docker Compose:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
```

**2. Clone repository:**
```bash
sudo mkdir -p /opt/windnewsmapper-dev
sudo chown $USER:$USER /opt/windnewsmapper-dev
cd /opt/windnewsmapper-dev
git clone https://github.com/rabciak/WindResarcherAI.git .
git checkout develop
```

**3. Configure environment:**
```bash
cp .env.development.example .env
vim .env  # Update DATABASE_URL, SECRET_KEY, etc.
```

**4. Configure Traefik (reverse proxy with SSL):**

Create `docker-compose.traefik.yml`:
```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencrypt.acme.email=your-email@example.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./letsencrypt:/letsencrypt"
    networks:
      - windnews_network

networks:
  windnews_network:
    external: true
```

**5. Update docker-compose.yml with Traefik labels:**
```yaml
services:
  backend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend-dev.rule=Host(`api-dev.windnews.rabciak.site`)"
      - "traefik.http.routers.backend-dev.entrypoints=websecure"
      - "traefik.http.routers.backend-dev.tls.certresolver=letsencrypt"
      - "traefik.http.services.backend-dev.loadbalancer.server.port=8000"

  frontend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend-dev.rule=Host(`dev.windnews.rabciak.site`)"
      - "traefik.http.routers.frontend-dev.entrypoints=websecure"
      - "traefik.http.routers.frontend-dev.tls.certresolver=letsencrypt"
      - "traefik.http.services.frontend-dev.loadbalancer.server.port=5173"
```

**6. Start services:**
```bash
docker network create windnews_network
docker-compose -f docker-compose.traefik.yml up -d
docker-compose up -d
```

---

## Deployment to Production (OVH)

**Target:** windnews.rabciak.site
**Branch:** `main`
**Trigger:** Manual deployment only (no auto-deploy to production)

### Pre-Deployment Checklist

- [ ] All tests passing on `main` branch
- [ ] Code reviewed and approved
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Backup created
- [ ] Rollback plan ready
- [ ] Stakeholders notified

### Deployment Process

**1. Merge develop into main:**
```bash
git checkout main
git pull origin main
git merge develop
git push origin main
```

**2. SSH into production server:**
```bash
ssh deploy@windnews.rabciak.site
cd /opt/windnewsmapper
```

**3. Run production deployment script:**
```bash
./scripts/deploy-prod.sh
```

**What the script does:**
1. ⚠️ Asks for confirmation (safety check)
2. 💾 Creates database backup
3. 📥 Pulls latest code from `main`
4. 🔍 Validates environment configuration
5. 🏗️ Builds new Docker images
6. 🛑 Stops running containers (gracefully)
7. 🚀 Starts new containers
8. 🔄 Runs database migrations
9. ✅ Performs health checks
10. 🔙 Offers rollback if health check fails

### Production Monitoring

**Check application health:**
```bash
# Health check
curl https://windnews.rabciak.site/health
curl https://api.windnews.rabciak.site/health

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Check container status
docker-compose -f docker-compose.prod.yml ps
```

**Monitor resource usage:**
```bash
# Docker stats
docker stats

# System resources
htop
df -h  # disk usage
free -h  # memory usage
```

---

## Rollback Procedures

### Automatic Rollback (via deployment script)

If the production deployment script detects a failed health check, it will offer to rollback automatically.

### Manual Rollback

**1. Identify the commit to rollback to:**
```bash
git log --oneline -10
```

**2. Rollback to previous commit:**
```bash
cd /opt/windnewsmapper
git reset --hard <previous-commit-hash>
docker-compose -f docker-compose.prod.yml up -d --build
```

**3. Restore database backup (if needed):**
```bash
# List available backups
ls -lh /opt/backups/windnewsmapper/

# Restore backup
docker-compose -f docker-compose.prod.yml exec -T db psql -U winduser_prod windnewsdb_prod < /opt/backups/windnewsmapper/backup_YYYYMMDD_HHMMSS.sql
```

**4. Verify application is working:**
```bash
curl https://windnews.rabciak.site/health
docker-compose -f docker-compose.prod.yml logs -f
```

### Emergency Hotfix

For critical production bugs:

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug-fix

# Make fix and test locally

# Commit and push
git commit -m "hotfix: fix critical security vulnerability"
git push origin hotfix/critical-bug-fix

# Create PR to main (expedited review)
# After merge, deploy to production immediately
```

---

## CI/CD Pipeline

### GitHub Actions Workflows

**1. `ci-develop.yml` - Development Pipeline**

Triggers on:
- Push to `develop`
- Pull requests to `develop`

Steps:
1. Backend linting (flake8, black, isort)
2. Frontend linting (ESLint)
3. Backend tests (pytest with PostgreSQL)
4. Frontend build (Vite)
5. Docker image builds
6. Deploy to development (on push only)

**2. `ci-main.yml` - Production Pipeline**

Triggers on:
- Push to `main`
- Pull requests to `main`

Steps:
1. Backend linting (strict)
2. Frontend linting (strict)
3. Backend tests (requires tests to exist)
4. Frontend build (production mode)
5. Docker image builds (production)
6. Create release tag (on push only)
7. Deploy to production (manual approval)

### Required GitHub Secrets

Configure these in GitHub Settings → Secrets and variables → Actions:

**Development:**
- `DEV_SERVER_HOST` - Development server hostname
- `DEV_SERVER_USER` - SSH username
- `DEV_SERVER_SSH_KEY` - SSH private key

**Production:**
- `PROD_SERVER_HOST` - Production server hostname
- `PROD_SERVER_USER` - SSH username
- `PROD_SERVER_SSH_KEY` - SSH private key

**Optional:**
- `CODECOV_TOKEN` - For code coverage reports
- `SLACK_WEBHOOK` - For deployment notifications

---

## Troubleshooting

### Deployment Fails

**Problem:** Deployment script exits with error

**Solutions:**
1. Check deployment logs
2. Verify environment variables are set
3. Ensure database is accessible
4. Check Docker daemon is running
5. Verify sufficient disk space

### Database Migration Fails

**Problem:** `alembic upgrade head` fails

**Solutions:**
```bash
# Check current migration status
docker-compose exec backend alembic current

# View migration history
docker-compose exec backend alembic history

# Manually run specific migration
docker-compose exec backend alembic upgrade <revision>

# Rollback migration
docker-compose exec backend alembic downgrade -1
```

### SSL Certificate Issues

**Problem:** Let's Encrypt certificate not renewing

**Solutions:**
```bash
# Check Traefik logs
docker logs traefik

# Verify domain DNS points to server
nslookup windnews.rabciak.site

# Check acme.json file
sudo cat /opt/windnewsmapper/letsencrypt/acme.json

# Force certificate renewal
docker-compose restart traefik
```

### Container Won't Start

**Problem:** Docker container exits immediately

**Solutions:**
```bash
# View container logs
docker-compose logs backend
docker-compose logs frontend

# Check container status
docker-compose ps

# Inspect container
docker inspect windnewsmapper_backend

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Out of Disk Space

**Problem:** Server running out of disk space

**Solutions:**
```bash
# Check disk usage
df -h

# Clean Docker images and containers
docker system prune -a

# Clean old backups
find /opt/backups/windnewsmapper -mtime +30 -delete

# Clean logs
docker-compose logs --tail=1000 > /dev/null
```

---

## Support and Contact

For deployment issues:
- **GitHub Issues:** https://github.com/rabciak/WindResarcherAI/issues
- **Documentation:** [README.md](README.md), [claude.md](claude.md)
- **Email:** your-email@example.com

---

**Last Updated:** 2025-10-02
**Document Version:** 1.0.0
