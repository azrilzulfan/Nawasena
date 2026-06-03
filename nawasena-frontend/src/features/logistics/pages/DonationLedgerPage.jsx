// src/features/logistics/pages/DonationLedgerPage.jsx
import { useState, useEffect, useCallback } from 'react';
import Badge      from '../../../components/ui/Badge';
import ErrorState from '../../../components/ui/ErrorState';
import { SkeletonRow } from '../../../components/ui/Skeleton';
import Pagination from '../../../components/ui/Pagination';
import PageCard   from '../../../components/ui/PageCard';
import { api }    from '../../../lib/api';

const STATUS_OPTS = [
  { value: '',         label: 'Semua Status' },
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
  const [status,     setStatus]    = useState('');
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
    <div className="space-y-4 font-sans">
      <div className="flex items-center gap-2">
        <label className="text-xs text-text-muted font-medium">Filter Status:</label>
        <select value={status} onChange={e => { setStatus(e.target.value); setPage(1); }}
          className="text-xs border border-muted rounded-lg px-3 py-1.5 bg-white text-accent outline-none">
          {STATUS_OPTS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      </div>
      <PageCard title="Ledger Donasi" count={meta?.total}>
        {error ? (
          <ErrorState message={error} onRetry={load} />
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-xs text-text-muted uppercase tracking-wide">
              <tr>
                <th className="text-left px-5 py-3">Item</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Tipe</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Kuantiti</th>
                <th className="text-left px-5 py-3">Status</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Tanggal</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {loading
                ? [...Array(5)].map((_, i) => <SkeletonRow key={i} cols={5} />)
                : donations.map(d => (
                  <tr key={d._id || d.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-3.5">
                      <div className="flex flex-col">
                        {/* Nama Item Utama */}
                        <p className="font-medium text-accent">{d.item_detail?.name}</p>
                        
                        {/* PENAMBAHAN: Nama Panti Asuhan Tujuan */}
                        <span className="text-xs text-text-muted font-normal mt-0.5">
                          {d.foundation?.name || d.foundation_name || 'Nama Panti Tidak Tersedia'}
                        </span>

                        {d.is_anonymous && (
                          <span className="text-[10px] bg-slate-100 text-text-muted px-1.5 py-0.5 rounded mt-1 self-start">
                            Anonim
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-5 py-3.5 hidden md:table-cell">
                      <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${d.type === 'goods' ? 'bg-secondary/10 text-primary' : 'bg-purple-50 text-purple-600'}`}>
                        {d.type === 'goods' ? 'Barang' : 'Uang'}
                      </span>
                    </td>
                    <td className="px-5 py-3.5 text-accent hidden md:table-cell">
                      {d.item_detail?.qty} {d.item_detail?.unit}
                    </td>
                    <td className="px-5 py-3.5"><Badge value={d.status} /></td>
                    <td className="px-5 py-3.5 text-text-muted text-xs hidden lg:table-cell">
                      {d.created_at ? new Date(d.created_at).toLocaleDateString('id-ID') : '—'}
                    </td>
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