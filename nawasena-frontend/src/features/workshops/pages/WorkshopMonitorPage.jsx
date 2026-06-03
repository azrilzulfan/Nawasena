// src/features/workshops/pages/WorkshopMonitorPage.jsx
import { CalendarDays, MapPin } from 'lucide-react';
import Badge from '../../../components/ui/Badge';
import ProgressBar from '../../../components/ui/ProgressBar';
import ErrorState from '../../../components/ui/ErrorState';
import { SkeletonCard } from '../../../components/ui/Skeleton';
import { useFetch } from '../../../hooks/useFetch';

export default function WorkshopMonitorPage() {
  const { data, loading, error, refetch } = useFetch('/workshops');
  const workshops = data?.data ?? data ?? [];

  if (error) return <ErrorState message={error} onRetry={refetch} />;

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 font-sans">
      {loading
        ? [...Array(6)].map((_, i) => <SkeletonCard key={i} />)
        : workshops.map(w => (
          <div key={w._id} className="bg-white rounded-2xl border border-muted shadow-sm p-5 flex flex-col gap-3">
            <div className="flex items-start justify-between gap-2">
              <p className="font-semibold text-accent leading-snug flex-1">{w.title}</p>
              <Badge value={w.status} />
            </div>

            <p className="text-xs text-text-muted line-clamp-2">{w.description}</p>

            <div className="space-y-1.5 text-xs text-text-muted">
              <div className="flex items-center gap-1.5">
                <CalendarDays size={12} />
                {new Date(w.event_date).toLocaleDateString('id-ID', {
                  day: 'numeric', month: 'long', year: 'numeric',
                })}
              </div>
              {w.location?.coordinates && (
                <div className="flex items-center gap-1.5">
                  <MapPin size={12} />
                  {w.location.coordinates[1].toFixed(4)}, {w.location.coordinates[0].toFixed(4)}
                </div>
              )}
            </div>

            <div>
              <p className="text-xs text-text-muted mb-1.5 font-medium">Kuota Mentor</p>
              <ProgressBar current={w.mentor_registered_count} total={w.mentor_needed} />
            </div>
          </div>
        ))
      }
    </div>
  );
}