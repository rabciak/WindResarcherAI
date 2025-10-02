import { useState, useEffect } from 'react';
import Map from './components/Map';
import axios from 'axios';
import './App.css';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

interface Stats {
  total_wind_farms: number;
  operational_farms: number;
  planned_farms: number;
  total_capacity_mw: number;
  total_news_articles: number;
}

function App() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [scraping, setScraping] = useState(false);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/stats`);
      setStats(response.data);
    } catch (err) {
      console.error('Error fetching statistics:', err);
    }
  };

  const handleScrapeNews = async () => {
    setScraping(true);
    try {
      const response = await axios.post(`${API_URL}/api/news/scrape`);
      alert(`Scraping completed! ${response.data.new_articles_saved} new articles saved.`);
      fetchStats();
      window.location.reload(); // Refresh map data
    } catch (err) {
      console.error('Error scraping news:', err);
      alert('Failed to scrape news. Please try again.');
    } finally {
      setScraping(false);
    }
  };

  return (
    <div className="app">
      <header className="header">
        <div className="header-content">
          <h1>WindNewsMapper</h1>
          <p>Wind Farm News & Mapping Platform for Poland</p>
        </div>

        <div className="controls">
          <button
            onClick={handleScrapeNews}
            disabled={scraping}
            className="scrape-button"
          >
            {scraping ? 'Scraping...' : 'Scrape Latest News'}
          </button>
        </div>

        {stats && (
          <div className="stats">
            <div className="stat-item">
              <span className="stat-value">{stats.total_wind_farms}</span>
              <span className="stat-label">Wind Farms</span>
            </div>
            <div className="stat-item">
              <span className="stat-value">{stats.operational_farms}</span>
              <span className="stat-label">Operational</span>
            </div>
            <div className="stat-item">
              <span className="stat-value">{stats.total_capacity_mw.toFixed(0)}</span>
              <span className="stat-label">Total MW</span>
            </div>
            <div className="stat-item">
              <span className="stat-value">{stats.total_news_articles}</span>
              <span className="stat-label">News Articles</span>
            </div>
          </div>
        )}
      </header>

      <main className="map-container">
        <Map />
      </main>
    </div>
  );
}

export default App;
