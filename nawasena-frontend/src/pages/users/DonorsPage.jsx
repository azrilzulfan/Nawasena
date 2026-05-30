// src/pages/users/DonorsPage.jsx
import { useFetch } from '../../hooks/useFetch';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';

export default function DonorsPage() {
  const { data, loading, error, refetch } = useFetch('/users?role=donor');
  const donors = data?.data ?? [];

  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
      <div className="px-5 py-4 border-b border-slate-100">
        <p className="font-semibold text-slate-800">
          Data Donatur
          {!loading && <span className="text-slate-400 font-normal text-sm ml-1">({data?.total ?? donors.length})</span>}
        </p>
      </div>
      {error ? (
        <ErrorState message={error} onRetry={refetch} />
      ) : (
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
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
                  <td className="px-5 py-3.5 font-medium text-slate-800">{u.full_name}</td>
                  <td className="px-5 py-3.5 text-slate-500">{u.email}</td>
                  <td className="px-5 py-3.5 text-slate-400 text-xs hidden md:table-cell">
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