// src/components/ui/ConfirmDialog.jsx
import { AlertTriangle, Trash2, CheckCircle } from 'lucide-react';

export default function ConfirmDialog({
  title        = 'Konfirmasi',
  message,
  description,
  confirmLabel = 'Ya, Lanjutkan',
  cancelLabel  = 'Batal',
  danger       = false,
  onConfirm,
  onCancel,
}) {
  const Icon = danger ? Trash2 : CheckCircle;
  const iconBg    = danger ? 'bg-rose-100'    : 'bg-secondary/20';
  const iconColor = danger ? 'text-rose-600'  : 'text-primary';
  const btnColor  = danger
    ? 'bg-rose-600 hover:bg-rose-700'
    : 'bg-primary hover:bg-primary-hover';

  return (
    <div
      className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center px-4"
      onClick={onCancel} 
    >
      <div
        className="bg-white rounded-2xl shadow-xl w-full max-w-sm p-6"
        onClick={e => e.stopPropagation()}
      >
        <div className={`w-12 h-12 ${iconBg} rounded-full flex items-center justify-center mx-auto mb-4`}>
          <Icon size={22} className={iconColor} />
        </div>

        <p className="text-sm font-semibold text-accent text-center mb-1">{title}</p>
        {message && (
          <p className="text-sm text-accent text-center">{message}</p>
        )}
        {description && (
          <p className="text-xs text-text-muted text-center mt-1">{description}</p>
        )}

        <div className="flex gap-3 mt-6">
          <button
            onClick={onCancel}
            className="flex-1 border border-muted text-accent hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl transition-colors"
          >
            {cancelLabel}
          </button>
          <button
            onClick={onConfirm}
            className={`flex-1 text-white text-sm font-medium py-2.5 rounded-xl transition-colors ${btnColor}`}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}