// src/components/layout/Sidebar.jsx
import { useState } from 'react';
import {
  LayoutDashboard, Building2, CheckSquare, BarChart3, Users, Heart,
  HandHelping, Boxes, BookOpen, CalendarCheck, UserCircle, LogOut,
  X, ChevronDown,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const NAV_ITEMS = [
  {
    label: 'Beranda',
    children: [
      { key: 'overview', label: 'Pusat Analitik', icon: LayoutDashboard },
    ],
  },
  {
    label: 'Panti Asuhan',
    children: [
      { key: 'foundation-queue',     label: 'Antrean Verifikasi', icon: CheckSquare },
      { key: 'foundation-list',      label: 'Daftar Panti',       icon: Building2 },
      { key: 'foundation-analytics', label: 'Statistik Panti',    icon: BarChart3 },
    ],
  },
  {
    label: 'Pengguna',
    children: [
      { key: 'donors',            label: 'Data Donatur',    icon: Heart },
      { key: 'volunteers',        label: 'Data Relawan',    icon: HandHelping },
      { key: 'foundation-admins', label: 'Data Pengelola',  icon: Users },
    ],
  },
  {
    label: 'Logistik & Transparansi',
    children: [
      { key: 'inventories', label: 'Kebutuhan Nasional', icon: Boxes },
      { key: 'donations',   label: 'Ledger Donasi',      icon: BookOpen },
    ],
  },
  {
    label: 'Aktivitas',
    children: [
      { key: 'workshops', label: 'Pantau Workshop', icon: CalendarCheck },
    ],
  },
  {
    label: 'Pengaturan',
    children: [
      { key: 'profile', label: 'Profil Admin', icon: UserCircle },
    ],
  },
];

function NavGroup({ group, activePage, onNavigate }) {
  const [open, setOpen] = useState(true);
  return (
    <div className="mb-1">
      <button
        onClick={() => setOpen(o => !o)}
        className="flex items-center justify-between w-full px-3 py-1.5 text-xs font-semibold text-slate-400 uppercase tracking-wider hover:text-slate-600"
      >
        {group.label}
        <ChevronDown size={13} className={`transition-transform ${open ? '' : '-rotate-90'}`} />
      </button>
      {open && group.children.map(item => {
        const Icon = item.icon;
        const active = activePage === item.key;
        return (
          <button
            key={item.key}
            onClick={() => onNavigate(item.key)}
            className={`flex items-center gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium transition-all mb-0.5
              ${active
                ? 'bg-emerald-50 text-emerald-700 shadow-sm'
                : 'text-slate-600 hover:bg-slate-50 hover:text-slate-800'
              }`}
          >
            <Icon size={16} className={active ? 'text-emerald-600' : 'text-slate-400'} />
            {item.label}
          </button>
        );
      })}
    </div>
  );
}

export default function Sidebar({ activePage, onNavigate, isOpen, onClose }) {
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    if (confirm('Yakin ingin keluar dari sistem?')) {
      await logout();
    }
  };

  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'SA';

  return (
    <>
      {isOpen && (
        <div className="fixed inset-0 bg-black/40 z-30 lg:hidden" onClick={onClose} />
      )}
      <aside className={`
        fixed top-0 left-0 h-full w-64 bg-white border-r border-slate-100 z-40 flex flex-col
        transform transition-transform duration-300 ease-in-out
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        lg:translate-x-0 lg:static lg:z-auto
      `}>
        <div className="flex items-center justify-between px-5 py-5 border-b border-slate-100">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-emerald-600 flex items-center justify-center">
              <span className="text-white font-bold text-sm">N</span>
            </div>
            <div>
              <p className="font-bold text-slate-800 text-sm leading-tight">Nawasena</p>
              <p className="text-xs text-slate-400 capitalize">{user?.role ?? 'Admin'}</p>
            </div>
          </div>
          <button onClick={onClose} className="lg:hidden text-slate-400 hover:text-slate-600">
            <X size={18} />
          </button>
        </div>

        <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
          {NAV_ITEMS.map(group => (
            <NavGroup
              key={group.label}
              group={group}
              activePage={activePage}
              onNavigate={(key) => { onNavigate(key); onClose(); }}
            />
          ))}
        </nav>

        <div className="px-3 py-4 border-t border-slate-100">
          <button
            onClick={handleLogout}
            className="flex items-center gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium text-rose-500 hover:bg-rose-50 transition-all"
          >
            <LogOut size={16} />
            Keluar Sistem
          </button>
        </div>
      </aside>
    </>
  );
}