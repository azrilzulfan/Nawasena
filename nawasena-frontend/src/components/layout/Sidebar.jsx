// src/components/layout/Sidebar.jsx
import { useState } from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard, Building2, CheckSquare, BarChart3, Users, Heart,
  HandHelping, Boxes, BookOpen, CalendarCheck, UserCircle, LogOut,
  X, ChevronDown,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import ConfirmDialog from '../ui/ConfirmDialog';
import logoNawasena from '../../assets/Logo.png'

const NAV_ITEMS = [
  {
    label: 'Beranda',
    children: [
      { to: '/admin', label: 'Pusat Analitik', icon: LayoutDashboard },
    ],
  },
  {
    label: 'Panti Asuhan',
    children: [
      { to: '/admin/foundation-queue',     label: 'Antrean Verifikasi', icon: CheckSquare },
      { to: '/admin/foundation-list',      label: 'Daftar Panti',       icon: Building2 },
      { to: '/admin/foundation-analytics', label: 'Statistik Panti',    icon: BarChart3 },
    ],
  },
  {
    label: 'Pengguna',
    children: [
      { to: '/admin/donors',            label: 'Data Donatur',   icon: Heart },
      { to: '/admin/volunteers',        label: 'Data Relawan',   icon: HandHelping },
      { to: '/admin/foundation-admins', label: 'Data Pengelola', icon: Users },
    ],
  },
  {
    label: 'Logistik & Transparansi',
    children: [
      { to: '/admin/inventories', label: 'Kebutuhan Nasional', icon: Boxes },
      { to: '/admin/donations',   label: 'Ledger Donasi',      icon: BookOpen },
    ],
  },
  {
    label: 'Aktivitas',
    children: [
      { to: '/admin/workshops', label: 'Pantau Workshop', icon: CalendarCheck },
    ],
  },
  {
    label: 'Pengaturan',
    children: [
      { to: '/admin/profile', label: 'Profil Admin', icon: UserCircle },
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

export default function Sidebar({ isOpen, onClose }) {
  const { user, logout } = useAuth();
  const [logoutConfirm, setLogoutConfirm] = useState(false);

  const handleLogoutConfirm = async () => {
    setLogoutConfirm(false);
    await logout();
  };

  const initials = user?.full_name?.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() ?? 'SA';

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
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 flex items-center justify-center">
              <img src={logoNawasena} alt="Nawasena" />
            </div>
            <div>
              <p className="font-bold text-accent text-sm leading-tight">Nawasena</p>
              <p className="text-xs text-text-muted capitalize">{user?.role ?? 'Admin'}</p>
            </div>
          </div>
          <button onClick={onClose} className="lg:hidden text-text-muted hover:text-accent">
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

        <div className="px-3 py-4 border-t border-muted">
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