// src/features/users/pages/DonorsPage.jsx
import { useFetch } from '../../../hooks/useFetch';
import ErrorState from '../../../components/ui/ErrorState';
import { SkeletonRow } from '../../../components/ui/Skeleton';

export default function DonorsPage() {
  const { data, loading, error, refetch } = useFetch('/users?role=donor');
  const donors = data?.data ?? [];

  return (
    <div className="bg-white rounded-2xl border border-muted shadow-sm overflow-hidden font-sans">
      <div className="px-5 py-4 border-b border-muted">
        <p className="font-semibold text-accent">
          Data Donatur
          {!loading && <span className="text-text-muted font-normal text-sm ml-1">({data?.total ?? donors.length})</span>}
        </p>
      </div>
      {error ? (
        <ErrorState message={error} onRetry={refetch} />
      ) : (
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-xs text-text-muted uppercase tracking-wide">
            <tr>
              <th className="text-left px-5 py-3">Nama</th>
              <th className="text-left px-5 py-3">Email</th>
              <th className="text-left px-5 py-3 hidden md:table-cell">Bergabung</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-50">
            {loading
              ? [...Array(5)].map((_, i) => <SkeletonRow key={i} cols={3} />)
              : donors.map(u => (
                <tr key={u._id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-5 py-3.5 font-medium text-accent">{u.full_name}</td>
                  <td className="px-5 py-3.5 text-text-muted">{u.email}</td>
                  <td className="px-5 py-3.5 text-text-muted text-xs hidden md:table-cell">
                    {new Date(u.created_at).toLocaleDateString('id-ID')}
                  </td>
                </tr>
              ))
            }
          </tbody>
        </table>
      )}
    </div>
  );
}