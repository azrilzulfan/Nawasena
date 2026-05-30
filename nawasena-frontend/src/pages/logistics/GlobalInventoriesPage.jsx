// src/pages/logistics/GlobalInventoriesPage.jsx
import { useState, useEffect, useCallback } from 'react';
import Badge from '../../components/ui/Badge';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';
import { api } from '../../lib/api';

const CATEGORIES   = ['Semua', 'Logistik', 'Edukasi', 'Medis'];
const URGENCY_OPTS = [
  { value: '',       label: 'Semua' },
  { value: 'high',   label: 'Tinggi' },
  { value: 'medium', label: 'Sedang' },
  { value: 'low',    label: 'Rendah' },
];

export default function GlobalInventoriesPage() {
  const [items,     setItems]    = useState([]);
  const [meta,      setMeta]     = useState(null);
  const [loading,   setLoading]  = useState(true);
  const [error,     setError]    = useState(null);
  const [category,  setCategory] = useState('');
  const [urgency,   setUrgency]  = useState('');
  const [page,      setPage]     = useState(1);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ page });
      if (category) params.set('category', category);
      if (urgency)  params.set('urgent_level', urgency);
      const res = await api.get(`/inventories?${params}`);
      setItems(res.data ?? []);
      setMeta(res);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [category, urgency, page]);

  useEffect(() => { load(); }, [load]);

  const handleFilter = (newCat, newUrg) => {
    setCategory(newCat === 'Semua' ? '' : newCat);
    setUrgency(newUrg);
    setPage(1);
  };

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex gap-1">
          {CATEGORIES.map(c => (
            <button
              key={c}
              onClick={() => handleFilter(c, urgency)}
              className={`text-xs px-3 py-1.5 rounded-lg font-medium transition-colors
                ${(category === (c === 'Semua' ? '' : c))
                  ? 'bg-emerald-600 text-white'
                  : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
                }`}
            >
              {c}
            </button>
          ))}
        </div>
        <select
          value={urgency}
          onChange={e => handleFilter(category || 'Semua', e.target.value)}
          className="text-xs border border-slate-200 rounded-lg px-3 py-1.5 bg-white text-slate-600 outline-none"
        >
          {URGENCY_OPTS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        {error ? (
          <ErrorState message={error} onRetry={load} />
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
              <tr>
                <th className="text-left px-5 py-3">Item</th>
                <th className="text-left px-5 py-3">Kategori</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Stok / Target</th>
                <th className="text-left px-5 py-3">Urgensi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {loading
                ? [...Array(5)].map((_, i) => <SkeletonRow key={i} cols={4} />)
                : items.map(item => (
                  <tr
                    key={item._id}
                    className={`transition-colors ${
                      item.urgent_level === 'high'
                        ? 'bg-rose-50 hover:bg-rose-100'
                        : 'hover:bg-slate-50'
                    }`}
                  >
                    <td className="px-5 py-3.5 font-medium text-slate-800">{item.item_name}</td>
                    <td className="px-5 py-3.5 text-slate-500">{item.category}</td>
                    <td className="px-5 py-3.5 text-slate-600 hidden md:table-cell">
                      {item.current_qty} / {item.target_qty} {item.unit}
                    </td>
                    <td className="px-5 py-3.5">
                      <Badge value={item.urgent_level} />
                    </td>
                  </tr>
                ))
              }
            </tbody>
          </table>
        )}

        {meta && meta.last_page > 1 && (
          <div className="px-5 py-3 border-t border-slate-100 flex items-center justify-between">
            <button disabled={page <= 1} onClick={() => setPage(p => p - 1)}
              className="text-xs px-3 py-1.5 border border-slate-200 rounded-lg disabled:opacity-40 hover:bg-slate-50">
              ← Sebelumnya
            </button>
            <span className="text-xs text-slate-500">{meta.current_page} / {meta.last_page}</span>
            <button disabled={page >= meta.last_page} onClick={() => setPage(p => p + 1)}
              className="text-xs px-3 py-1.5 border border-slate-200 rounded-lg disabled:opacity-40 hover:bg-slate-50">
              Berikutnya →
            </button>
          </div>
        )}
      </div>
    </div>
  );
}