// src/pages/users/VolunteersPage.jsx
import { useState } from 'react';
import { ExternalLink, X } from 'lucide-react';
import { useFetch } from '../../hooks/useFetch';
import { api } from '../../lib/api';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';

function PortfolioModal({ userId, onClose }) {
  const { data, loading, error } = useFetch(`/users/${userId}/portfolio`);

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-6">
        <div className="flex items-center justify-between mb-5">
          <p className="font-semibold text-slate-800">Portfolio Relawan</p>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600">
            <X size={18} />
          </button>
        </div>

        {loading && <div className="h-20 bg-slate-50 rounded-xl animate-pulse" />}
        {error   && <p className="text-sm text-rose-500">{error}</p>}
        {data && (
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-emerald-50 rounded-xl p-4 text-center">
                <p className="text-2xl font-bold text-emerald-700">{data.volunteer_hours ?? 0}</p>
                <p className="text-xs text-emerald-600 mt-1">Jam Relawan</p>
              </div>
              <div className="bg-blue-50 rounded-xl p-4 text-center">
                <p className="text-2xl font-bold text-blue-700">{data.workshops_attended ?? 0}</p>
                <p className="text-xs text-blue-600 mt-1">Workshop Diikuti</p>
              </div>
            </div>
            {data.skills?.length > 0 && (
              <div>
                <p className="text-xs font-medium text-slate-500 mb-2">Skills</p>
                <div className="flex flex-wrap gap-1.5">
                  {data.skills.map(s => (
                    <span key={s} className="bg-slate-100 text-slate-600 text-xs px-2.5 py-1 rounded-full">{s}</span>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default function VolunteersPage() {
  const { data, loading, error, refetch } = useFetch('/users?role=volunteer');
  const volunteers = data?.data ?? [];
  const [portfolioId, setPortfolioId] = useState(null);

  return (
    <>
      {portfolioId && (
        <PortfolioModal userId={portfolioId} onClose={() => setPortfolioId(null)} />
      )}

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100">
          <p className="font-semibold text-slate-800">
            Data Relawan
            {!loading && <span className="text-slate-400 font-normal text-sm ml-1">({data?.total ?? volunteers.length})</span>}
          </p>
        </div>
        {error ? (
          <ErrorState message={error} onRetry={refetch} />
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
              <tr>
                <th className="text-left px-5 py-3">Nama</th>
                <th className="text-left px-5 py-3 hidden md:table-cell">Skills</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Jam</th>
                <th className="text-left px-5 py-3 hidden lg:table-cell">Workshop</th>
                <th className="text-left px-5 py-3">Portfolio</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {loading
                ? [...Array(4)].map((_, i) => <SkeletonRow key={i} cols={5} />)
                : volunteers.map(u => (
                  <tr key={u._id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-3.5">
                      <p className="font-medium text-slate-800">{u.full_name}</p>
                      <p className="text-xs text-slate-400">{u.email}</p>
                    </td>
                    <td className="px-5 py-3.5 hidden md:table-cell">
                      <div className="flex flex-wrap gap-1">
                        {u.volunteer_profile?.skills?.map(s => (
                          <span key={s} className="bg-blue-50 text-blue-600 text-xs px-2 py-0.5 rounded-full border border-blue-100">{s}</span>
                        ))}
                      </div>
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 hidden lg:table-cell">
                      {u.volunteer_profile?.volunteer_hours ?? 0} jam
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 hidden lg:table-cell">
                      {u.volunteer_profile?.workshops_attended ?? 0}x
                    </td>
                    <td className="px-5 py-3.5">
                      <button
                        onClick={() => setPortfolioId(u._id)}
                        className="flex items-center gap-1.5 text-xs text-emerald-600 hover:text-emerald-800 font-medium"
                      >
                        <ExternalLink size={13} /> Lihat
                      </button>
                    </td>
                  </tr>
                ))
              }
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}