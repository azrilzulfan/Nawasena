// src/features/foundation-admin/pages/FAOverviewPage.jsx
import { useEffect, useState, useCallback } from 'react';
import { Boxes, TrendingUp, Users, AlertTriangle } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import StatCard   from '../../../components/ui/StatCard';
import ErrorState from '../../../components/ui/ErrorState';
import Spinner    from '../../../components/ui/Spinner';
import { api }    from '../../../lib/api';
import { useAuth } from '../../../context/AuthContext';

const STATUS_COLORS = { pending: '#f59e0b', sent: '#3b82f6', received: '#9810fa', verified: '#10b981' };
const STATUS_LABELS = { pending: 'Pending', sent: 'Dikirim', received: 'Diterima', verified: 'Terverifikasi' };

function NotLinkedState() {
  const { refreshUser } = useAuth();
  const [checking, setChecking] = useState(false);
  const [stillEmpty, setStillEmpty] = useState(false);

  const handleRetry = async () => {
    setChecking(true);
    setStillEmpty(false);
    const fresh = await refreshUser();
    if (!fresh?.managed_foundation_id) setStillEmpty(true);
    setChecking(false);
  };

  return (
    <div className="flex flex-col items-center justify-center py-20 font-sans">
      <div className="bg-white rounded-2xl border border-muted shadow-sm p-8 max-w-sm w-full text-center">
        <div className="w-14 h-14 bg-amber-50 rounded-full flex items-center justify-center mx-auto mb-4">
          <AlertTriangle size={28} className="text-amber-500" />
        </div>
        <h3 className="font-semibold text-accent mb-2">Yayasan belum terhubung</h3>
        <p className="text-sm text-text-muted mb-5">
          Akun Anda belum terhubung ke yayasan manapun. Ini bisa terjadi jika proses pendaftaran belum selesai.
        </p>
        {stillEmpty && <p className="text-xs text-rose-500 mb-4">Data yayasan belum tersedia. Hubungi Super Admin.</p>}
        <button onClick={handleRetry} disabled={checking}
          className="w-full bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl flex items-center justify-center gap-2 transition-colors">
          {checking ? <><Spinner />Memeriksa...</> : 'Periksa Ulang'}
        </button>
      </div>
    </div>
  );
}

export default function FAOverviewPage() {
  const { myFoundationId } = useAuth();
  const [analytics, setAnalytics] = useState(null);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);

  const load = useCallback(async () => {
    if (!myFoundationId) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.get(`/foundations/${myFoundationId}/analytics`);
      setAnalytics(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [myFoundationId]);

  useEffect(() => { load(); }, [load]);

  if (!myFoundationId) return <NotLinkedState />;

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => <div key={i} className="h-24 bg-white rounded-2xl border border-muted animate-pulse" />)}
        </div>
        <div className="h-72 bg-white rounded-2xl border border-muted animate-pulse" />
      </div>
    );
  }

  if (error) return <ErrorState message={error} onRetry={load} />;

  const donationChartData = Object.entries(analytics.donations.by_status ?? {}).map(([k, v]) => ({
    name: STATUS_LABELS[k] ?? k, value: v, fill: STATUS_COLORS[k] ?? '#94a3b8',
  }));

  const inventoryChartData = (analytics.inventory.items ?? []).slice(0, 8).map(item => ({
    name: item.item_name.length > 14 ? item.item_name.slice(0, 14) + '…' : item.item_name,
    stok: item.current_qty,
    target: item.target_qty,
  }));

  return (
    <div className="space-y-6 font-sans">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={TrendingUp} color="emerald" label="Total Donasi" value={analytics.donations.total}
          sub={`${analytics.donations.by_status?.verified ?? 0} terverifikasi`} />
        <StatCard icon={Boxes} color="blue" label="Total Item" value={analytics.inventory.total_items}
          sub="Kebutuhan terdaftar" />
        <StatCard icon={AlertTriangle} color="rose" label="Item Mendesak" value={analytics.inventory.urgent_items}
          sub="Butuh donasi segera" />
        <StatCard icon={Users} color="amber" label="Total Relawan" value={analytics.volunteers.total_registered}
          sub={`${analytics.volunteers.total_workshops} workshop`} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl border border-muted p-5 shadow-sm">
          <p className="text-sm font-semibold text-accent mb-4">Status Donasi</p>
          {donationChartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={240}>
              <PieChart>
                <Pie data={donationChartData} cx="50%" cy="45%" innerRadius={60} outerRadius={90} paddingAngle={3} dataKey="value">
                  {donationChartData.map((e, i) => <Cell key={i} fill={e.fill} />)}
                </Pie>
                <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: 12 }} />
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-52 flex items-center justify-center text-text-muted text-sm">Belum ada donasi</div>
          )}
        </div>
        <div className="bg-white rounded-2xl border border-muted p-5 shadow-sm">
          <p className="text-sm font-semibold text-accent mb-4">Stok vs Target Inventori</p>
          {inventoryChartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={inventoryChartData} barSize={12}>
                <XAxis dataKey="name" tick={{ fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ borderRadius: 12, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }} />
                <Bar dataKey="stok"   fill="#5E7D6C" radius={[4,4,0,0]} name="Stok" />
                <Bar dataKey="target" fill="#E2E8F0" radius={[4,4,0,0]} name="Target" />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-52 flex items-center justify-center text-text-muted text-sm">Belum ada inventori</div>
          )}
        </div>
      </div>

      {analytics.inventory.urgent_items > 0 && (
        <div className="bg-rose-50 border border-rose-200 rounded-2xl p-4 flex items-start gap-3">
          <AlertTriangle size={18} className="text-rose-500 shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-semibold text-rose-700">
              {analytics.inventory.urgent_items} item inventori dalam kondisi mendesak
            </p>
            <p className="text-xs text-rose-500 mt-0.5">
              Stok hampir habis. Segera informasikan kepada donatur melalui halaman Kebutuhan.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}