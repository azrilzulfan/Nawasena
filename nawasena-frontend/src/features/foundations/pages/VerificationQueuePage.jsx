// src/features/foundations/pages/VerificationQueuePage.jsx
import { useState } from 'react';
import { CheckCircle, FileText } from 'lucide-react';
import { useFetch }    from '../../../hooks/useFetch';
import { api }         from '../../../lib/api';
import { useToast }    from '../../../context/ToastContext';
import ErrorState      from '../../../components/ui/ErrorState';
import { SkeletonRow } from '../../../components/ui/Skeleton';
import PageCard        from '../../../components/ui/PageCard';
import ConfirmDialog   from '../../../components/ui/ConfirmDialog';

export default function VerificationQueuePage() {
  const { data, loading, error, refetch } = useFetch('/foundations?is_verified=0');
  const [verifying, setVerifying] = useState(null);
  const [confirm,   setConfirm]   = useState(null);
  const [actionError, setActionError] = useState(null);
  const toast = useToast();

  const foundations = data?.data ?? [];

  const handleVerify = async () => {
    const foundation = confirm.foundation;
    const id = foundation._id ?? foundation.id;
    setConfirm(null);
    setVerifying(id);
    try {
      await api.patch(`/foundations/${id}/verify`);
      toast.success(`Panti "${foundation.name}" berhasil diverifikasi.`);   
      refetch();
    } catch (err) {
      toast.error(`Gagal memverifikasi: ${err.message}`);                                     
    } finally {
      setVerifying(null);
    }
  };

  const pendingCount = !loading ? foundations.length : undefined;
  const headerActions = pendingCount !== undefined ? (
    <span className="bg-amber-100 text-amber-700 text-xs font-medium px-2.5 py-1 rounded-full">
      {pendingCount} Menunggu
    </span>
  ) : null;

  return (
    <>
      {confirm && (
        <ConfirmDialog
          message={`Verifikasi panti "${confirm.foundation.name}"?`}
          confirmLabel="Verifikasi"
          onConfirm={handleVerify}
          onCancel={() => setConfirm(null)}
        />
      )}

      <PageCard title="Antrean Verifikasi" actions={headerActions}>
        {error ? (
          <ErrorState message={error} onRetry={refetch} />
        ) : (
          <table className="w-full text-sm font-sans">
            <thead className="bg-slate-50 text-xs text-text-muted uppercase tracking-wide">
              <tr>
                <th className="text-left px-5 py-3">Nama Panti</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Alamat</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Kontak</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Didaftarkan</th>
                <th className="text-left px-5 py-3">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {loading ? (
                [...Array(3)].map((_, i) => <SkeletonRow key={i} cols={5} />)
              ) : foundations.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-5 py-12 text-center text-text-muted text-sm">
                    Tidak ada panti yang menunggu verifikasi
                  </td>
                </tr>
              ) : foundations.map(f => {
                const fId = f._id ?? f.id;
                return (
                  <tr key={fId} className="hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-3.5 font-medium text-accent">{f.name}</td>
                    <td className="px-5 py-3.5 text-text-muted hidden md:table-cell">{f.address}</td>
                    <td className="px-5 py-3.5 text-text-muted hidden lg:table-cell">{f.contact_phone}</td>
                    <td className="px-5 py-3.5 text-text-muted text-xs hidden lg:table-cell">
                      {new Date(f.created_at).toLocaleDateString('id-ID')}
                    </td>
                    <td className="px-5 py-3.5">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => setConfirm({ foundation: f })}
                          disabled={verifying === fId}
                          className="flex items-center gap-1.5 bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition-colors"
                        >
                          <CheckCircle size={13} />
                          {verifying === fId ? 'Memproses…' : 'Verifikasi'}
                        </button>
                        {f.verification_docs?.[0] && (
                          <a href={f.verification_docs[0]} target="_blank" rel="noreferrer"
                            className="p-1.5 text-secondary hover:text-primary hover:bg-secondary/10 rounded-lg transition-colors"
                            title="Lihat dokumen">
                            <FileText size={14} />
                          </a>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </PageCard>
    </>
  );
}