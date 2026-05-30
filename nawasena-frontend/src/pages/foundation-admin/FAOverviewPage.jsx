// src/pages/foundation-admin/FAOverviewPage.jsx
import { useEffect, useState } from 'react';
import { Boxes, TrendingUp, Users, AlertTriangle } from 'lucide-react';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend,
} from 'recharts';
import StatCard from '../../components/ui/StatCard';
import ErrorState from '../../components/ui/ErrorState';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';

const STATUS_COLORS = {
  pending: '#f59e0b', sent: '#3b82f6', received: '#6366f1', verified: '#10b981',
};
const STATUS_LABELS = {
  pending: 'Pending', sent: 'Dikirim', received: 'Diterima', verified: 'Terverifikasi',
};

function NotLinkedState() {
  const { refreshUser } = useAuth();
  const [checking, setChecking] = useState(false);
  const [stillEmpty, setStillEmpty] = useState(false);

  const handleRetry = async () => {
    setChecking(true);
    setStillEmpty(false);
    const fresh = await refreshUser();
    if (!fresh?.managed_foundation_id) {
      setStillEmpty(true);
    }
    setChecking(false);
  };

  return (
    <div className="flex flex-col items-center justify-center py-20">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8 max-w-sm w-full text-center">
        <div className="w-14 h-14 bg-amber-50 rounded-full flex items-center justify-center mx-auto mb-4">
          <AlertTriangle size={28} className="text-amber-500" />
        </div>
        <h3 className="font-semibold text-slate-800 mb-2">Yayasan belum terhubung</h3>
        <p className="text-sm text-slate-400 mb-5">
          Akun Anda belum terhubung ke yayasan manapun. Ini bisa terjadi jika proses pendaftaran yayasan belum selesai.
        </p>

        {stillEmpty && (
          <p className="text-xs text-rose-500 mb-4">
            Data yayasan belum tersedia. Hubungi Super Admin jika masalah berlanjut.
          </p>
        )}

        <button
          onClick={handleRetry}
          disabled={checking}
          className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2"
        >
          {checking
            ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />Memeriksa...</>
            : 'Periksa Ulang'
          }
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

  const load = async () => {
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
  };

  useEffect(() => { load(); }, [myFoundationId]);

  if (!myFoundationId) {
    return (
        <NotLinkedState />
    )
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="h-24 bg-white rounded-2xl border border-slate-100 animate-pulse" />
          ))}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <div className="h-72 bg-white rounded-2xl border border-slate-100 animate-pulse" />
          <div className="h-72 bg-white rounded-2xl border border-slate-100 animate-pulse" />
        </div>
      </div>
    );
  }

  if (error) return <ErrorState message={error} onRetry={load} />;

  const donationChartData = Object.entries(analytics.donations.by_status ?? {}).map(([k, v]) => ({
    name: STATUS_LABELS[k] ?? k, value: v, fill: STATUS_COLORS[k] ?? '#94a3b8',
  }));

  const inventoryChartData = (analytics.inventory.items ?? [])
    .slice(0, 8)
    .map(item => ({
      name: item.item_name.length > 14 ? item.item_name.slice(0, 14) + '…' : item.item_name,
      stok: item.current_qty,
      target: item.target_qty,
    }));

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={TrendingUp} color="emerald"
          label="Total Donasi"
          value={analytics.donations.total}
          sub={`${analytics.donations.by_status?.verified ?? 0} terverifikasi`}
        />
        <StatCard
          icon={Boxes} color="blue"
          label="Total Item"
          value={analytics.inventory.total_items}
          sub="Kebutuhan terdaftar"
        />
        <StatCard
          icon={AlertTriangle} color="rose"
          label="Item Mendesak"
          value={analytics.inventory.urgent_items}
          sub="Butuh donasi segera"
        />
        <StatCard
          icon={Users} color="amber"
          label="Total Relawan"
          value={analytics.volunteers.total_registered}
          sub={`${analytics.volunteers.total_workshops} workshop`}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-2xl border border-slate-100 p-5 shadow-sm">
          <p className="text-sm font-semibold text-slate-700 mb-4">Status Donasi</p>
          {donationChartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={240}>
              <PieChart>
                <Pie
                  data={donationChartData} cx="50%" cy="45%"
                  innerRadius={60} outerRadius={90} paddingAngle={3} dataKey="value"
                >
                  {donationChartData.map((entry, i) => <Cell key={i} fill={entry.fill} />)}
                </Pie>
                <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: 12 }} />
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-52 flex items-center justify-center text-slate-400 text-sm">Belum ada donasi</div>
          )}
        </div>

        <div className="bg-white rounded-2xl border border-slate-100 p-5 shadow-sm">
          <p className="text-sm font-semibold text-slate-700 mb-4">Stok vs Target Inventori</p>
          {inventoryChartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={inventoryChartData} barSize={12}>
                <XAxis dataKey="name" tick={{ fontSize: 10 }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ borderRadius: 12, border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }} />
                <Bar dataKey="stok"   fill="#3b82f6" radius={[4, 4, 0, 0]} name="Stok" />
                <Bar dataKey="target" fill="#e2e8f0" radius={[4, 4, 0, 0]} name="Target" />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-52 flex items-center justify-center text-slate-400 text-sm">Belum ada inventori</div>
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