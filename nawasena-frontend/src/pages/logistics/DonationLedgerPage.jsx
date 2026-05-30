// src/pages/logistics/DonationLedgerPage.jsx
import { useState, useEffect, useCallback } from 'react';
import Badge from '../../components/ui/Badge';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';
import { api } from '../../lib/api';

const STATUS_OPTS = [
  { value: '', label: 'Semua Status' },
  { value: 'pending',  label: 'Pending' },
  { value: 'sent',     label: 'Dikirim' },
  { value: 'received', label: 'Diterima' },
  { value: 'verified', label: 'Terverifikasi' },
];

export default function DonationLedgerPage() {
  const [donations, setDonations] = useState([]);
  const [meta,      setMeta]      = useState(null);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);
  const [status,    setStatus]    = useState('');
  const [page,      setPage]      = useState(1);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ page });
      if (status) params.set('status', status);
      const res = await api.get(`/donations?${params}`);
      setDonations(res.data ?? []);
      setMeta(res);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [status, page]);

  useEffect(() => { load(); }, [load]);

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <label className="text-xs text-slate-500 font-medium">Filter Status:</label>
        <select
          value={status}
          onChange={e => { setStatus(e.target.value); setPage(1); }}
          className="text-xs border border-slate-200 rounded-lg px-3 py-1.5 bg-white text-slate-600 outline-none"
        >
          {STATUS_OPTS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <p className="font-semibold text-slate-800">
            Ledger Donasi
            {meta && <span className="text-slate-400 font-normal text-sm ml-1">({meta.total})</span>}
          </p>
        </div>
        {error ? (
          <ErrorState message={error} onRetry={load} />
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
              <tr>
                <th className="text-left px-5 py-3">Item</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Tipe</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Qty</th>
                <th className="text-left px-5 py-3">Status</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Tanggal</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {loading
                ? [...Array(5)].map((_, i) => <SkeletonRow key={i} cols={5} />)
                : donations.map(d => (
                  <tr key={d._id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-3.5">
                      <p className="font-medium text-slate-800">{d.item_detail?.name}</p>
                      {d.is_anonymous && <span className="text-xs text-slate-400">Anonim</span>}
                    </td>
                    <td className="px-5 py-3.5 hidden md:table-cell">
                      <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                        d.type === 'goods'
                          ? 'bg-blue-50 text-blue-600'
                          : 'bg-purple-50 text-purple-600'
                      }`}>
                        {d.type === 'goods' ? 'Barang' : 'Uang'}
                      </span>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 hidden md:table-cell">
                      {d.item_detail?.qty} {d.item_detail?.unit}
                    </td>
                    <td className="px-5 py-3.5">
                      <Badge value={d.status} />
                    </td>
                    <td className="px-5 py-3.5 text-slate-400 text-xs hidden lg:table-cell">
                      {new Date(d.created_at).toLocaleDateString('id-ID')}
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