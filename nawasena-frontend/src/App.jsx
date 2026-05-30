// src/App.jsx
import { useState } from 'react';
import { useAuth } from './context/AuthContext';

import LoginPage    from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';

import SuperAdminLayout       from './layouts/SuperAdminLayout';       
import FoundationAdminLayout  from './layouts/FoundationAdminLayout';

function AuthGate() {
  const [showRegister, setShowRegister] = useState(false);
  return showRegister
    ? <RegisterPage onGoLogin={() => setShowRegister(false)} />
    : <LoginPage onGoRegister={() => setShowRegister(true)} />;
}

export default function App() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="flex items-center gap-3 text-slate-400">
          <div className="w-5 h-5 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin" />
          <span className="text-sm">Memuat sesi...</span>
        </div>
      </div>
    );
  }

  if (!user) return <AuthGate />;

  switch (user.role) {
    case 'admin':
      return <SuperAdminLayout />;
    case 'foundation_admin':
      return <FoundationAdminLayout />;
    default:
      return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center px-4">
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8 max-w-sm text-center">
            <p className="font-semibold text-slate-800 mb-2">Akses Terbatas</p>
            <p className="text-sm text-slate-400 mb-5">
              Akun dengan role <strong>{user.role}</strong> tidak memiliki akses ke dashboard ini.
            </p>
            <button
              onClick={() => { localStorage.removeItem('nawasena_token'); window.location.reload(); }}
              className="text-sm text-rose-500 hover:text-rose-700 font-medium"
            >
              Keluar
            </button>
          </div>
        </div>
      );
  }
}