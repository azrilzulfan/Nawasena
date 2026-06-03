// src/pages/OverviewPage.jsx
import { useEffect, useState } from 'react';
import { Users, Building2, Boxes, TrendingUp, ExternalLink, Phone } from 'lucide-react';
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend,
} from 'recharts';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import StatCard from '../components/ui/StatCard';
import ErrorState from '../components/ui/ErrorState';
import { api } from '../lib/api';
import L from 'leaflet';

import markerIconPng from 'leaflet/dist/images/marker-icon.png';
import markerShadowPng from 'leaflet/dist/images/marker-shadow.png';

import 'leaflet/dist/leaflet.css';

const CATEGORY_COLORS = { Logistik: '#10b981', Edukasi: '#3b82f6', Medis: '#f59e0b' };

export default function OverviewPage() {
  const [foundations, setFoundations] = useState([]);
  const [donations,   setDonations]   = useState([]);
  const [inventories, setInventories] = useState([]);
  const [volunteers,   setVolunteers]  = useState([]);
  const [loading, setLoading]         = useState(true);
  const [error,   setError]           = useState(null);

  useEffect(() => {
    async function loadAll() {
      setLoading(true);
      setError(null);
      try {
        const [fRes, dRes, iRes, vRes] = await Promise.all([
          api.get('/foundations?is_verified=1'),
          api.get('/donations'),
          api.get('/inventories'),
          api.get('/users?role=volunteer'),
        ]);
        setFoundations(fRes.data ?? []);
        setDonations(dRes.data ?? []);
        setInventories(iRes.data ?? []);
        setVolunteers(vRes.data ?? []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }
    loadAll();
  }, []);

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="h-24 bg-white rounded-2xl border border-muted animate-pulse" />
          ))}
        </div>
        <div className="h-72 bg-white rounded-2xl border border-muted animate-pulse" />
      </div>
    );
  }

  if (error) return <ErrorState message={error} />;

  const urgentItems = inventories.filter(i => i.urgent_level === 'high').length;

  const trendMap = {};
  donations.forEach(d => {
    const month = new Date(d.created_at).toLocaleString('id-ID', { month: 'short' });
    trendMap[month] = (trendMap[month] ?? 0) + 1;
  });
  const trendData = Object.entries(trendMap).map(([month, total]) => ({ month, total }));

  const categoryMap = {};
  inventories.forEach(i => {
    categoryMap[i.category] = (categoryMap[i.category] ?? 0) + 1;
  });
  const categoryData = Object.entries(categoryMap).map(([name, value]) => ({
    name, value, fill: CATEGORY_COLORS[name] ?? '#94a3b8',
  }));

  const DefaultIcon = L.icon({
    iconUrl: markerIconPng,
    shadowUrl: markerShadowPng,
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
  });
  L.Marker.prototype.options.icon = DefaultIcon;

  function ChangeMapView({ center }) {
    const map = useMap();
    useEffect(() => {
      if (center && center[0] && center[1]) {
        map.setView(center, map.getZoom());
      }
    }, [center, map]);
    return null;
  }

  const validFoundations = foundations.filter(
    f => f.location?.coordinates?.[1] !== undefined && f.location?.coordinates?.[0] !== undefined
  );

  const defaultCenter = [-6.2088, 106.8456];
  const mapCenter = validFoundations.length > 0
    ? [validFoundations[0].location.coordinates[1], validFoundations[0].location.coordinates[0]]
    : defaultCenter;

  return (
    <div className="space-y-6 font-sans">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={TrendingUp} label="Total Donasi"   value={donations.length}   sub="Semua waktu" color="emerald" />
        <StatCard icon={Building2}  label="Panti Aktif"    value={foundations.length} sub="Terverifikasi" color="blue" />
        <StatCard icon={Users}      label="Total Relawan"  value={volunteers.length}  sub="Terdaftar" color="amber" />
        <StatCard icon={Boxes}      label="Item Mendesak"  value={urgentItems}        sub="Butuh donasi segera" color="rose" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 bg-white rounded-2xl border border-muted p-5 shadow-sm">
          <p className="text-sm font-semibold text-accent mb-4">Tren Donasi Global</p>
          {trendData.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <AreaChart data={trendData}>
                <defs>
                  <linearGradient id="grad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10b981" stopOpacity={0.15} />
                    <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="month" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ borderRadius: 12, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }} />
                <Area type="monotone" dataKey="total" stroke="#10b981" strokeWidth={2.5} fill="url(#grad)" dot={{ r: 4, fill: '#10b981' }} />
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-52 flex items-center justify-center text-text-muted text-sm">Belum ada data donasi</div>
          )}
        </div>

        <div className="bg-white rounded-2xl border border-muted p-5 shadow-sm">
          <p className="text-sm font-semibold text-accent mb-4">Kategori Inventori</p>
          {categoryData.length > 0 ? (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={categoryData} cx="50%" cy="45%" innerRadius={55} outerRadius={80} paddingAngle={3} dataKey="value">
                  {categoryData.map((entry, i) => <Cell key={i} fill={entry.fill} />)}
                </Pie>
                <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: 12 }} />
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-52 flex items-center justify-center text-text-muted text-sm">Belum ada data</div>
          )}
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-muted p-5 shadow-sm">
        <p className="text-sm font-semibold text-accent mb-3 flex items-center justify-between">
          <span>Sebaran Panti Asuhan</span>
          <span className="text-xs font-normal text-text-muted bg-slate-50 px-2.5 py-1 rounded-full border border-muted">
            {validFoundations.length} panti aktif terpetakan
          </span>
        </p>
        
        <div className="w-full h-64 rounded-xl overflow-hidden border border-muted shadow-inner z-0 relative">
          <MapContainer 
            center={mapCenter} 
            zoom={10} 
            className="w-full h-full"
            scrollWheelZoom={true}
          >
            <TileLayer
              attribution='© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            
            <ChangeMapView center={mapCenter} />

            {validFoundations.map((f) => {
              const lng = f.location.coordinates[0];
              const lat = f.location.coordinates[1];

              return (
                <Marker key={f.id || f._id} position={[lat, lng]}>
                  <Popup maxWidth={250}>
                    <div className="p-0.5 font-sans">
                      <div className="flex items-center gap-1.5 mb-1">
                        <Building2 size={14} className="text-primary" />
                        <h4 className="font-bold text-accent m-0 text-xs leading-tight">{f.name}</h4>
                      </div>
                      <p className="text-[11px] text-text-muted m-0 mb-2 line-clamp-2">{f.address}</p>
                      
                      <div className="flex flex-col gap-1 border-t border-muted pt-1.5 mt-1">
                        {f.contact_phone && (
                          <span className="text-[10px] text-text-muted flex items-center gap-1">
                            <Phone size={10} /> {f.contact_phone}
                          </span>
                        )}
                        <a
                          href={`https://www.google.com/maps/search/?api=1&query=${lat},${lng}`}
                          target="_blank"
                          rel="noreferrer"
                          className="text-[10px] text-primary hover:text-primary-hover font-medium flex items-center gap-0.5 mt-0.5 transition-colors"
                        >
                          Buka di Google Maps <ExternalLink size={9} />
                        </a>
                      </div>
                    </div>
                  </Popup>
                </Marker>
              );
            })}
          </MapContainer>
        </div>
      </div>
    </div>
  );
}