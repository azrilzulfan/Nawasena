// src/components/layout/Topbar.jsx
import { Menu, Bell } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const PAGE_TITLES = {
  overview:              'Pusat Analitik',
  'foundation-queue':    'Antrean Verifikasi Panti',
  'foundation-list':     'Daftar Panti',
  'foundation-analytics':'Statistik Panti',
  donors:                'Data Donatur',
  volunteers:            'Data Relawan',
  'foundation-admins':   'Data Pengelola Panti',
  inventories:           'Pantauan Kebutuhan Nasional',
  donations:             'Laporan Riwayat Donasi',
  workshops:             'Manajemen Kegiatan',
  profile:               'Profil Admin',
};

export default function Topbar({ activePage, onMenuToggle }) {
  const { user } = useAuth();
  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'SA';

  return (
    <header className="sticky top-0 z-20 bg-white/80 backdrop-blur-sm border-b border-slate-100 px-4 py-3 flex items-center gap-3">
      <button onClick={onMenuToggle} className="lg:hidden p-2 rounded-lg text-slate-500 hover:bg-slate-100">
        <Menu size={20} />
      </button>
      <div className="flex-1">
        <h1 className="text-base font-bold text-slate-800">
          {PAGE_TITLES[activePage] ?? 'Dashboard'}
        </h1>
      </div>
      <button className="relative p-2 rounded-xl text-slate-500 hover:bg-slate-100">
        <Bell size={18} />
        <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-rose-500 rounded-full" />
      </button>
      <div className="flex items-center gap-2.5">
        <div className="w-8 h-8 rounded-full bg-emerald-600 flex items-center justify-center text-white text-xs font-bold">
          {initials}
        </div>
        <div className="hidden md:block">
          <p className="text-xs font-semibold text-slate-700 leading-tight">{user?.full_name}</p>
          <p className="text-xs text-slate-400 capitalize">{user?.role}</p>
        </div>
      </div>
    </header>
  );
}