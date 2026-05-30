// src/pages/foundations/FoundationListPage.jsx
import { useState, useEffect, useCallback } from 'react';
import { Search, MapPin } from 'lucide-react';
import { api } from '../../lib/api';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';

export default function FoundationListPage() {
  const [foundations, setFoundations] = useState([]);
  const [search,    setSearch]   = useState('');
  const [query,     setQuery]    = useState(''); 
  const [page,      setPage]     = useState(1);
  const [meta,      setMeta]     = useState(null);
  const [loading,   setLoading]  = useState(true);
  const [error,     setError]    = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ is_verified: 1, page });
      if (query) params.set('search', query);
      const res = await api.get(`/foundations?${params}`);
      setFoundations(res.data ?? []);
      setMeta(res);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [query, page]);

  useEffect(() => { load(); }, [load]);

  useEffect(() => {
    const t = setTimeout(() => { setQuery(search); setPage(1); }, 400);
    return () => clearTimeout(t);
  }, [search]);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-xl px-4 py-2.5 w-full max-w-sm shadow-sm">
        <Search size={15} className="text-slate-400 shrink-0" />
        <input
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder="Cari nama atau alamat..."
          className="bg-transparent text-sm outline-none text-slate-600 placeholder:text-slate-400 w-full"
        />
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <p className="font-semibold text-slate-800">
            Panti Terverifikasi
            {meta && <span className="text-slate-400 font-normal text-sm ml-1">({meta.total})</span>}
          </p>
        </div>

        {error ? (
          <ErrorState message={error} onRetry={load} />
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
              <tr>
                <th className="text-left px-5 py-3">Nama Panti</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Lokasi</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Kontak</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Bergabung</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {loading ? (
                [...Array(5)].map((_, i) => <SkeletonRow key={i} cols={4} />)
              ) : foundations.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-5 py-12 text-center text-slate-400 text-sm">
                    Tidak ada hasil ditemukan
                  </td>
                </tr>
              ) : foundations.map(f => (
                <tr key={f._id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-5 py-3.5 font-medium text-slate-800">{f.name}</td>
                  <td className="px-5 py-3.5 hidden md:table-cell">
                    <div className="flex items-center gap-1.5 text-slate-500">
                      <MapPin size={12} />{f.address}
                    </div>
                  </td>
                  <td className="px-5 py-3.5 text-slate-500 hidden lg:table-cell">{f.contact_phone}</td>
                  <td className="px-5 py-3.5 text-slate-400 text-xs hidden lg:table-cell">
                    {new Date(f.created_at).toLocaleDateString('id-ID')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {meta && meta.last_page > 1 && (
          <div className="px-5 py-3 border-t border-slate-100 flex items-center justify-between">
            <button
              disabled={page <= 1}
              onClick={() => setPage(p => p - 1)}
              className="text-xs px-3 py-1.5 border border-slate-200 rounded-lg disabled:opacity-40 hover:bg-slate-50"
            >
              ← Sebelumnya
            </button>
            <span className="text-xs text-slate-500">
              Halaman {meta.current_page} / {meta.last_page}
            </span>
            <button
              disabled={page >= meta.last_page}
              onClick={() => setPage(p => p + 1)}
              className="text-xs px-3 py-1.5 border border-slate-200 rounded-lg disabled:opacity-40 hover:bg-slate-50"
            >
              Berikutnya →
            </button>
          </div>
        )}
      </div>
    </div>
  );
}