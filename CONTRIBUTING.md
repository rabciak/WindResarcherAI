# Contributing to WindNewsMapper

Thank you for considering contributing to WindNewsMapper! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

---

## Code of Conduct

### Our Pledge

We are committed to providing a friendly, safe, and welcoming environment for all contributors, regardless of experience level, gender identity, sexual orientation, disability, personal appearance, race, ethnicity, age, religion, or nationality.

### Expected Behavior

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, trolling, or discriminatory comments
- Publishing others' private information
- Personal or political attacks
- Other conduct which could reasonably be considered inappropriate

---

## Getting Started

### Prerequisites

- **Git** - Version control
- **Python 3.11+** - Backend development
- **Node.js 18+** - Frontend development
- **Docker & Docker Compose** - Containerization (optional but recommended)
- **PostgreSQL 15** - Database (or use Docker)

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/WindResarcherAI.git
   cd WindResarcherAI
   ```
3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/rabciak/WindResarcherAI.git
   ```

### Setup Development Environment

```bash
# Start services with Docker
docker-compose up -d

# Or set up locally (see README.md for detailed instructions)
```

---

## Development Workflow

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
# Update your local develop branch
git checkout develop
git pull upstream develop

# Create a new feature branch
git checkout -b feature/your-feature-name
```

**Branch naming conventions:**
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test additions/updates

### 2. Make Your Changes

- Write clean, readable code
- Follow the style guides (see below)
- Add tests for new functionality
- Update documentation as needed

### 3. Test Your Changes

```bash
# Backend tests
cd backend
pytest tests/ -v

# Frontend linting
cd frontend
npm run lint

# Manual testing
docker-compose up -d
# Test in browser: http://localhost:5173
```

### 4. Commit Your Changes

Follow the [Conventional Commits](#commit-message-convention) specification:

```bash
git add .
git commit -m "feat: add news filtering by date range"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub from your branch to `develop`.

---

## Code Style Guidelines

### Python (Backend)

We follow **PEP 8** with some modifications:

**Key Rules:**
- **Indentation:** 4 spaces (no tabs)
- **Line length:** 120 characters (preferred: 100)
- **Naming:**
  - `snake_case` for functions, variables, methods
  - `PascalCase` for classes
  - `UPPER_CASE` for constants
- **Imports:** Group stdlib, third-party, local (separated by blank lines)
- **Type hints:** Always use type hints for function parameters and returns
- **Docstrings:** Use triple quotes for all docstrings

**Tools:**
```bash
# Format code with Black
black app/

# Sort imports with isort
isort app/

# Lint with flake8
flake8 app/ --max-line-length=120
```

**Example:**
```python
from typing import List, Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.models import NewsArticle, get_db

router = APIRouter()


@router.get("/news", response_model=List[dict])
async def get_news(
    limit: int = 50,
    skip: int = 0,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
) -> List[dict]:
    """
    Get all news articles with optional filtering.

    Args:
        limit: Maximum number of articles to return
        skip: Number of articles to skip (pagination)
        category: Filter by category (optional)
        db: Database session

    Returns:
        List of news article dictionaries
    """
    query = db.query(NewsArticle)
    if category:
        query = query.filter(NewsArticle.category == category)

    articles = query.order_by(NewsArticle.published_date.desc()).offset(skip).limit(limit).all()
    return [article.to_dict() for article in articles]
```

### TypeScript/React (Frontend)

We follow **ESLint** configuration with React best practices:

**Key Rules:**
- **Indentation:** 2 spaces
- **Naming:**
  - `PascalCase` for components, interfaces, types
  - `camelCase` for variables, functions, props
- **File names:** Match component names (`Map.tsx`)
- **Imports:** React first, then libraries, then local
- **TypeScript:** Strict mode enabled, no `any` types

**Tools:**
```bash
# Lint code
npm run lint

# Auto-fix linting issues
npm run lint -- --fix
```

**Example:**
```typescript
import { useState, useEffect } from 'react';
import axios from 'axios';

interface NewsArticle {
  id: number;
  title: string;
  url: string;
  source?: string;
}

interface NewsListProps {
  category?: string;
  limit?: number;
}

function NewsList({ category, limit = 50 }: NewsListProps) {
  const [articles, setArticles] = useState<NewsArticle[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchArticles = async () => {
      try {
        const response = await axios.get('/api/news', {
          params: { category, limit }
        });
        setArticles(response.data);
      } catch (error) {
        console.error('Error fetching articles:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchArticles();
  }, [category, limit]);

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      {articles.map((article) => (
        <div key={article.id}>
          <h3>{article.title}</h3>
          <a href={article.url}>Read more</a>
        </div>
      ))}
    </div>
  );
}

export default NewsList;
```

### General Guidelines

- **Comments:** Write self-documenting code; use comments for complex logic only
- **DRY Principle:** Don't Repeat Yourself
- **SOLID Principles:** Follow object-oriented design principles
- **Error Handling:** Always handle errors gracefully
- **Security:** Never commit secrets, API keys, or passwords

---

## Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/) for clear, structured commit history.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting (no functional changes)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks (dependencies, build config)
- `perf:` - Performance improvements
- `ci:` - CI/CD configuration changes

### Scope (Optional)

Indicates the part of the codebase affected:
- `backend` - Backend changes
- `frontend` - Frontend changes
- `api` - API changes
- `scraper` - Web scraping changes
- `db` - Database changes
- `docker` - Docker configuration
- `docs` - Documentation

### Examples

```bash
feat(backend): add pagination to news endpoint
fix(frontend): resolve map marker positioning bug
docs: update deployment instructions
refactor(scraper): optimize HTML parsing logic
test(api): add tests for wind farm endpoints
chore(deps): update FastAPI to 0.110.0
perf(backend): add database indexes for faster queries
ci: add automated deployment to staging
```

### Body and Footer (Optional)

For complex changes, add a body explaining the motivation and implementation:

```
feat(backend): add news filtering by multiple categories

Previously, users could only filter by a single category. This change
allows filtering by multiple categories using comma-separated values.

Closes #123
```

---

## Pull Request Process

### Before Submitting

- [ ] Branch is up to date with `develop`
- [ ] All tests pass locally
- [ ] Code follows style guidelines
- [ ] No linting errors
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow Conventional Commits

### Submitting a PR

1. **Push your branch** to your fork
2. **Open a Pull Request** on GitHub
3. **Fill out the PR template** completely
4. **Link related issues** (e.g., "Closes #123")
5. **Request reviewers**
6. **Add appropriate labels** (bug, enhancement, documentation)

### PR Title

Follow Conventional Commits format:

```
feat: add news filtering by category
fix: resolve map marker positioning bug
docs: update API documentation
```

### What Happens Next

1. **Automated checks run** (CI/CD)
   - Linting (Python, TypeScript)
   - Tests (pytest)
   - Build (Docker images)

2. **Code review** by maintainers
   - Code quality
   - Security
   - Performance
   - Tests

3. **Feedback and iterations**
   - Address review comments
   - Push updates to your branch
   - CI/CD runs again automatically

4. **Approval and merge**
   - Maintainer approves PR
   - PR is merged into `develop`
   - Your branch is deleted

### Tips for Faster Review

- **Keep PRs small** - Easier to review, faster to merge
- **One feature per PR** - Don't mix unrelated changes
- **Write good descriptions** - Explain what, why, and how
- **Add screenshots** - For UI changes
- **Be responsive** - Address feedback quickly

---

## Testing Requirements

### Backend Tests

All new backend features must include tests:

```python
# backend/tests/test_api.py
import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_get_news():
    """Test GET /api/news endpoint"""
    response = client.get("/api/news")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_news_with_filter():
    """Test news filtering by category"""
    response = client.get("/api/news?category=investment")
    assert response.status_code == 200
    articles = response.json()
    for article in articles:
        assert article["category"] == "investment"
```

**Run tests:**
```bash
cd backend
pytest tests/ -v --cov=app
```

### Frontend Tests (Future)

Frontend tests will be added using Vitest and React Testing Library:

```typescript
import { render, screen } from '@testing-library/react';
import NewsList from './NewsList';

describe('NewsList', () => {
  it('renders loading state initially', () => {
    render(<NewsList />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('displays articles after loading', async () => {
    render(<NewsList />);
    const article = await screen.findByText('Sample Article Title');
    expect(article).toBeInTheDocument();
  });
});
```

### Manual Testing

Before submitting PR:
1. Test with Docker Compose
2. Test all affected functionality
3. Test in multiple browsers (Chrome, Firefox, Safari)
4. Test responsive design (mobile, tablet, desktop)
5. Check browser console for errors

---

## Documentation

### When to Update Documentation

Update documentation when you:
- Add new features
- Change API endpoints
- Modify environment variables
- Update deployment process
- Change configuration

### What to Update

- **README.md** - User-facing documentation
- **DEPLOYMENT.md** - Deployment instructions
- **claude.md** - AI context and architecture
- **Code comments** - Docstrings and inline comments
- **API docs** - Swagger/OpenAPI (auto-generated from FastAPI)

### Documentation Style

- **Be concise** - Get to the point quickly
- **Use examples** - Show, don't just tell
- **Keep it updated** - Outdated docs are worse than no docs
- **Use proper formatting** - Markdown, code blocks, links

---

## Questions or Need Help?

- **GitHub Issues:** https://github.com/rabciak/WindResarcherAI/issues
- **GitHub Discussions:** Ask questions, share ideas
- **Discord/Slack:** (if available)

---

## Recognition

Contributors will be recognized in:
- GitHub Contributors page
- Release notes
- README.md (for significant contributions)

---

Thank you for contributing to WindNewsMapper! 🚀

---

**Last Updated:** 2025-10-02
**Document Version:** 1.0.0
