// src/pages/foundations/VerificationQueuePage.jsx
/* eslint-disable no-unused-vars */
import { useState } from 'react';
import { CheckCircle, FileText } from 'lucide-react';
import { useFetch } from '../../hooks/useFetch';
import { api } from '../../lib/api';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';

export default function VerificationQueuePage() {
  const { data, loading, error, refetch } = useFetch('/foundations?is_verified=0');
  const [verifying, setVerifying] = useState(null);

  const foundations = data?.data ?? [];

  const handleVerify = async (foundation) => {
    const targetId = foundation.id || foundation._id;
    
    if (!targetId) {
      alert("Gagal memproses: ID Panti tidak ditemukan.");
      return;
    }

    if (!confirm(`Verifikasi panti ${foundation.name}?`)) return;
    setVerifying(targetId);
    try {
      await api.patch(`/foundations/${targetId}/verify`);
      refetch();
    } catch (err) {
      alert(err.message);
    } finally {
      setVerifying(null);
    }
  };

  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
      <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
        <p className="font-semibold text-slate-800">Antrean Verifikasi</p>
        {!loading && (
          <span className="bg-amber-100 text-amber-700 text-xs font-medium px-2.5 py-1 rounded-full">
            {foundations.length} Menunggu
          </span>
        )}
      </div>

      {error ? (
        <ErrorState message={error} onRetry={refetch} />
      ) : (
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
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
                <td colSpan={5} className="px-5 py-12 text-center text-slate-400 text-sm">
                  Tidak ada panti yang menunggu verifikasi
                </td>
              </tr>
            ) : foundations.map(f => (
              <tr key={f._id} className="hover:bg-slate-50 transition-colors">
                <td className="px-5 py-3.5 font-medium text-slate-800">{f.name}</td>
                <td className="px-5 py-3.5 text-slate-500 hidden md:table-cell">{f.address}</td>
                <td className="px-5 py-3.5 text-slate-500 hidden lg:table-cell">{f.contact_phone}</td>
                <td className="px-5 py-3.5 text-slate-400 text-xs hidden lg:table-cell">
                  {new Date(f.created_at).toLocaleDateString('id-ID')}
                </td>
                <td className="px-5 py-3.5">
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => handleVerify(f)}
                      disabled={verifying === (f.id || f._id)}
                      className="flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-60 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition-colors"
                    >
                      <CheckCircle size={13} />
                      {verifying === f._id ? 'Memproses...' : 'Verifikasi'}
                    </button>
                    
                    {f.verification_docs?.length > 0 && (
                      <a
                        href={f.verification_docs[0]}
                        target="_blank"
                        rel="noreferrer"
                        className="p-1.5 text-blue-400 hover:text-blue-700 hover:bg-blue-100 rounded-lg transition-colors"
                        title="Lihat dokumen"
                      >
                        <FileText size={14} />
                      </a>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {data && data.last_page > 1 && (
        <div className="px-5 py-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
          <span>Halaman {data.current_page} dari {data.last_page}</span>
          <span>{data.total} total</span>
        </div>
      )}
    </div>
  );
}