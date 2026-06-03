// src/features/foundation-admin/pages/FADonationsPage.jsx
import { useState, useEffect, useCallback } from 'react';
import { ChevronDown } from 'lucide-react';
import Badge          from '../../../components/ui/Badge';
import ErrorState     from '../../../components/ui/ErrorState';
import { SkeletonRow } from '../../../components/ui/Skeleton';
import Pagination     from '../../../components/ui/Pagination';
import PageCard       from '../../../components/ui/PageCard';
import ConfirmDialog  from '../../../components/ui/ConfirmDialog';
import Spinner        from '../../../components/ui/Spinner';
import { api }        from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';
import { useAuth }    from '../../../context/AuthContext';

const NEXT_STATUS = { pending: 'sent', sent: 'received', received: 'verified' };
const STATUS_ACTION_LABEL = { pending: 'Tandai Dikirim', sent: 'Tandai Diterima', received: 'Verifikasi' };
const STATUS_OPTS = [
  { value: '',         label: 'Semua Status' },
  { value: 'pending',  label: 'Pending' },
  { value: 'sent',     label: 'Dikirim' },
  { value: 'received', label: 'Diterima' },
  { value: 'verified', label: 'Terverifikasi' },
];

export default function FADonationsPage() {
  const { myFoundationId } = useAuth();
  const [donations, setDonations] = useState([]);
  const [meta,      setMeta]      = useState(null);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);
  const [status,     setStatus]    = useState('');
  const [page,      setPage]      = useState(1);
  const [updating,  setUpdating]  = useState(null);
  const [expanded,  setExpanded]  = useState(null);
  const [confirm,   setConfirm]   = useState(null);
  const toast = useToast();

  const load = useCallback(async () => {
    if (!myFoundationId) return;
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ page });
      if (status) params.set('status', status);
      const res = await api.get(`/foundations/${myFoundationId}/donations?${params}`);
      setDonations(res.data ?? []);
      setMeta(res);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [myFoundationId, status, page]);

  useEffect(() => { load(); }, [load]);

  const handleUpdateStatus = async () => {
    const donation = confirm.donation;
    
    const donationActiveId = donation._id || donation.id; 
    
    const next = NEXT_STATUS[donation.status];
    if (!next || !donationActiveId || donationActiveId === 'undefined') {
      toast.error('Gagal memproses: ID Donasi tidak valid atau kosong.');
      setConfirm(null);
      return;
    }

    setConfirm(null);
    setUpdating(donationActiveId);
    try {
      await api.patch(`/donations/${donationActiveId}/status`, { status: next });
      toast.success(`Status donasi berhasil diubah ke "${next}".`);   
      load();
    } catch (err) {
      const serverMessage = err.response?.data?.message || err.message;
      toast.error(`Gagal mengubah status: ${serverMessage}`);           
    } finally {
      setUpdating(null);
    }
  };

  return (
    <>
      {confirm && (
        <ConfirmDialog
          title="Update Status Donasi?"
          message={`Status akan diubah menjadi "${NEXT_STATUS[confirm.donation.status]}".`}
          onConfirm={handleUpdateStatus}
          onCancel={() => setConfirm(null)}
          confirmLabel="Ya, Update"
        />
      )}

      <div className="space-y-4">
        <div className="flex items-center gap-2">
          <label className="text-xs text-text-muted font-medium">Filter:</label>
          <select
            value={status}
            onChange={e => { setStatus(e.target.value); setPage(1); }}
            className="text-xs border border-muted rounded-lg px-3 py-1.5 bg-white text-accent outline-none"
          >
            {STATUS_OPTS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
          </select>
        </div>

        <PageCard title="Donasi Masuk" count={meta?.total}>
          {error ? (
            <ErrorState message={error} onRetry={load} />
          ) : (
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-xs text-text-muted uppercase tracking-wide">
                <tr>
                  <th className="text-left px-5 py-3">Item</th>
                  <th className="text-left px-5 py-3 hidden md:table-cell">Tipe</th>
                  <th className="text-left px-5 py-3 hidden md:table-cell">Qty</th>
                  <th className="text-left px-5 py-3">Status</th>
                  <th className="text-left px-5 py-3">Aksi</th>
                  <th className="text-left px-5 py-3 hidden lg:table-cell">Tanggal</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {loading
                  ? [...Array(5)].map((_, i) => <SkeletonRow key={i} cols={6} />)
                  : donations.map(d => (
                    <>
                      <tr key={d._id} className="hover:bg-slate-50 transition-colors">
                        <td className="px-5 py-3.5">
                          <div className="flex items-center gap-2">
                            <button
                              onClick={() => setExpanded(expanded === d._id ? null : d._id)}
                              className="text-text-muted hover:text-accent"
                            >
                              <ChevronDown size={14} className={`transition-transform ${expanded === d._id ? 'rotate-180' : ''}`} />
                            </button>
                            <div>
                              <p className="font-medium text-accent">{d.item_detail?.name}</p>
                              {d.is_anonymous && <p className="text-xs text-text-muted">Anonim</p>}
                            </div>
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
                        <td className="px-5 py-3.5">
                          {NEXT_STATUS[d.status] ? (
                            <button
                              onClick={() => setConfirm({ donation: d })}
                              disabled={updating === d._id}
                              className="text-xs bg-primary hover:bg-primary-hover disabled:opacity-60 text-white font-medium px-3 py-1.5 rounded-lg transition-colors whitespace-nowrap flex items-center gap-1.5"
                            >
                              {updating === d._id ? <Spinner /> : null}
                              {STATUS_ACTION_LABEL[d.status]}
                            </button>
                          ) : (
                            <span className="text-xs text-text-muted">—</span>
                          )}
                        </td>
                        <td className="px-5 py-3.5 text-text-muted text-xs hidden lg:table-cell">
                          {new Date(d.created_at).toLocaleDateString('id-ID')}
                        </td>
                      </tr>
                      {expanded === d._id && (
                        <tr key={`${d._id}-expand`} className="bg-slate-50">
                          <td colSpan={6} className="px-8 py-4">
                            <p className="text-xs font-semibold text-text-muted uppercase mb-3">Riwayat Status</p>
                            <div className="space-y-2">
                              {(d.history_logs ?? []).map((log, i) => (
                                <div key={i} className="flex items-start gap-3">
                                  <div className="w-1.5 h-1.5 rounded-full bg-primary mt-1.5 shrink-0" />
                                  <div>
                                    <div className="flex items-center gap-2">
                                      <Badge value={log.status} />
                                      <span className="text-xs text-text-muted">
                                        {new Date(log.timestamp).toLocaleString('id-ID')}
                                      </span>
                                    </div>
                                    {log.note && <p className="text-xs text-accent mt-0.5">{log.note}</p>}
                                  </div>
                                </div>
                              ))}
                            </div>
                          </td>
                        </tr>
                      )}
                    </>
                  ))
                }
              </tbody>
            </table>
          )}
          <Pagination meta={meta} page={page} onPageChange={setPage} />
        </PageCard>
      </div>
    </>
  );
}