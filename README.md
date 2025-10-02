# WindNewsMapper

A full-stack web application for mapping and tracking wind farm news in Poland. The application combines web scraping, geospatial mapping, and real-time data visualization to provide insights into Poland's renewable energy sector.

## Features

- 🗺️ **Interactive Map**: Leaflet-based map showing wind farm locations and news articles
- 📰 **News Scraping**: Automated scraping of Polish renewable energy news sources
- 📊 **Statistics Dashboard**: Real-time statistics on wind farms and news coverage
- 🐳 **Docker Support**: Easy deployment with Docker Compose
- 🔄 **REST API**: FastAPI backend with comprehensive endpoints

## Tech Stack

### Backend
- **Python 3.11** with FastAPI
- **PostgreSQL** for data persistence
- **SQLAlchemy** ORM
- **BeautifulSoup4** for web scraping
- **Uvicorn** ASGI server

### Frontend
- **React 18** with TypeScript
- **Vite** build tool
- **Leaflet** for interactive maps
- **Axios** for API communication

## Project Structure

```
WindNewsMapper/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py              # FastAPI application
│   │   ├── models.py            # Database models
│   │   ├── scraper.py           # Web scraping logic
│   │   └── api/
│   │       ├── __init__.py
│   │       └── routes.py        # API endpoints
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   └── Map.tsx          # Leaflet map component
│   │   ├── App.tsx
│   │   ├── App.css
│   │   ├── main.tsx
│   │   └── index.css
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── Dockerfile
├── docker-compose.yml
├── .gitignore
└── README.md
```

## Setup Instructions

### Prerequisites
- Python 3.11+
- Node.js 18+
- Docker and Docker Compose (optional, for containerized setup)

### Option 1: Docker Setup (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/rabciak/WindResarcherAI.git
   cd WindResarcherAI
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

### Option 2: Local Development Setup

#### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

5. **Run the backend server**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

#### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env if needed
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

#### Database Setup (PostgreSQL)

If not using Docker, you'll need to set up PostgreSQL manually:

```bash
# Install PostgreSQL (Ubuntu/Debian)
sudo apt-get install postgresql postgresql-contrib

# Create database
sudo -u postgres psql
CREATE DATABASE windnewsdb;
CREATE USER winduser WITH PASSWORD 'windpass';
GRANT ALL PRIVILEGES ON DATABASE windnewsdb TO winduser;
\q
```

## API Endpoints

### News Endpoints
- `GET /api/news` - Get all news articles
- `GET /api/news/{id}` - Get specific news article
- `POST /api/news/scrape` - Trigger news scraping

### Wind Farm Endpoints
- `GET /api/wind-farms` - Get all wind farms
- `GET /api/wind-farms/{id}` - Get specific wind farm
- `POST /api/wind-farms` - Create new wind farm entry

### Utility Endpoints
- `GET /api/map-data` - Get combined data for map visualization
- `GET /api/stats` - Get statistics
- `GET /health` - Health check

## Usage

1. **Access the application** at http://localhost:5173
2. **Click "Scrape Latest News"** to fetch recent articles from Polish renewable energy news sources
3. **Explore the map** to see wind farm locations (green markers) and news locations (blue markers)
4. **Click on markers** to view detailed information

## News Sources

The application scrapes news from:
- gramwzielone.pl
- wysokienapiecie.pl
- wnp.pl

## Development

### Adding New Scrapers

Edit `backend/app/scraper.py` and add a new scraping method:

```python
def scrape_new_source(self) -> List[Dict]:
    # Implement scraping logic
    pass
```

Then add it to `scrape_all()` method.

### Database Migrations

```bash
cd backend
alembic revision --autogenerate -m "Description"
alembic upgrade head
```

## Environment Variables

### Backend (.env)
```
DATABASE_URL=postgresql://winduser:windpass@localhost:5432/windnewsdb
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
DEBUG=True
LOG_LEVEL=INFO
```

### Frontend (.env)
```
VITE_API_URL=http://localhost:8000
```

## Troubleshooting

### Port Already in Use
```bash
# Check what's using the port
lsof -i :5173  # or :8000
# Kill the process or change the port in configuration
```

### Database Connection Issues
- Ensure PostgreSQL is running
- Check DATABASE_URL in backend/.env
- Verify database credentials

### Frontend Not Loading Map
- Check browser console for errors
- Verify VITE_API_URL is set correctly
- Ensure backend is running and accessible

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a Pull Request.

### Quick Start for Contributors

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/WindResarcherAI.git
   cd WindResarcherAI
   ```
3. **Create a feature branch**:
   ```bash
   git checkout develop
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** following our [Code Style Guidelines](CONTRIBUTING.md#code-style-guidelines)
5. **Commit using Conventional Commits**:
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push and create a Pull Request**:
   ```bash
   git push origin feature/your-feature-name
   ```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Branch Strategy

We use **Git Flow** for our branching strategy:

- **`main`** - Production-ready code (deploys to windnews.rabciak.site)
- **`develop`** - Development branch (deploys to dev.windnews.rabciak.site)
- **`feature/*`** - New features (branch from `develop`)
- **`bugfix/*`** - Bug fixes (branch from `develop`)
- **`hotfix/*`** - Urgent production fixes (branch from `main`)

### Creating a Feature

```bash
# Start from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/add-news-filtering

# Work on your feature, commit changes
git add .
git commit -m "feat: add news filtering by category"

# Push and create PR to develop
git push origin feature/add-news-filtering
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed workflow and deployment instructions.

## Development Workflow

### Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

**Examples:**
```bash
git commit -m "feat(backend): add pagination to news endpoint"
git commit -m "fix(frontend): resolve map marker positioning bug"
git commit -m "docs: update API documentation"
```

### CI/CD Pipeline

Every push and pull request triggers automated checks:

- ✅ **Linting** - Python (flake8, black) and TypeScript (ESLint)
- ✅ **Tests** - Backend tests with pytest
- ✅ **Build** - Docker images for backend and frontend
- 🚀 **Deploy** - Automatic deployment to development/production

### Code Quality

Before submitting a PR:

**Backend:**
```bash
cd backend

# Format code
black app/
isort app/

# Lint
flake8 app/ --max-line-length=120

# Run tests
pytest tests/ -v
```

**Frontend:**
```bash
cd frontend

# Lint
npm run lint

# Build
npm run build
```

## Deployment

### Development Environment
- **URL**: https://dev.windnews.rabciak.site
- **Deploys**: Automatically on push to `develop` branch
- **Purpose**: Testing and staging

### Production Environment
- **URL**: https://windnews.rabciak.site
- **API**: https://api.windnews.rabciak.site
- **Deploys**: Manually from `main` branch
- **Purpose**: Live production environment

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

### Quick Deploy

**Development:**
```bash
./scripts/deploy-dev.sh
```

**Production:**
```bash
./scripts/deploy-prod.sh
```

## Documentation

- **[README.md](README.md)** - This file, project overview and setup
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contributing guidelines and code style
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment and workflow documentation
- **[claude.md](claude.md)** - Comprehensive project context for AI assistance

## License

This project is licensed under the MIT License.

## Contact

- **GitHub**: https://github.com/rabciak/WindResarcherAI
- **Issues**: https://github.com/rabciak/WindResarcherAI/issues

---

## Acknowledgments

- **OpenStreetMap** - Map tiles and geocoding
- **Leaflet** - Interactive mapping library
- **FastAPI** - Modern Python web framework
- **React** - Frontend UI library

---

**Note**: This application is designed for educational and research purposes. Please respect the robots.txt and terms of service of the websites being scraped.
