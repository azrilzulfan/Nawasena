// src/pages/foundation-admin/FAWorkshopsPage.jsx
import { useState, useEffect, useCallback } from 'react';
import { CalendarDays, Users, Pencil, ToggleLeft, ToggleRight } from 'lucide-react';
import Badge from '../../components/ui/Badge';
import ProgressBar from '../../components/ui/ProgressBar';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonCard } from '../../components/ui/Skeleton';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';

const NEXT_STATUS = { open: 'closed', closed: 'open' };

export default function FAWorkshopsPage({ onNavigate, onEditWorkshop }) {
  const { myFoundationId } = useAuth();
  const [workshops, setWorkshops] = useState([]);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);
  const [toggling,  setToggling]  = useState(null);

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

  const handleToggleStatus = async (workshop) => {
    const next = NEXT_STATUS[workshop.status];
    if (!next) return;
    setToggling(workshop._id);
    try {
      await api.patch(`/workshops/${workshop._id}/status`, { status: next });
      load();
    } catch (err) {
      alert(err.message);
    } finally {
      setToggling(null);
    }
  };

  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <button
          onClick={() => onNavigate('fa-workshop-add')}
          className="bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium px-4 py-2 rounded-xl transition-colors"
        >
          + Buat Workshop
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {loading
          ? [...Array(4)].map((_, i) => <SkeletonCard key={i} />)
          : workshops.map(w => (
            <div key={w._id} className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5 flex flex-col gap-3">
              <div className="flex items-start justify-between gap-2">
                <p className="font-semibold text-slate-800 leading-snug flex-1">{w.title}</p>
                <Badge value={w.status} />
              </div>

              <p className="text-xs text-slate-500 line-clamp-2">{w.description}</p>

              <div className="space-y-1.5 text-xs text-slate-500">
                <div className="flex items-center gap-1.5">
                  <CalendarDays size={12} />
                  {new Date(w.event_date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}
                </div>
                <div className="flex items-center gap-1.5">
                  <Users size={12} />
                  {w.mentor_registered_count} / {w.mentor_needed} mentor terdaftar
                </div>
              </div>

              <ProgressBar current={w.mentor_registered_count} total={w.mentor_needed} />

              {w.registered_volunteers?.length > 0 && (
                <div>
                  <p className="text-xs text-slate-400 mb-1.5">Relawan ({w.registered_volunteers.length})</p>
                  <div className="flex flex-wrap gap-1">
                    {w.registered_volunteers.slice(0, 4).map((v, i) => (
                      <span key={i} className="text-xs bg-slate-100 text-slate-600 px-2 py-0.5 rounded-full">
                        {v.user_id.slice(0, 8)}...
                      </span>
                    ))}
                    {w.registered_volunteers.length > 4 && (
                      <span className="text-xs text-slate-400">+{w.registered_volunteers.length - 4} lainnya</span>
                    )}
                  </div>
                </div>
              )}

              {w.status !== 'finished' && (
                <div className="flex gap-2 pt-1 border-t border-slate-50">
                  <button
                    onClick={() => handleToggleStatus(w)}
                    disabled={toggling === w._id}
                    className="flex items-center gap-1.5 text-xs text-slate-500 hover:text-blue-600 font-medium transition-colors disabled:opacity-50"
                  >
                    {w.status === 'open'
                      ? <><ToggleRight size={14} className="text-emerald-500" />Tutup Pendaftaran</>
                      : <><ToggleLeft size={14} />Buka Pendaftaran</>
                    }
                  </button>
                </div>
              )}
            </div>
          ))
        }
      </div>
    </div>
  );
}