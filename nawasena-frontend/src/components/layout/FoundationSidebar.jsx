// src/components/layout/FoundationSidebar.jsx
import { useState } from 'react';
import {
  LayoutDashboard, Boxes, BookOpen, CalendarCheck,
  UserCircle, LogOut, X, ChevronDown, PlusCircle,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const NAV_ITEMS = [
  {
    label: 'Beranda',
    children: [
      { key: 'fa-overview', label: 'Dasbor Saya', icon: LayoutDashboard },
    ],
  },
  {
    label: 'Inventori',
    children: [
      { key: 'fa-inventories',    label: 'Daftar Kebutuhan',  icon: Boxes },
      { key: 'fa-inventory-add',  label: 'Tambah Kebutuhan',  icon: PlusCircle },
    ],
  },
  {
    label: 'Donasi',
    children: [
      { key: 'fa-donations', label: 'Donasi Masuk', icon: BookOpen },
    ],
  },
  {
    label: 'Workshop',
    children: [
      { key: 'fa-workshops',    label: 'Daftar Workshop',  icon: CalendarCheck },
      { key: 'fa-workshop-add', label: 'Buat Workshop',    icon: PlusCircle },
    ],
  },
  {
    label: 'Akun',
    children: [
      { key: 'fa-profile', label: 'Profil Saya', icon: UserCircle },
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
                ? 'bg-blue-50 text-blue-700 shadow-sm'
                : 'text-slate-600 hover:bg-slate-50 hover:text-slate-800'
              }`}
          >
            <Icon size={16} className={active ? 'text-blue-600' : 'text-slate-400'} />
            {item.label}
          </button>
        );
      })}
    </div>
  );
}

export default function FoundationSidebar({ activePage, onNavigate, isOpen, onClose, foundationName }) {
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    if (confirm('Yakin ingin keluar?')) await logout();
  };

  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'FA';

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
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center shrink-0">
              <span className="text-white font-bold text-sm">N</span>
            </div>
            <div className="min-w-0">
              <p className="font-bold text-slate-800 text-sm leading-tight">Nawasena</p>
              <p className="text-xs text-slate-400 truncate">{foundationName ?? 'Pengelola Panti'}</p>
            </div>
          </div>
          <button onClick={onClose} className="lg:hidden text-slate-400 hover:text-slate-600 shrink-0">
            <X size={18} />
          </button>
        </div>

        {/* Nav */}
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

        <div className="px-3 py-4 border-t border-slate-100 space-y-1">
          <div className="flex items-center gap-2.5 px-3 py-2 mb-1">
            <div className="w-7 h-7 rounded-full bg-blue-600 flex items-center justify-center text-white text-xs font-bold shrink-0">
              {initials}
            </div>
            <div className="min-w-0">
              <p className="text-xs font-semibold text-slate-700 truncate">{user?.full_name}</p>
              <p className="text-xs text-slate-400 truncate">{user?.email}</p>
            </div>
          </div>
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