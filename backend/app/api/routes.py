from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from app.models import get_db, WindFarm, NewsArticle
from app.scraper import WindFarmNewsScraper

router = APIRouter()


# News Article Endpoints
@router.get("/news", response_model=List[dict])
async def get_news(
    limit: int = 50,
    skip: int = 0,
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all news articles with optional filtering"""
    query = db.query(NewsArticle)

    if category:
        query = query.filter(NewsArticle.category == category)

    articles = query.order_by(NewsArticle.published_date.desc()).offset(skip).limit(limit).all()
    return [article.to_dict() for article in articles]


@router.get("/news/{article_id}", response_model=dict)
async def get_news_by_id(article_id: int, db: Session = Depends(get_db)):
    """Get a specific news article by ID"""
    article = db.query(NewsArticle).filter(NewsArticle.id == article_id).first()

    if not article:
        raise HTTPException(status_code=404, detail="Article not found")

    return article.to_dict()


@router.post("/news/scrape")
async def scrape_news(background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    """Trigger news scraping and save to database"""
    scraper = WindFarmNewsScraper()
    articles = scraper.scrape_all()

    saved_count = 0
    for article_data in articles:
        # Check if article already exists
        existing = db.query(NewsArticle).filter(NewsArticle.url == article_data['url']).first()

        if not existing:
            article = NewsArticle(
                title=article_data['title'],
                url=article_data['url'],
                source=article_data['source'],
                published_date=article_data.get('published_date'),
                category=article_data.get('category', 'news'),
                scraped_at=datetime.utcnow()
            )
            db.add(article)
            saved_count += 1

    db.commit()

    return {
        "message": "News scraping completed",
        "total_scraped": len(articles),
        "new_articles_saved": saved_count
    }


# Wind Farm Endpoints
@router.get("/wind-farms", response_model=List[dict])
async def get_wind_farms(
    limit: int = 100,
    skip: int = 0,
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all wind farms with optional filtering"""
    query = db.query(WindFarm)

    if status:
        query = query.filter(WindFarm.status == status)

    wind_farms = query.order_by(WindFarm.name).offset(skip).limit(limit).all()
    return [farm.to_dict() for farm in wind_farms]


@router.get("/wind-farms/{farm_id}", response_model=dict)
async def get_wind_farm_by_id(farm_id: int, db: Session = Depends(get_db)):
    """Get a specific wind farm by ID"""
    farm = db.query(WindFarm).filter(WindFarm.id == farm_id).first()

    if not farm:
        raise HTTPException(status_code=404, detail="Wind farm not found")

    return farm.to_dict()


@router.post("/wind-farms", response_model=dict)
async def create_wind_farm(farm_data: dict, db: Session = Depends(get_db)):
    """Create a new wind farm entry"""
    wind_farm = WindFarm(
        name=farm_data['name'],
        location=farm_data['location'],
        latitude=farm_data['latitude'],
        longitude=farm_data['longitude'],
        capacity_mw=farm_data.get('capacity_mw'),
        status=farm_data.get('status', 'planned'),
        operator=farm_data.get('operator'),
        description=farm_data.get('description')
    )

    db.add(wind_farm)
    db.commit()
    db.refresh(wind_farm)

    return wind_farm.to_dict()


@router.get("/map-data")
async def get_map_data(db: Session = Depends(get_db)):
    """Get combined data for map visualization"""
    # Get wind farms
    wind_farms = db.query(WindFarm).all()

    # Get news articles with location data
    news_with_location = db.query(NewsArticle).filter(
        NewsArticle.latitude.isnot(None),
        NewsArticle.longitude.isnot(None)
    ).order_by(NewsArticle.published_date.desc()).limit(50).all()

    return {
        "wind_farms": [farm.to_dict() for farm in wind_farms],
        "news_locations": [article.to_dict() for article in news_with_location]
    }


@router.get("/stats")
async def get_statistics(db: Session = Depends(get_db)):
    """Get general statistics"""
    total_farms = db.query(WindFarm).count()
    total_news = db.query(NewsArticle).count()

    operational_farms = db.query(WindFarm).filter(WindFarm.status == 'operational').count()
    planned_farms = db.query(WindFarm).filter(WindFarm.status == 'planned').count()

    total_capacity = db.query(WindFarm).filter(WindFarm.capacity_mw.isnot(None)).with_entities(
        db.func.sum(WindFarm.capacity_mw)
    ).scalar() or 0

    return {
        "total_wind_farms": total_farms,
        "operational_farms": operational_farms,
        "planned_farms": planned_farms,
        "total_capacity_mw": float(total_capacity),
        "total_news_articles": total_news
    }
