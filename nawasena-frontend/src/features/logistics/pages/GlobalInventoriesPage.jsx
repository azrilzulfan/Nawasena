// src/features/logistics/pages/GlobalInventoriesPage.jsx
import { useState, useEffect, useCallback } from 'react';
import Badge      from '../../../components/ui/Badge';
import ErrorState from '../../../components/ui/ErrorState';
import { SkeletonRow } from '../../../components/ui/Skeleton';
import Pagination from '../../../components/ui/Pagination';
import PageCard   from '../../../components/ui/PageCard';
import { api }    from '../../../lib/api';

const CATEGORIES   = ['Semua', 'Logistik', 'Edukasi', 'Medis'];
const URGENCY_OPTS = [
  { value: '',       label: 'Semua Urgensi' },
  { value: 'high',   label: 'Tinggi' },
  { value: 'medium', label: 'Sedang' },
  { value: 'low',    label: 'Rendah' },
];

export default function GlobalInventoriesPage() {
  const [items,    setItems]    = useState([]);
  const [meta,     setMeta]     = useState(null);
  const [loading,  setLoading]  = useState(true);
  const [error,    setError]    = useState(null);
  const [category, setCategory] = useState('');
  const [urgency,  setUrgency]  = useState('');
  const [page,     setPage]     = useState(1);

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

  return (
    <div className="space-y-4 font-sans">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex gap-1">
          {CATEGORIES.map(c => {
            const val = c === 'Semua' ? '' : c;
            return (
              <button key={c} onClick={() => { setCategory(val); setPage(1); }}
                className={`text-xs px-3 py-1.5 rounded-lg font-medium transition-colors
                  ${category === val
                    ? 'bg-primary text-white'
                    : 'bg-white border border-muted text-accent hover:bg-slate-50'
                  }`}>
                {c}
              </button>
            );
          })}
        </div>
        <select value={urgency} onChange={e => { setUrgency(e.target.value); setPage(1); }}
          className="text-xs border border-muted rounded-lg px-3 py-1.5 bg-white text-accent outline-none">
          {URGENCY_OPTS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      </div>

      <PageCard>
        {error ? (
          <ErrorState message={error} onRetry={load} />
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-xs text-text-muted uppercase tracking-wide">
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
                  <tr key={item._id || item.id}
                    className={`transition-colors ${item.urgent_level === 'high' ? 'bg-rose-50 hover:bg-rose-100' : 'hover:bg-slate-50'}`}>
                    <td className="px-5 py-3.5">
                      <div className="flex flex-col">
                        {/* Nama Barang Kebutuhan */}
                        <p className="font-medium text-accent">{item.item_name}</p>
                        
                        {/* PENAMBAHAN: Nama Panti Pemilik Inventori */}
                        <span className="text-xs text-text-muted font-normal mt-0.5">
                          {item.foundation?.name || item.foundation_name || 'Nama Panti Tidak Tersedia'}
                        </span>
                      </div>
                    </td>
                    <td className="px-5 py-3.5 text-text-muted">{item.category}</td>
                    <td className="px-5 py-3.5 text-accent hidden md:table-cell">
                      {item.current_qty} / {item.target_qty} {item.unit}
                    </td>
                    <td className="px-5 py-3.5"><Badge value={item.urgent_level} /></td>
                  </tr>
                ))
              }
            </tbody>
          </table>
        )}
        <Pagination meta={meta} page={page} onPageChange={setPage} />
      </PageCard>
    </div>
  );
}