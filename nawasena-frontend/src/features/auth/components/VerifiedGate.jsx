// src/features/auth/components/VerifiedGate.jsx
import { Lock } from 'lucide-react';
import { useAuth } from '../../../context/AuthContext';

export default function VerifiedGate({ children, showLockedOverlay = false }) {
  const { user, isVerified } = useAuth();

  if (user?.role !== 'foundation_admin' || isVerified) return children;

  if (showLockedOverlay) {
    return (
      <div className="relative">
        <div className="blur-[1px] opacity-40 pointer-events-none select-none">{children}</div>
        <div className="absolute inset-0 bg-slate-50/20 backdrop-blur-[0.5px] rounded-2xl flex flex-col items-center justify-center text-center p-4">
          <div className="w-9 h-9 rounded-full bg-muted flex items-center justify-center text-text-muted mb-1.5 shadow-sm">
            <Lock size={15} />
          </div>
          <p className="text-xs font-semibold text-accent">Fitur Terkunci</p>
          <p className="text-[10px] text-text-muted">Menunggu panti diverifikasi</p>
        </div>
      </div>
    );
  }

  return null;
}