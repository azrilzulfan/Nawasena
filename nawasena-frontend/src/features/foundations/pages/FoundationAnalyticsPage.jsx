// src/features/foundations/pages/FoundationAnalyticsPage.jsx
import { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { useFetch } from '../../../hooks/useFetch';
import { api } from '../../../lib/api';
import ErrorState from '../../../components/ui/ErrorState';

const STATUS_LABELS = { pending: 'Pending', sent: 'Dikirim', received: 'Diterima', verified: 'Terverifikasi' };

export default function FoundationAnalyticsPage() {
  const { data: fData, loading: fLoading } = useFetch('/foundations?is_verified=1');
  const foundations = fData?.data ?? [];

  const [selectedId,   setSelectedId]  = useState('');
  const [analytics,    setAnalytics]   = useState(null);
  const [loading,      setLoading]     = useState(false);
  const [error,        setError]       = useState(null);

  useEffect(() => {
    if (foundations.length && !selectedId) setSelectedId(foundations[0]._id);
  }, [foundations, selectedId]);

  useEffect(() => {
    if (!selectedId) return;
    setLoading(true);
    setError(null);
    api.get(`/foundations/${selectedId}/analytics`)
      .then(setAnalytics)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false));
  }, [selectedId]);

  const chartData = analytics
    ? Object.entries(analytics.donations.by_status ?? {}).map(([k, v]) => ({
        status: STATUS_LABELS[k] ?? k, total: v,
      }))
    : [];

  return (
    <div className="space-y-5 font-sans">
      <div className="flex items-center gap-3">
        <label className="text-sm font-medium text-text-muted">Pilih Panti:</label>
        <select
          value={selectedId}
          onChange={e => setSelectedId(e.target.value)}
          disabled={fLoading}
          className="text-sm border border-muted rounded-xl px-3 py-2 bg-white text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent disabled:opacity-50"
        >
          {foundations.map(f => <option key={f._id} value={f._id}>{f.name}</option>)}
        </select>
      </div>

      {error && <ErrorState message={error} />}

      {loading && (
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="h-20 bg-white rounded-2xl border border-muted animate-pulse" />
          ))}
        </div>
      )}

      {!loading && analytics && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {[
              { label: 'Total Donasi',   value: analytics.donations.total },
              { label: 'Item Inventori', value: analytics.inventory.total_items },
              { label: 'Item Mendesak',  value: analytics.inventory.urgent_items },
              { label: 'Total Relawan',  value: analytics.volunteers.total_registered },
              { label: 'Total Workshop', value: analytics.volunteers.total_workshops },
            ].map(({ label, value }) => (
              <div key={label} className="bg-white rounded-2xl border border-muted p-4 shadow-sm">
                <p className="text-xs text-text-muted">{label}</p>
                <p className="text-2xl font-bold text-accent mt-1">{value}</p>
              </div>
            ))}
          </div>

          <div className="bg-white rounded-2xl border border-muted p-5 shadow-sm">
            <p className="text-sm font-semibold text-accent mb-4">Distribusi Status Donasi</p>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={chartData} barSize={36}>
                <XAxis dataKey="status" tick={{ fontSize: 12 }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 12 }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ borderRadius: 12, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }} />
                <Bar dataKey="total" fill="#5E7D6C" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </>
      )}
    </div>
  );
}