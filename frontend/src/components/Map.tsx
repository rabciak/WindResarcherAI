import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import axios from 'axios';

// Fix Leaflet default marker icons
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

L.Marker.prototype.options.icon = DefaultIcon;

// Custom icons for different marker types
const windFarmIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

const newsIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

interface WindFarm {
  id: number;
  name: string;
  location: string;
  latitude: number;
  longitude: number;
  capacity_mw?: number;
  status?: string;
  operator?: string;
  description?: string;
}

interface NewsArticle {
  id: number;
  title: string;
  url: string;
  source?: string;
  published_date?: string;
  latitude?: number;
  longitude?: number;
  location?: string;
}

interface MapData {
  wind_farms: WindFarm[];
  news_locations: NewsArticle[];
}

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

function Map() {
  const [mapData, setMapData] = useState<MapData>({ wind_farms: [], news_locations: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchMapData();
  }, []);

  const fetchMapData = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/map-data`);
      setMapData(response.data);
      setError(null);
    } catch (err) {
      console.error('Error fetching map data:', err);
      setError('Failed to load map data');
    } finally {
      setLoading(false);
    }
  };

  // Center on Poland
  const center: [number, number] = [52.0, 19.0];
  const zoom = 6;

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        fontSize: '18px'
      }}>
        Loading map data...
      </div>
    );
  }

  if (error) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        fontSize: '18px',
        color: '#d32f2f'
      }}>
        <div>{error}</div>
        <button
          onClick={fetchMapData}
          style={{
            marginTop: '20px',
            padding: '10px 20px',
            fontSize: '16px',
            cursor: 'pointer'
          }}
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <MapContainer
      center={center}
      zoom={zoom}
      style={{ height: '100vh', width: '100%' }}
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />

      {/* Wind Farm Markers */}
      {mapData.wind_farms.map((farm) => (
        <Marker
          key={`farm-${farm.id}`}
          position={[farm.latitude, farm.longitude]}
          icon={windFarmIcon}
        >
          <Popup>
            <div style={{ minWidth: '200px' }}>
              <h3 style={{ margin: '0 0 10px 0' }}>{farm.name}</h3>
              <p><strong>Location:</strong> {farm.location}</p>
              {farm.capacity_mw && (
                <p><strong>Capacity:</strong> {farm.capacity_mw} MW</p>
              )}
              {farm.status && (
                <p><strong>Status:</strong> {farm.status}</p>
              )}
              {farm.operator && (
                <p><strong>Operator:</strong> {farm.operator}</p>
              )}
              {farm.description && (
                <p style={{ fontSize: '0.9em', marginTop: '10px' }}>{farm.description}</p>
              )}
            </div>
          </Popup>
        </Marker>
      ))}

      {/* News Location Markers */}
      {mapData.news_locations.map((article) => (
        article.latitude && article.longitude && (
          <Marker
            key={`news-${article.id}`}
            position={[article.latitude, article.longitude]}
            icon={newsIcon}
          >
            <Popup>
              <div style={{ minWidth: '200px' }}>
                <h3 style={{ margin: '0 0 10px 0', fontSize: '16px' }}>{article.title}</h3>
                {article.source && (
                  <p><strong>Source:</strong> {article.source}</p>
                )}
                {article.published_date && (
                  <p><strong>Published:</strong> {new Date(article.published_date).toLocaleDateString()}</p>
                )}
                <a
                  href={article.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{ color: '#1976d2', textDecoration: 'none' }}
                >
                  Read article →
                </a>
              </div>
            </Popup>
          </Marker>
        )
      ))}
    </MapContainer>
  );
}

export default Map;
