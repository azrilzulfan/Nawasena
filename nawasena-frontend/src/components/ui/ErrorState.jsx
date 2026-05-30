// src/components/ui/ErrorState.jsx
import { AlertCircle } from 'lucide-react';

export default function ErrorState({ message, onRetry }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-slate-400">
      <AlertCircle size={32} className="mb-3 text-rose-400" />
      <p className="text-sm font-medium text-slate-500">{message ?? 'Gagal memuat data'}</p>
      {onRetry && (
        <button
          onClick={onRetry}
          className="mt-4 text-xs text-emerald-600 hover:text-emerald-800 font-medium"
        >
          Coba lagi
        </button>
      )}
    </div>
  );
}