import requests
from bs4 import BeautifulSoup
from typing import List, Dict, Optional
from datetime import datetime
import re
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class WindFarmNewsScraper:
    """Web scraper for Polish wind farm and renewable energy news"""

    def __init__(self):
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }

        # Polish renewable energy news sources
        self.sources = {
            'gramwzielone': 'https://www.gramwzielone.pl/energia-wiatrowa',
            'wysokienapiecie': 'https://wysokienapiecie.pl/category/energia-wiatrowa/',
            'wnp': 'https://www.wnp.pl/oze/',
        }

    def scrape_gramwzielone(self) -> List[Dict]:
        """Scrape news from gramwzielone.pl"""
        articles = []
        try:
            url = self.sources['gramwzielone']
            response = requests.get(url, headers=self.headers, timeout=10)
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'lxml')

            # Find article elements (adjust selectors based on actual website structure)
            article_elements = soup.find_all('article', class_='post', limit=10)

            for article in article_elements:
                try:
                    title_elem = article.find('h2') or article.find('h3')
                    link_elem = article.find('a')

                    if title_elem and link_elem:
                        title = title_elem.get_text(strip=True)
                        url = link_elem.get('href')

                        # Extract date if available
                        date_elem = article.find('time')
                        published_date = None
                        if date_elem:
                            date_str = date_elem.get('datetime') or date_elem.get_text(strip=True)
                            published_date = self._parse_date(date_str)

                        articles.append({
                            'title': title,
                            'url': url,
                            'source': 'gramwzielone.pl',
                            'published_date': published_date,
                            'category': 'news'
                        })
                except Exception as e:
                    logger.error(f"Error parsing article from gramwzielone: {e}")
                    continue

        except Exception as e:
            logger.error(f"Error scraping gramwzielone: {e}")

        return articles

    def scrape_wysokienapiecie(self) -> List[Dict]:
        """Scrape news from wysokienapiecie.pl"""
        articles = []
        try:
            url = self.sources['wysokienapiecie']
            response = requests.get(url, headers=self.headers, timeout=10)
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'lxml')

            # Find article elements
            article_elements = soup.find_all('article', limit=10)

            for article in article_elements:
                try:
                    title_elem = article.find('h2', class_='entry-title') or article.find('h2')
                    link_elem = title_elem.find('a') if title_elem else None

                    if link_elem:
                        title = link_elem.get_text(strip=True)
                        url = link_elem.get('href')

                        # Extract date
                        date_elem = article.find('time')
                        published_date = None
                        if date_elem:
                            date_str = date_elem.get('datetime') or date_elem.get_text(strip=True)
                            published_date = self._parse_date(date_str)

                        articles.append({
                            'title': title,
                            'url': url,
                            'source': 'wysokienapiecie.pl',
                            'published_date': published_date,
                            'category': 'news'
                        })
                except Exception as e:
                    logger.error(f"Error parsing article from wysokienapiecie: {e}")
                    continue

        except Exception as e:
            logger.error(f"Error scraping wysokienapiecie: {e}")

        return articles

    def scrape_wnp(self) -> List[Dict]:
        """Scrape news from wnp.pl"""
        articles = []
        try:
            url = self.sources['wnp']
            response = requests.get(url, headers=self.headers, timeout=10)
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'lxml')

            # Find article elements
            article_elements = soup.find_all('div', class_='news-item', limit=10)

            for article in article_elements:
                try:
                    link_elem = article.find('a')

                    if link_elem:
                        title = link_elem.get_text(strip=True)
                        url = link_elem.get('href')

                        if not url.startswith('http'):
                            url = f"https://www.wnp.pl{url}"

                        articles.append({
                            'title': title,
                            'url': url,
                            'source': 'wnp.pl',
                            'published_date': None,
                            'category': 'news'
                        })
                except Exception as e:
                    logger.error(f"Error parsing article from wnp: {e}")
                    continue

        except Exception as e:
            logger.error(f"Error scraping wnp: {e}")

        return articles

    def scrape_all(self) -> List[Dict]:
        """Scrape news from all sources"""
        all_articles = []

        logger.info("Starting to scrape all sources...")

        all_articles.extend(self.scrape_gramwzielone())
        all_articles.extend(self.scrape_wysokienapiecie())
        all_articles.extend(self.scrape_wnp())

        logger.info(f"Scraped {len(all_articles)} articles in total")

        return all_articles

    def _parse_date(self, date_str: str) -> Optional[datetime]:
        """Parse date string to datetime object"""
        if not date_str:
            return None

        try:
            # Try ISO format first
            return datetime.fromisoformat(date_str.replace('Z', '+00:00'))
        except:
            pass

        try:
            # Try common date formats
            for fmt in ['%Y-%m-%d', '%d-%m-%Y', '%d.%m.%Y']:
                try:
                    return datetime.strptime(date_str, fmt)
                except:
                    continue
        except:
            pass

        return None

    def extract_location(self, text: str) -> Optional[str]:
        """Extract location from text (simple regex-based approach)"""
        # Common Polish voivodeships
        voivodeships = [
            'pomorskie', 'zachodniopomorskie', 'wielkopolskie', 'kujawsko-pomorskie',
            'warmińsko-mazurskie', 'podlaskie', 'mazowieckie', 'łódzkie', 'lubelskie',
            'podkarpackie', 'małopolskie', 'śląskie', 'opolskie', 'dolnośląskie',
            'lubuskie', 'świętokrzyskie'
        ]

        text_lower = text.lower()
        for voivodeship in voivodeships:
            if voivodeship in text_lower:
                return voivodeship.capitalize()

        return None


# Example usage function
def scrape_wind_news():
    """Main function to scrape wind farm news"""
    scraper = WindFarmNewsScraper()
    articles = scraper.scrape_all()
    return articles
