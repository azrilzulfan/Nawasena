// src/components/layout/Topbar.jsx
import { Menu, Bell } from 'lucide-react';
import { useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const PAGE_TITLES = {
  '/admin':                     'Pusat Analitik',
  '/admin/foundation-queue':    'Antrean Verifikasi Panti',
  '/admin/foundation-list':     'Daftar Panti',
  '/admin/foundation-analytics':'Statistik Panti',
  '/admin/donors':              'Data Donatur',
  '/admin/volunteers':          'Data Relawan',
  '/admin/foundation-admins':   'Data Pengelola Panti',
  '/admin/inventories':         'Pantauan Kebutuhan Nasional',
  '/admin/donations':           'Laporan Riwayat Donasi',
  '/admin/workshops':           'Manajemen Kegiatan',
  '/admin/profile':             'Profil Admin',
};

export default function Topbar({ onMenuToggle }) {
  const { user } = useAuth();
  const { pathname } = useLocation();
  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'SA';

  return (
    <header className="sticky top-0 z-20 bg-white/80 backdrop-blur-sm border-b border-muted px-4 py-3 flex items-center gap-3">
      <button onClick={onMenuToggle} className="lg:hidden p-2 rounded-lg text-text-muted hover:bg-slate-100">
        <Menu size={20} />
      </button>
      <div className="flex-1">
        <h1 className="text-base font-bold text-accent">
          {PAGE_TITLES[pathname] ?? 'Dashboard'}
        </h1>
      </div>
      <div className="flex items-center gap-2.5">
        <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold">
          {initials}
        </div>
        <div className="hidden md:block">
          <p className="text-xs font-semibold text-accent leading-tight">{user?.full_name}</p>
          <p className="text-xs text-text-muted capitalize">{user?.role}</p>
        </div>
      </div>
    </header>
  );
}