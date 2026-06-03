// src/features/foundation-admin/pages/FAWorkshopsPage.jsx
import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { CalendarDays, Users, ToggleLeft, ToggleRight, CheckCircle } from 'lucide-react';
import Badge      from '../../../components/ui/Badge';
import ProgressBar from '../../../components/ui/ProgressBar';
import ErrorState from '../../../components/ui/ErrorState';
import { SkeletonCard } from '../../../components/ui/Skeleton';
import ConfirmDialog from '../../../components/ui/ConfirmDialog'; // ← IMPORT DIALOG KONFIRMASI
import { api }    from '../../../lib/api';
import { useToast } from '../../../context/ToastContext';
import { useAuth } from '../../../context/AuthContext';

const NEXT_STATUS = { open: 'closed', closed: 'open' };

export default function FAWorkshopsPage() {
  const navigate = useNavigate();
  const { myFoundationId } = useAuth();
  const [workshops, setWorkshops] = useState([]);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);
  const [toggling,  setToggling]  = useState(null);
  const [confirmData, setConfirmData] = useState(null); // ← STATE UNTUK CONTROL DIALOG
  const toast = useToast();

  // Memuat daftar kegiatan workshop dari API Laravel
  const load = useCallback(async () => {
    if (!myFoundationId) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.get(`/foundations/${myFoundationId}/workshops`);
      setWorkshops(Array.isArray(data) ? data : data.data ?? []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [myFoundationId]);

  useEffect(() => { load(); }, [load]);

  // Handler untuk Mengubah Status Pendaftaran (Open <-> Closed)
  const handleToggleStatus = async (workshop) => {
    const idMurni = workshop._id || workshop.id; 

    const next = NEXT_STATUS[workshop.status];
    if (!next || !idMurni) {
      toast.error("Gagal mengubah status: ID data kosong atau tidak valid.");
      return;
    }

    setToggling(idMurni);
    try {
      await api.patch(`/workshops/${idMurni}/status`, { status: next });
      
      const label = next === 'open' ? 'dibuka' : 'ditutup';
      toast.success(`Pendaftaran workshop berhasil ${label}.`);   
      load();
    } catch (err) {
      const serverMessage = err.response?.data?.message || err.message;
      toast.error(`Gagal mengubah status: ${serverMessage}`);       
    } finally {
      setToggling(null);
    }
  };

  // Handler: Menyelesaikan Kegiatan Workshop secara Permanen (Dipicu dari ConfirmDialog)
  const handleFinishWorkshop = async () => {
    if (!confirmData) return;
    
    const idMurni = confirmData._id || confirmData.id;
    const title = confirmData.title;
    
    // Tutup dialog terlebih dahulu
    setConfirmData(null);

    if (!idMurni) {
      toast.error("Gagal menyelesaikan workshop: ID tidak valid.");
      return;
    }

    setToggling(idMurni);
    try {
      await api.patch(`/workshops/${idMurni}/status`, { status: 'finished' });
      toast.success(`Workshop "${title}" telah dinyatakan selesai!`);
      load();
    } catch (err) {
      const serverMessage = err.response?.data?.message || err.message;
      toast.error(`Gagal menyelesaikan workshop: ${serverMessage}`);
    } finally {
      setToggling(null);
    }
  };

  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="space-y-4 font-sans">
      {/* Render ConfirmDialog jika state confirmData terisi */}
      {confirmData && (
        <ConfirmDialog
          title="Selesaikan Kegiatan?"
          message={confirmData.title}
          description="Aksi ini akan mengunci agenda kegiatan secara permanen dan otomatis mengakumulasikan jam kerja sosial pada portfolio relawan."
          confirmLabel="Ya, Selesai"
          cancelLabel="Batal"
          danger={false} // Menggunakan ikon CheckCircle warna hijau/biru bawaan komponen Anda
          onConfirm={handleFinishWorkshop}
          onCancel={() => setConfirmData(null)}
        />
      )}

      {/* Top Action Bar */}
      <div className="flex justify-end">
        <button
          onClick={() => navigate('/fa/workshop-add')}
          className="bg-primary hover:bg-primary-hover text-white text-sm font-medium px-4 py-2 rounded-xl transition-colors shadow-sm"
        >
          + Buat Workshop
        </button>
      </div>

      {/* Grid Layout Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {loading
          ? [...Array(4)].map((_, i) => <SkeletonCard key={i} />)
          : workshops.map(w => {
              const currentId = w._id || w.id;
              
              return (
                <div key={currentId} className="bg-white rounded-2xl border border-muted shadow-sm p-5 flex flex-col gap-3 min-h-[240px]">
                  {/* Header Title & Badge */}
                  <div className="flex items-start justify-between gap-2">
                    <p className="font-semibold text-accent leading-snug flex-1">{w.title}</p>
                    <Badge value={w.status} />
                  </div>
                  
                  {/* Description */}
                  <p className="text-xs text-text-muted line-clamp-2">{w.description}</p>
                  
                  {/* Info Meta */}
                  <div className="space-y-1.5 text-xs text-text-muted">
                    <div className="flex items-center gap-1.5">
                      <CalendarDays size={12} />
                      {w.event_date ? new Date(w.event_date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' }) : '—'}
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Users size={12} />
                      {w.mentor_registered_count ?? 0} / {w.mentor_needed} mentor terdaftar
                    </div>
                  </div>
                  
                  {/* Progress Bar */}
                  <ProgressBar current={w.mentor_registered_count ?? 0} total={w.mentor_needed} />
                  
                  {/* Embedded Inline List Relawan Terdaftar */}
                  {w.registered_volunteers?.length > 0 && (
                    <div>
                      <p className="text-xs text-text-muted mb-1.5">Relawan ({w.registered_volunteers.length})</p>
                      <div className="flex flex-wrap gap-1">
                        {w.registered_volunteers.slice(0, 4).map((v, i) => (
                          <span key={i} className="text-xs bg-slate-100 text-accent px-2 py-0.5 rounded-full border border-slate-200/40">
                            {v.user_name || (v.user_id ? `${v.user_id.slice(0, 6)}…` : 'Anonim')}
                          </span>
                        ))}
                        {w.registered_volunteers.length > 4 && (
                          <span className="text-xs text-text-muted self-center ml-1">+{w.registered_volunteers.length - 4} lainnya</span>
                        )}
                      </div>
                    </div>
                  )}

                  {/* Dinamis Footer Action Group Berdasarkan Status */}
                  {w.status !== 'finished' ? (
                    <div className="flex items-center justify-between pt-2 mt-auto border-t border-muted">
                      {/* Tombol Toggle Buka/Tutup Pendaftaran */}
                      <button
                        type="button"
                        onClick={() => handleToggleStatus(w)}
                        disabled={toggling === currentId}
                        className="flex items-center gap-1.5 text-xs text-text-muted hover:text-primary font-medium transition-colors disabled:opacity-50"
                      >
                        {w.status === 'open' ? (
                          <><ToggleRight size={14} className="text-primary" /> Tutup Pendaftaran</>
                        ) : (
                          <><ToggleLeft size={14} /> Buka Pendaftaran</>
                        )}
                      </button>

                      {/* Tombol Selesaikan Kegiatan (Hanya Aktif saat Status 'closed') */}
                      {w.status === 'closed' && (
                        <button
                          type="button"
                          onClick={() => setConfirmData(w)} // ← SET DATA OBJECT WORKSHOP KE STATE DIALOG
                          disabled={toggling === currentId}
                          className="bg-emerald-50 text-emerald-600 hover:bg-emerald-100 text-xs font-semibold px-2.5 py-1.5 rounded-lg transition-colors disabled:opacity-50 border border-emerald-200/50 flex items-center gap-1"
                        >
                          <CheckCircle size={12} /> Selesaikan Kegiatan
                        </button>
                      )}
                    </div>
                  ) : (
                    <div className="pt-2 mt-auto border-t border-muted flex justify-center">
                      <span className="text-[11px] font-medium bg-slate-50 text-slate-400 px-3 py-1 rounded-full border border-slate-100 flex items-center gap-1">
                        <CheckCircle size={11} className="text-slate-400" /> Siklus Kegiatan Selesai
                      </span>
                    </div>
                  )}
                </div>
              );
            })
        }
      </div>
    </div>
  );
}