// src/features/users/pages/FoundationAdminsPage.jsx
import { useFetch } from '../../../hooks/useFetch';
import ErrorState from '../../../components/ui/ErrorState';
import { SkeletonRow } from '../../../components/ui/Skeleton';

export default function FoundationAdminsPage() {
  const { data: uData, loading: uLoading, error: uError, refetch } = useFetch('/users?role=foundation_admin');
  const { data: fData } = useFetch('/foundations?is_verified=1');

  const admins      = uData?.data ?? [];
  const foundations = fData?.data ?? [];

  const foundationName = (id) => foundations.find(f => (f._id ?? f.id) === id)?.name ?? '—';

  return (
    <div className="bg-white rounded-2xl border border-muted shadow-sm overflow-hidden font-sans">
      <div className="px-5 py-4 border-b border-muted">
        <p className="font-semibold text-accent">
          Pengelola Panti
          {!uLoading && <span className="text-text-muted font-normal text-sm ml-1">({uData?.total ?? admins.length})</span>}
        </p>
      </div>
      {uError ? (
        <ErrorState message={uError} onRetry={refetch} />
      ) : (
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-xs text-text-muted uppercase tracking-wide">
            <tr>
              <th className="text-left px-5 py-3">Nama</th>
              <th className="text-left px-5 py-3">Email</th>
              <th className="text-left px-5 py-3 hidden md:table-cell">Mengelola Panti</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-50">
            {uLoading
              ? [...Array(4)].map((_, i) => <SkeletonRow key={i} cols={3} />)
              : admins.map(u => (
                <tr key={u._id ?? u.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-5 py-3.5 font-medium text-accent">{u.full_name}</td>
                  <td className="px-5 py-3.5 text-text-muted">{u.email}</td>
                  <td className="px-5 py-3.5 text-accent hidden md:table-cell">
                    {foundationName(u.managed_foundation_id)}
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