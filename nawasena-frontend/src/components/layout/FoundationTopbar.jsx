// src/components/layout/FoundationTopbar.jsx
import { Menu, Bell } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const PAGE_TITLES = {
  'fa-overview':      'Dasbor Saya',
  'fa-inventories':   'Daftar Kebutuhan',
  'fa-inventory-add': 'Tambah Kebutuhan',
  'fa-donations':     'Donasi Masuk',
  'fa-workshops':     'Daftar Workshop',
  'fa-workshop-add':  'Buat Workshop',
  'fa-profile':       'Profil Saya',
};

export default function FoundationTopbar({ activePage, onMenuToggle }) {
  const { user } = useAuth();
  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'FA';

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
        <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center text-white text-xs font-bold">
          {initials}
        </div>
        <div className="hidden md:block">
          <p className="text-xs font-semibold text-slate-700 leading-tight">{user?.full_name}</p>
          <p className="text-xs text-slate-400">Pengelola Panti</p>
        </div>
      </div>
    </header>
  );
}