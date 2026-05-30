// src/pages/users/FoundationAdminsPage.jsx
import { useFetch } from '../../hooks/useFetch';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';

export default function FoundationAdminsPage() {
  const { data: uData, loading: uLoading, error: uError, refetch } = useFetch('/users?role=foundation_admin');
  const { data: fData } = useFetch('/foundations?is_verified=1');

  const admins      = uData?.data ?? [];
  const foundations = fData?.data ?? [];

  const foundationName = (id) => foundations.find(f => f.id === id)?.name ?? '—';

  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
      <div className="px-5 py-4 border-b border-slate-100">
        <p className="font-semibold text-slate-800">
          Pengelola Panti
          {!uLoading && <span className="text-slate-400 font-normal text-sm ml-1">({uData?.total ?? admins.length})</span>}
        </p>
      </div>
      {uError ? (
        <ErrorState message={uError} onRetry={refetch} />
      ) : (
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
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
                <tr key={u.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-5 py-3.5 font-medium text-slate-800">{u.full_name}</td>
                  <td className="px-5 py-3.5 text-slate-500">{u.email}</td>
                  <td className="px-5 py-3.5 text-slate-600 hidden md:table-cell">
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