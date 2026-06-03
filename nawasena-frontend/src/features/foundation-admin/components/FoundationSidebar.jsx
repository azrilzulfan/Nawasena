// src/features/foundation-admin/components/FoundationSidebar.jsx
import { useState } from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard, Boxes, BookOpen, CalendarCheck,
  UserCircle, LogOut, X, ChevronDown, PlusCircle,
  QrCode,
} from 'lucide-react';
import { useAuth } from '../../../context/AuthContext';
import ConfirmDialog from '../../../components/ui/ConfirmDialog';
import logoNawasena from '../../../assets/Logo.png'

const NAV_ITEMS = [
  {
    label: 'Beranda',
    children: [
      { to: '/fa', label: 'Dasbor Saya', icon: LayoutDashboard },
    ],
  },
  {
    label: 'Inventori',
    children: [
      { to: '/fa/inventories',    label: 'Daftar Kebutuhan',  icon: Boxes },
      { to: '/fa/inventory-add',  label: 'Tambah Kebutuhan',  icon: PlusCircle },
    ],
  },
  {
    label: 'Donasi',
    children: [
      { to: '/fa/donations', label: 'Donasi Masuk', icon: BookOpen },
      { to: '/fa/qr-scan',   label: 'Scan QR Donasi', icon: QrCode },
    ],
  },
  {
    label: 'Workshop',
    children: [
      { to: '/fa/workshops',    label: 'Daftar Workshop',  icon: CalendarCheck },
      { to: '/fa/workshop-add', label: 'Buat Workshop',    icon: PlusCircle },
    ],
  },
  {
    label: 'Akun',
    children: [
      { to: '/fa/profile', label: 'Profil Saya', icon: UserCircle },
    ],
  },
];

function NavGroup({ group, onClose }) {
  const [open, setOpen] = useState(true);
  return (
    <div className="mb-1">
      <button
        onClick={() => setOpen(o => !o)}
        className="flex items-center justify-between w-full px-3 py-1.5 text-xs font-semibold text-text-muted uppercase tracking-wider hover:text-accent"
      >
        {group.label}
        <ChevronDown size={13} className={`transition-transform ${open ? '' : '-rotate-90'}`} />
      </button>
      {open && group.children.map(item => {
        const Icon = item.icon;
        return (
          <NavLink
            key={item.to}
            to={item.to}
            end
            onClick={onClose}
            className={({ isActive }) =>
              `flex items-center gap-3 w-full px-3 py-2.5 rounded-xl text-sm font-medium transition-all mb-0.5 ${
                isActive
                  ? 'bg-secondary/10 text-primary shadow-sm'
                  : 'text-accent hover:bg-slate-50 hover:text-accent-hover'
              }`
            }
          >
            {({ isActive }) => (
              <>
                <Icon size={16} className={isActive ? 'text-primary' : 'text-text-muted'} />
                {item.label}
              </>
            )}
          </NavLink>
        );
      })}
    </div>
  );
}

export default function FoundationSidebar({ isOpen, onClose, foundationName }) {
  const { user, logout } = useAuth();
  const [logoutConfirm, setLogoutConfirm] = useState(false);

  const handleLogoutConfirm = async () => {
    setLogoutConfirm(false);
    await logout();
  };

  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'FA';

  return (
    <>
      {logoutConfirm && (
        <ConfirmDialog
          title="Keluar dari Sistem?"
          message="Sesi Anda akan diakhiri dan Anda perlu login kembali."
          confirmLabel="Ya, Keluar"
          danger
          onConfirm={handleLogoutConfirm}
          onCancel={() => setLogoutConfirm(false)}
        />
      )}
      {isOpen && (
        <div className="fixed inset-0 bg-black/40 z-30 lg:hidden" onClick={onClose} />
      )}
      <aside className={`
        fixed top-0 left-0 h-full w-64 bg-white border-r border-muted z-40 flex flex-col
        transform transition-transform duration-300 ease-in-out
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        lg:translate-x-0 lg:static lg:z-auto
      `}>
        <div className="flex items-center justify-between px-5 py-5 border-b border-muted">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-8 h-8 flex items-center justify-center">
              <img src={logoNawasena} alt="Nawasena" />
            </div>
            <div className="min-w-0">
              <p className="font-bold text-accent text-sm leading-tight">Nawasena</p>
              <p className="text-xs text-text-muted truncate">{foundationName ?? 'Pengelola Panti'}</p>
            </div>
          </div>
          <button onClick={onClose} className="lg:hidden text-text-muted hover:text-accent shrink-0">
            <X size={18} />
          </button>
        </div>

        <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
          {NAV_ITEMS.map(group => (
            <NavGroup
              key={group.label}
              group={group}
              onClose={onClose}
            />
          ))}
        </nav>

        <div className="px-3 py-4 border-t border-muted space-y-1">
          <button
            onClick={() => setLogoutConfirm(true)}
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