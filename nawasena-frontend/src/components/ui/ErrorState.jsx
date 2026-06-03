// src/components/ui/ErrorState.jsx
import { AlertCircle } from 'lucide-react';

export default function ErrorState({ message, onRetry }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-text-muted">
      <AlertCircle size={32} className="mb-3 text-rose-400" />
      <p className="text-sm font-medium text-text-muted">{message ?? 'Gagal memuat data'}</p>
      {onRetry && (
        <button
          onClick={onRetry}
          className="mt-4 text-xs text-primary hover:text-primary-hover font-medium"
        >
          Coba lagi
        </button>
      )}
    </div>
  );
}