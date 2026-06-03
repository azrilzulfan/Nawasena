// src/features/foundation-admin/components/VerificationBanner.jsx
import { AlertCircle } from 'lucide-react';
import { useAuth } from '../../../context/AuthContext';

export default function VerificationBanner() {
  const { user, foundation, isVerified } = useAuth();

  if (user?.role !== 'foundation_admin' || isVerified) return null;

  return (
    <div className="bg-amber-50 border-b border-amber-200 px-4 py-3 animate-pulse">
      <div className="flex items-center gap-3 max-w-7xl mx-auto">
        <span className="flex p-2 rounded-lg bg-amber-600 text-white shrink-0">
          <AlertCircle size={18} />
        </span>
        <div className="flex-1">
          <p className="font-medium text-amber-800 text-sm leading-tight">
            Akun Yayasan <strong>{foundation?.name || 'Panti Anda'}</strong> Sedang Menunggu Verifikasi
          </p>
          <span className="block text-xs text-amber-600 mt-0.5">
            Fitur penarikan donasi, pembuatan workshop, dan manipulasi inventaris dinonaktifkan hingga Super Admin menyetujui dokumen legalitas Anda.
          </span>
        </div>
      </div>
    </div>
  );
}