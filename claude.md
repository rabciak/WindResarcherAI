# WindNewsMapper - Project Documentation

## 1. PROJECT OVERVIEW

### Project Name
**WindNewsMapper** (formerly WindResarcherAI)

### Purpose
A full-stack web application for mapping and tracking wind farm news in Poland. The application combines web scraping, geospatial mapping, and real-time data visualization to provide insights into Poland's renewable energy sector.

### Main Technologies
- **Backend**: Python 3.11, FastAPI, PostgreSQL, SQLAlchemy
- **Frontend**: React 18, TypeScript, Vite, Leaflet
- **Deployment**: Docker, Docker Compose
- **Web Scraping**: BeautifulSoup4, Requests, lxml

### Current Development Status
- ✅ Core functionality implemented
- ✅ Web scraping for 3 Polish news sources
- ✅ Interactive map with Leaflet
- ✅ REST API with comprehensive endpoints
- ✅ Docker containerization
- ⏳ Production deployment to OVH with Traefik (planned)
- ⏳ Advanced geolocation extraction (in progress)
- ⏳ News content analysis and categorization (planned)

---

## 2. ARCHITECTURE

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Browser                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (React + Vite)                   │
│  ┌──────────────┬─────────────────┬────────────────────┐   │
│  │   App.tsx    │  Map Component  │  Stats Dashboard   │   │
│  │  (Main UI)   │   (Leaflet)     │   (Statistics)     │   │
│  └──────────────┴─────────────────┴────────────────────┘   │
│                         │                                    │
│                    Axios HTTP Client                         │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              Backend (FastAPI + Uvicorn)                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                API Routes (routes.py)                 │  │
│  │  • /api/news              • /api/wind-farms          │  │
│  │  • /api/news/scrape       • /api/map-data            │  │
│  │  • /api/stats             • /health                   │  │
│  └────────────┬─────────────────────┬────────────────────┘  │
│               │                     │                        │
│  ┌────────────▼─────────┐  ┌────────▼──────────────────┐   │
│  │  Scraper Module      │  │   Database Models         │   │
│  │  (scraper.py)        │  │   (SQLAlchemy ORM)        │   │
│  │  • gramwzielone.pl   │  │   • WindFarm              │   │
│  │  • wysokienapiecie.pl│  │   • NewsArticle           │   │
│  │  • wnp.pl            │  │                            │   │
│  └──────────────────────┘  └─────────────┬──────────────┘   │
└──────────────────────────────────────────┼──────────────────┘
                                            │ SQL
                                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Database                       │
│  ┌──────────────────────┬──────────────────────────────┐   │
│  │  wind_farms table    │  news_articles table         │   │
│  │  • id, name          │  • id, title, url            │   │
│  │  • lat/lon           │  • source, published_date    │   │
│  │  • capacity, status  │  • lat/lon, location         │   │
│  └──────────────────────┴──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Backend Structure

```
backend/
├── app/
│   ├── __init__.py          # Package initializer
│   ├── main.py              # FastAPI app initialization, CORS, lifespan
│   ├── models.py            # SQLAlchemy models (WindFarm, NewsArticle)
│   ├── scraper.py           # Web scraping logic (WindFarmNewsScraper)
│   └── api/
│       ├── __init__.py
│       └── routes.py        # API endpoint definitions
├── requirements.txt         # Python dependencies
├── Dockerfile              # Backend container definition
└── .env                    # Environment variables (gitignored)
```

**Key Components:**
- `main.py`: Application entry point, configures CORS, creates database tables on startup
- `models.py`: Defines `WindFarm` and `NewsArticle` database models with SQLAlchemy
- `routes.py`: RESTful API endpoints for news, wind farms, statistics, and map data
- `scraper.py`: Web scraping class with methods for each news source

### Frontend Structure

```
frontend/
├── src/
│   ├── components/
│   │   └── Map.tsx          # Leaflet map component with markers
│   ├── App.tsx              # Main application component
│   ├── App.css              # Application styles
│   ├── main.tsx             # React app entry point
│   └── index.css            # Global styles
├── package.json             # npm dependencies and scripts
├── tsconfig.json            # TypeScript configuration
├── vite.config.ts           # Vite build configuration
├── Dockerfile              # Multi-stage frontend container
└── .env                    # Environment variables (gitignored)
```

**Key Components:**
- `Map.tsx`: Interactive Leaflet map with custom markers for wind farms (green) and news (blue)
- `App.tsx`: Main UI with stats dashboard, scrape button, and map container
- Uses TypeScript for type safety
- Axios for API communication

### Database Schema

**Table: `wind_farms`**
```sql
id              INTEGER PRIMARY KEY
name            VARCHAR(255) NOT NULL
location        VARCHAR(255) NOT NULL
latitude        FLOAT NOT NULL
longitude       FLOAT NOT NULL
capacity_mw     FLOAT
status          VARCHAR(100)        -- planned, under_construction, operational
operator        VARCHAR(255)
description     TEXT
created_at      TIMESTAMP DEFAULT NOW()
updated_at      TIMESTAMP DEFAULT NOW()
```

**Table: `news_articles`**
```sql
id              INTEGER PRIMARY KEY
title           VARCHAR(500) NOT NULL
url             VARCHAR(1000) NOT NULL UNIQUE
source          VARCHAR(255)
published_date  TIMESTAMP
content         TEXT
summary         TEXT
wind_farm_name  VARCHAR(255)
location        VARCHAR(255)
latitude        FLOAT
longitude       FLOAT
category        VARCHAR(100)        -- news, investment, regulatory, technical
scraped_at      TIMESTAMP DEFAULT NOW()
created_at      TIMESTAMP DEFAULT NOW()
```

### API Endpoints

**News Endpoints:**
- `GET /api/news?limit=50&skip=0&category=news` - Get news articles with pagination/filtering
- `GET /api/news/{article_id}` - Get specific article by ID
- `POST /api/news/scrape` - Trigger web scraping, save new articles

**Wind Farm Endpoints:**
- `GET /api/wind-farms?limit=100&skip=0&status=operational` - Get wind farms with filtering
- `GET /api/wind-farms/{farm_id}` - Get specific wind farm by ID
- `POST /api/wind-farms` - Create new wind farm entry

**Utility Endpoints:**
- `GET /api/map-data` - Get combined data for map (wind farms + geolocated news)
- `GET /api/stats` - Get statistics (total farms, capacity, news count, etc.)
- `GET /health` - Health check endpoint
- `GET /` - Root endpoint with API info

---

## 3. TECH STACK

### Backend

| Technology | Version | Purpose |
|-----------|---------|---------|
| Python | 3.11 | Programming language |
| FastAPI | 0.109.0 | Modern async web framework |
| Uvicorn | 0.27.0 | ASGI server with hot reload |
| SQLAlchemy | 2.0.25 | ORM for database interactions |
| Pydantic | 2.5.3 | Data validation and settings |
| PostgreSQL | 15 | Relational database |
| psycopg2-binary | 2.9.9 | PostgreSQL adapter |
| BeautifulSoup4 | 4.12.3 | HTML/XML parsing for scraping |
| Requests | 2.31.0 | HTTP library for web requests |
| lxml | 5.1.0 | XML/HTML parser (fast) |
| Alembic | 1.13.1 | Database migrations |
| python-dotenv | 1.0.0 | Environment variable management |
| python-multipart | 0.0.6 | Multipart form data support |

### Frontend

| Technology | Version | Purpose |
|-----------|---------|---------|
| React | 18.2.0 | UI library |
| TypeScript | 5.3.3 | Type-safe JavaScript |
| Vite | 5.0.11 | Fast build tool and dev server |
| Leaflet | 1.9.4 | Interactive mapping library |
| react-leaflet | 4.2.1 | React bindings for Leaflet |
| Axios | 1.6.5 | HTTP client for API calls |
| ESLint | 8.56.0 | Code linting |
| @vitejs/plugin-react | 4.2.1 | React plugin for Vite |

### Database
- **PostgreSQL 15-alpine** - Lightweight, production-ready PostgreSQL

### Deployment
- **Docker** - Container platform
- **Docker Compose** - Multi-container orchestration
- **Nginx** (production) - Static file serving for frontend
- **Traefik** (planned) - Reverse proxy with SSL for OVH deployment

---

## 4. PROJECT STRUCTURE

```
WindNewsMapper/
├── backend/                     # Python FastAPI backend
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py             # FastAPI app, CORS, startup/shutdown
│   │   ├── models.py           # SQLAlchemy ORM models
│   │   ├── scraper.py          # Web scraping logic
│   │   └── api/
│   │       ├── __init__.py
│   │       └── routes.py       # API endpoint definitions
│   ├── venv/                   # Python virtual environment (gitignored)
│   ├── requirements.txt        # Python package dependencies
│   ├── Dockerfile              # Backend Docker container definition
│   └── .env                    # Environment variables (gitignored)
│
├── frontend/                    # React TypeScript frontend
│   ├── src/
│   │   ├── components/
│   │   │   └── Map.tsx         # Leaflet map with markers and popups
│   │   ├── App.tsx             # Main app component with stats
│   │   ├── App.css             # Application-specific styles
│   │   ├── main.tsx            # React entry point
│   │   └── index.css           # Global styles
│   ├── node_modules/           # npm dependencies (gitignored)
│   ├── dist/                   # Build output (gitignored)
│   ├── package.json            # npm dependencies and scripts
│   ├── tsconfig.json           # TypeScript compiler options
│   ├── vite.config.ts          # Vite configuration
│   ├── Dockerfile              # Multi-stage frontend container
│   └── .env                    # Environment variables (gitignored)
│
├── docker-compose.yml           # Multi-container setup (db, backend, frontend)
├── .gitignore                   # Git ignore rules
├── README.md                    # Project documentation
└── claude.md                    # This file - Claude AI context
```

### Directory Purposes

- **`backend/app/`** - Core application logic, models, API routes, scraping
- **`backend/venv/`** - Isolated Python environment (never commit)
- **`frontend/src/`** - React components, TypeScript source code
- **`frontend/dist/`** - Production build output (generated, not committed)
- **`frontend/node_modules/`** - npm dependencies (never commit)

### Key Files

- **`backend/app/main.py`** - FastAPI application factory, CORS setup, database initialization
- **`backend/app/models.py`** - Database schema definitions (WindFarm, NewsArticle)
- **`backend/app/scraper.py`** - Web scraping implementation for Polish news sites
- **`backend/app/api/routes.py`** - All API endpoints and business logic
- **`frontend/src/App.tsx`** - Root component with stats dashboard and map container
- **`frontend/src/components/Map.tsx`** - Leaflet map integration with markers
- **`docker-compose.yml`** - Orchestrates PostgreSQL, backend, and frontend containers

---

## 5. DEVELOPMENT WORKFLOW

### Initial Setup

**1. Clone the Repository**
```bash
git clone https://github.com/rabciak/WindResarcherAI.git
cd WindResarcherAI
```

**2. Docker Setup (Recommended)**
```bash
# Start all services (database, backend, frontend)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild after code changes
docker-compose up -d --build
```

**3. Local Development Setup (Alternative)**

Backend:
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env      # Configure DATABASE_URL
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Frontend:
```bash
cd frontend
npm install
cp .env.example .env      # Configure VITE_API_URL
npm run dev
```

### Local Development Commands

**Backend:**
```bash
# Start dev server with hot reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Run migrations
alembic revision --autogenerate -m "Description"
alembic upgrade head

# Install new dependency
pip install package-name
pip freeze > requirements.txt
```

**Frontend:**
```bash
# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint

# Install new dependency
npm install package-name
```

**Docker:**
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Restart a service
docker-compose restart backend

# Rebuild containers
docker-compose up -d --build

# Access database
docker exec -it windnewsmapper_db psql -U winduser -d windnewsdb

# Stop and remove containers
docker-compose down
```

### Testing Approach

**Current Status:** No automated tests implemented yet

**Planned Testing Strategy:**
- **Backend**: pytest, pytest-asyncio for FastAPI endpoints
- **Frontend**: Vitest, React Testing Library
- **E2E**: Playwright or Cypress
- **API Testing**: Manual testing via Swagger UI at http://localhost:8000/docs

### Development Workflow

1. **Feature Development**
   - Create feature branch: `git checkout -b feature/feature-name`
   - Make changes in backend or frontend
   - Test locally with `docker-compose up` or separate dev servers
   - Commit changes: `git commit -m "Add feature description"`

2. **Database Changes**
   - Modify models in `backend/app/models.py`
   - Generate migration: `alembic revision --autogenerate -m "Add new field"`
   - Apply migration: `alembic upgrade head`
   - Update API routes and frontend as needed

3. **Adding New Scraper**
   - Add source URL to `scraper.py` `sources` dict
   - Implement `scrape_source_name()` method
   - Add to `scrape_all()` method
   - Test with `POST /api/news/scrape`

---

## 6. API DOCUMENTATION

### News Endpoints

**GET /api/news**
```
Description: Retrieve news articles with pagination and filtering
Query Parameters:
  - limit (int, default=50): Number of articles to return
  - skip (int, default=0): Number of articles to skip (pagination)
  - category (str, optional): Filter by category (news, investment, regulatory, technical)

Response: List of news article objects
Example:
  GET /api/news?limit=10&category=news
```

**GET /api/news/{article_id}**
```
Description: Get a specific news article by ID
Path Parameters:
  - article_id (int): Article ID

Response: Single news article object
Status Codes:
  - 200: Success
  - 404: Article not found
```

**POST /api/news/scrape**
```
Description: Trigger web scraping for all sources, save new articles to database
Request Body: None

Response:
{
  "message": "News scraping completed",
  "total_scraped": 30,
  "new_articles_saved": 15
}
```

### Wind Farm Endpoints

**GET /api/wind-farms**
```
Description: Get all wind farms with optional filtering
Query Parameters:
  - limit (int, default=100): Number of records to return
  - skip (int, default=0): Pagination offset
  - status (str, optional): Filter by status (planned, under_construction, operational)

Response: List of wind farm objects
```

**GET /api/wind-farms/{farm_id}**
```
Description: Get specific wind farm by ID
Path Parameters:
  - farm_id (int): Wind farm ID

Response: Single wind farm object
Status Codes:
  - 200: Success
  - 404: Wind farm not found
```

**POST /api/wind-farms**
```
Description: Create a new wind farm entry
Request Body:
{
  "name": "Farm Name",
  "location": "Location Name",
  "latitude": 52.5,
  "longitude": 19.2,
  "capacity_mw": 50.0,
  "status": "planned",
  "operator": "Company Name",
  "description": "Description text"
}

Response: Created wind farm object with ID
```

### Utility Endpoints

**GET /api/map-data**
```
Description: Get combined data for map visualization (all wind farms + news with coordinates)
Response:
{
  "wind_farms": [...],
  "news_locations": [...]
}
```

**GET /api/stats**
```
Description: Get general statistics about the system
Response:
{
  "total_wind_farms": 10,
  "operational_farms": 5,
  "planned_farms": 3,
  "total_capacity_mw": 450.5,
  "total_news_articles": 120
}
```

**GET /health**
```
Description: Health check endpoint
Response: {"status": "healthy"}
```

**GET /**
```
Description: Root endpoint with API information
Response:
{
  "message": "WindNewsMapper API",
  "version": "1.0.0",
  "status": "running"
}
```

### Authentication
Currently: **No authentication** implemented
Planned: API key authentication for scraping endpoints

---

## 7. CODING CONVENTIONS

### Python Style Guide (Backend)

**Follow PEP 8:**
- Indentation: 4 spaces
- Line length: Max 100 characters (preferred), hard limit 120
- Imports: Group stdlib, third-party, local (separated by blank lines)
- Naming:
  - `snake_case` for functions, variables, methods
  - `PascalCase` for classes
  - `UPPER_CASE` for constants

**Example:**
```python
from fastapi import APIRouter, Depends
from typing import List, Optional

from app.models import NewsArticle, get_db

router = APIRouter()

@router.get("/news", response_model=List[dict])
async def get_news(
    limit: int = 50,
    skip: int = 0,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all news articles with optional filtering"""
    # Implementation
```

**Type Hints:**
- Always use type hints for function parameters and return types
- Use `Optional[Type]` for nullable values
- Use `List[Type]`, `Dict[str, Type]` from `typing`

**Docstrings:**
- Use triple quotes for all docstrings
- Brief one-liner for simple functions
- Multi-line for complex functions (description, args, returns)

### TypeScript/React Conventions (Frontend)

**Naming:**
- `PascalCase` for components, interfaces, types
- `camelCase` for variables, functions, props
- File names match component names: `Map.tsx` for `Map` component

**Component Structure:**
```typescript
// Imports
import { useState, useEffect } from 'react';
import axios from 'axios';

// Interfaces/Types
interface Props {
  title: string;
  count?: number;
}

// Component
function ComponentName({ title, count = 0 }: Props) {
  // State
  const [data, setData] = useState<Type | null>(null);

  // Effects
  useEffect(() => {
    // Effect logic
  }, []);

  // Handlers
  const handleClick = () => {
    // Handler logic
  };

  // Render
  return (
    <div>
      {/* JSX */}
    </div>
  );
}

export default ComponentName;
```

**TypeScript Strict Mode:**
- `strict: true` in tsconfig.json
- No implicit `any` types
- Enable all strict flags

### File Naming Patterns

**Backend:**
- Python files: `lowercase_with_underscores.py`
- Models: `models.py`
- Routes: `routes.py`
- Utility modules: `scraper.py`, `utils.py`

**Frontend:**
- Components: `PascalCase.tsx` (e.g., `Map.tsx`, `App.tsx`)
- Utilities: `camelCase.ts` (e.g., `apiClient.ts`)
- Styles: Match component name (e.g., `App.css`)

### Import Organization

**Python:**
```python
# Standard library
import os
from datetime import datetime
from typing import List, Optional

# Third-party
from fastapi import FastAPI, Depends
from sqlalchemy import Column, Integer, String

# Local
from app.models import WindFarm
from app.utils import parse_date
```

**TypeScript:**
```typescript
// React/External libraries
import { useState, useEffect } from 'react';
import axios from 'axios';

// Components
import Map from './components/Map';

// Styles
import './App.css';
```

---

## 8. DEPENDENCIES

### Python Packages

| Package | Version | Purpose |
|---------|---------|---------|
| **fastapi** | 0.109.0 | Modern async web framework with automatic API docs |
| **uvicorn[standard]** | 0.27.0 | ASGI server with WebSocket support and hot reload |
| **sqlalchemy** | 2.0.25 | SQL ORM with async support |
| **pydantic** | 2.5.3 | Data validation using Python type hints |
| **pydantic-settings** | 2.1.0 | Settings management from env vars |
| **python-dotenv** | 1.0.0 | Load environment variables from .env files |
| **psycopg2-binary** | 2.9.9 | PostgreSQL database adapter (binary distribution) |
| **beautifulsoup4** | 4.12.3 | HTML/XML parsing for web scraping |
| **requests** | 2.31.0 | Simple HTTP library for making requests |
| **lxml** | 5.1.0 | Fast XML/HTML parser (C-based) |
| **alembic** | 1.13.1 | Database migration tool for SQLAlchemy |
| **python-multipart** | 0.0.6 | Form data parsing for file uploads |

**Why these choices:**
- **FastAPI**: Chosen for automatic OpenAPI docs, async support, and excellent performance
- **SQLAlchemy 2.0**: Modern ORM with type hints and async capabilities
- **BeautifulSoup4 + lxml**: Robust and flexible HTML parsing (lxml for speed)
- **Pydantic**: Built-in with FastAPI, excellent for data validation
- **Alembic**: Standard migration tool, integrates seamlessly with SQLAlchemy

### npm Packages

**Dependencies:**
| Package | Version | Purpose |
|---------|---------|---------|
| **react** | 18.2.0 | UI library with hooks and modern features |
| **react-dom** | 18.2.0 | React rendering for web |
| **leaflet** | 1.9.4 | Open-source mapping library |
| **react-leaflet** | 4.2.1 | React components for Leaflet |
| **axios** | 1.6.5 | Promise-based HTTP client |

**DevDependencies:**
| Package | Version | Purpose |
|---------|---------|---------|
| **@types/react** | 18.2.48 | TypeScript definitions for React |
| **@types/react-dom** | 18.2.18 | TypeScript definitions for ReactDOM |
| **@types/leaflet** | 1.9.8 | TypeScript definitions for Leaflet |
| **@typescript-eslint/eslint-plugin** | 6.19.0 | ESLint TypeScript rules |
| **@typescript-eslint/parser** | 6.19.0 | TypeScript parser for ESLint |
| **@vitejs/plugin-react** | 4.2.1 | React plugin for Vite (Fast Refresh) |
| **eslint** | 8.56.0 | Code linting and style enforcement |
| **eslint-plugin-react-hooks** | 4.6.0 | Enforce React Hooks rules |
| **eslint-plugin-react-refresh** | 0.4.5 | Validate Fast Refresh constraints |
| **typescript** | 5.3.3 | TypeScript compiler |
| **vite** | 5.0.11 | Next-gen frontend build tool |

**Why these choices:**
- **Vite**: Extremely fast dev server, better than webpack for modern projects
- **Leaflet**: Lightweight, open-source, no API keys required (vs Google Maps)
- **react-leaflet**: Official React bindings, declarative API
- **Axios**: Better API than fetch, interceptors, automatic JSON parsing
- **TypeScript**: Type safety, better IDE support, catches errors early

---

## 9. DEPLOYMENT

### Docker Setup

**Architecture:**
```
docker-compose.yml orchestrates 3 services:
├── db (PostgreSQL)
├── backend (FastAPI)
└── frontend (React + Vite dev server)
```

**Starting the Stack:**
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Rebuild after code changes
docker-compose up -d --build

# Stop services
docker-compose down

# Stop and remove volumes (WARNING: deletes database)
docker-compose down -v
```

**Accessing Services:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Database: localhost:5432 (username: `winduser`, password: `windpass`)

### Environment Variables

**Backend (.env):**
```bash
# Database connection
DATABASE_URL=postgresql://winduser:windpass@db:5432/windnewsdb

# CORS allowed origins (comma-separated)
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Application settings
DEBUG=True
LOG_LEVEL=INFO
```

**Frontend (.env):**
```bash
# Backend API URL
VITE_API_URL=http://localhost:8000
```

**Docker Compose Environment:**
Environment variables are defined directly in `docker-compose.yml` for simplicity.

### Deployment to OVH with Traefik

**Planned Setup:**

1. **Server Configuration:**
   - VPS on OVH with Docker and Docker Compose
   - Domain pointing to server IP
   - SSL certificates via Let's Encrypt (automated by Traefik)

2. **Traefik Configuration:**
```yaml
# traefik.yml
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: your-email@example.com
      storage: acme.json
      httpChallenge:
        entryPoint: web
```

3. **Updated docker-compose.yml for Production:**
```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - "--providers.docker=true"
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

  backend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.windnews.example.com`)"
      - "traefik.http.routers.backend.entrypoints=websecure"
      - "traefik.http.routers.backend.tls.certresolver=letsencrypt"
    # ... rest of backend config

  frontend:
    build:
      context: ./frontend
      target: production  # Use nginx stage
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`windnews.example.com`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"
    # ... rest of frontend config
```

4. **Subdomain Configuration:**
   - Frontend: `windnews.example.com`
   - Backend API: `api.windnews.example.com`
   - Database: Not exposed publicly (internal Docker network only)

5. **Deployment Steps:**
```bash
# On OVH server
git clone https://github.com/rabciak/WindResarcherAI.git
cd WindResarcherAI

# Set up environment variables
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
# Edit .env files with production values

# Start with Traefik
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Run database migrations
docker-compose -f docker-compose.prod.yml exec backend alembic upgrade head
```

**Security Considerations:**
- Use strong passwords for PostgreSQL in production
- Never commit `.env` files
- Set `DEBUG=False` in production
- Restrict CORS origins to production domains only
- Use environment secrets management (e.g., Docker secrets, Vault)

---

## 10. FUTURE ROADMAP

### Planned Features

**High Priority:**
1. **Advanced Geolocation Extraction**
   - Implement NLP-based location extraction from news content
   - Geocoding API integration (OpenStreetMap Nominatim)
   - Automatic coordinate assignment for news articles

2. **News Content Analysis**
   - Full article content scraping (not just titles)
   - Automatic categorization (investment, regulatory, technical, general)
   - Keyword extraction and tagging
   - Wind farm name detection and linking

3. **User Authentication**
   - API key authentication for scraping endpoints
   - User accounts for saving favorite locations/articles
   - Admin panel for manual data entry/editing

4. **Scheduled Scraping**
   - Background task scheduler (Celery + Redis)
   - Automatic daily/weekly scraping
   - Email notifications for new articles

**Medium Priority:**
5. **Enhanced Map Features**
   - Clustering for dense marker areas
   - Heat maps for wind farm density
   - Filter controls (by status, capacity, date range)
   - Search functionality

6. **Analytics Dashboard**
   - Trends over time (new projects, capacity growth)
   - Regional analysis (by voivodeship)
   - Source comparison (which sites report most)
   - Charts and visualizations (Chart.js/Recharts)

7. **Data Export**
   - CSV/Excel export for wind farms and news
   - JSON API for third-party integrations
   - RSS feed for latest news

**Low Priority:**
8. **Additional Data Sources**
   - Government databases (URE - Energy Regulatory Office)
   - Investment announcements
   - Environmental impact reports
   - Social media monitoring (Twitter/X)

9. **Mobile App**
   - React Native app
   - Push notifications for nearby projects
   - Offline map support

### Technical Debt to Address

1. **Testing**
   - Add pytest unit tests for backend (routes, scraper, models)
   - Add Vitest tests for frontend components
   - Integration tests for API endpoints
   - E2E tests with Playwright

2. **Error Handling**
   - Improve scraper error recovery (retry logic)
   - Better API error responses (RFC 7807 Problem Details)
   - Frontend error boundaries
   - Logging and monitoring (Sentry integration)

3. **Performance**
   - Database indexing optimization
   - API response caching (Redis)
   - Frontend lazy loading and code splitting
   - Image optimization for map markers

4. **Code Quality**
   - Add pre-commit hooks (black, isort, flake8)
   - Implement CI/CD pipeline (GitHub Actions)
   - Add API versioning (/api/v1/)
   - Improve documentation (Swagger descriptions)

5. **Security**
   - Input validation and sanitization
   - Rate limiting for API endpoints
   - SQL injection prevention (already using ORM, but audit)
   - XSS protection

### Optimization Opportunities

1. **Database**
   - Add indexes on frequently queried fields (latitude, longitude, published_date)
   - Implement full-text search (PostgreSQL FTS)
   - Partition news_articles table by date

2. **Scraping**
   - Implement async scraping with `aiohttp`
   - Add browser automation for JavaScript-heavy sites (Playwright)
   - Respect robots.txt and implement rate limiting

3. **Frontend**
   - Implement virtual scrolling for large lists
   - Use service workers for offline support
   - Optimize bundle size (tree shaking, lazy loading)
   - Add Progressive Web App (PWA) capabilities

4. **Infrastructure**
   - Set up CDN for static assets (Cloudflare)
   - Database read replicas for scaling
   - Horizontal scaling with load balancer
   - Monitoring and alerting (Prometheus + Grafana)

---

## 11. TROUBLESHOOTING

### Common Issues and Solutions

#### Port Already in Use

**Problem:** `Error: bind: address already in use`

**Solution:**
```bash
# Find process using port 8000 (backend)
lsof -i :8000
# or
netstat -tulpn | grep 8000

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml or uvicorn command
```

#### Database Connection Issues

**Problem:** `sqlalchemy.exc.OperationalError: could not connect to server`

**Solutions:**
1. **Check if PostgreSQL is running:**
   ```bash
   # For Docker
   docker-compose ps
   docker-compose logs db

   # For local PostgreSQL
   sudo systemctl status postgresql
   ```

2. **Verify DATABASE_URL in backend/.env:**
   ```bash
   # For Docker (use service name 'db')
   DATABASE_URL=postgresql://winduser:windpass@db:5432/windnewsdb

   # For local development
   DATABASE_URL=postgresql://winduser:windpass@localhost:5432/windnewsdb
   ```

3. **Check database credentials:**
   ```bash
   # Access database shell
   docker exec -it windnewsmapper_db psql -U winduser -d windnewsdb

   # List databases
   \l

   # List tables
   \dt
   ```

4. **Recreate database:**
   ```bash
   docker-compose down -v  # WARNING: Deletes all data
   docker-compose up -d
   ```

#### Frontend Not Loading Map

**Problem:** Map shows blank or markers don't appear

**Solutions:**
1. **Check browser console for errors**
   - Open DevTools (F12)
   - Look for CORS errors, 404s, or JavaScript errors

2. **Verify VITE_API_URL is set correctly:**
   ```bash
   # frontend/.env
   VITE_API_URL=http://localhost:8000
   ```

3. **Check if backend is running and accessible:**
   ```bash
   curl http://localhost:8000/health
   # Should return: {"status":"healthy"}

   curl http://localhost:8000/api/map-data
   # Should return JSON with wind_farms and news_locations
   ```

4. **Clear browser cache and reload:**
   - Hard reload: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

5. **Check Leaflet CSS is loaded:**
   - Ensure `import 'leaflet/dist/leaflet.css'` is in Map.tsx
   - Check Network tab in DevTools for CSS 404 errors

#### Scraping Fails or Returns No Results

**Problem:** `POST /api/news/scrape` returns `new_articles_saved: 0`

**Solutions:**
1. **Check scraper logs:**
   ```bash
   docker-compose logs backend
   # Look for "Error scraping..." messages
   ```

2. **Test scraper manually:**
   ```python
   # In backend container or local environment
   from app.scraper import WindFarmNewsScraper
   scraper = WindFarmNewsScraper()
   articles = scraper.scrape_gramwzielone()
   print(articles)
   ```

3. **Common causes:**
   - Website changed HTML structure (update CSS selectors)
   - Rate limiting or bot detection (add delays, rotate User-Agent)
   - Network issues (check internet connection)
   - Website is down (try accessing URL in browser)

4. **Update selectors:**
   - Inspect target website with browser DevTools
   - Update CSS selectors in `scraper.py`
   - Test individual scraper methods

#### Docker Build Failures

**Problem:** `docker-compose up` fails during build

**Solutions:**
1. **Clean rebuild:**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up
   ```

2. **Check Dockerfile syntax:**
   - Ensure all COPY paths are correct
   - Verify requirements.txt/package.json exist

3. **Disk space issues:**
   ```bash
   # Check disk space
   df -h

   # Clean Docker images/containers
   docker system prune -a
   ```

4. **Network issues during build:**
   - Check internet connection
   - Try using different DNS (8.8.8.8)

### Debug Tips

**Backend Debugging:**
```python
# Add to routes.py for detailed logging
import logging
logger = logging.getLogger(__name__)

@router.get("/test")
async def test_endpoint():
    logger.info("Test endpoint called")
    logger.debug(f"Database connection: {db}")
    return {"status": "ok"}
```

**Frontend Debugging:**
```typescript
// Add to components for debugging
console.log('Map data:', mapData);
console.error('Error fetching data:', error);

// React DevTools browser extension for component inspection
```

**Database Debugging:**
```bash
# Access database shell
docker exec -it windnewsmapper_db psql -U winduser -d windnewsdb

# Check table contents
SELECT * FROM news_articles LIMIT 5;
SELECT COUNT(*) FROM wind_farms;

# Check for duplicate URLs (should be unique)
SELECT url, COUNT(*) FROM news_articles GROUP BY url HAVING COUNT(*) > 1;
```

**Network Debugging:**
```bash
# Check if services can communicate
docker-compose exec backend ping db
docker-compose exec frontend ping backend

# Check port bindings
docker-compose ps
netstat -tulpn | grep -E '5173|8000|5432'
```

### Known Limitations

1. **Web Scraping Fragility**
   - Scrapers break when websites change HTML structure
   - No automated alerts for scraper failures
   - Limited error recovery

2. **Geolocation Accuracy**
   - Currently manual or basic regex-based location extraction
   - No automatic geocoding (coordinates must be entered manually for wind farms)

3. **Performance**
   - No pagination for map markers (may be slow with 1000+ markers)
   - No caching layer (every request hits database)
   - Scraping is synchronous (blocks API during scrape)

4. **Security**
   - No authentication (anyone can trigger scraping)
   - No rate limiting
   - Database credentials in plain text .env files

5. **Scalability**
   - Single database instance (no replication)
   - No horizontal scaling support
   - No load balancing

---

## QUICK REFERENCE

### Essential Commands

```bash
# Start everything
docker-compose up -d

# View logs
docker-compose logs -f

# Restart service
docker-compose restart backend

# Access database
docker exec -it windnewsmapper_db psql -U winduser -d windnewsdb

# Run migrations
docker-compose exec backend alembic upgrade head

# Stop everything
docker-compose down
```

### Important URLs

- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Redoc: http://localhost:8000/redoc

### Key File Locations

- Backend code: `backend/app/`
- Frontend code: `frontend/src/`
- API routes: `backend/app/api/routes.py`
- Database models: `backend/app/models.py`
- Web scraper: `backend/app/scraper.py`
- Main map: `frontend/src/components/Map.tsx`

---

**Last Updated:** 2025-10-02
**Claude Context:** This file provides comprehensive context for AI-assisted development with Claude Code.
