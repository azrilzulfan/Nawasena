// src/components/ui/Toast.jsx
import { useEffect, useState } from 'react';
import { CheckCircle, XCircle, AlertCircle, Info, X } from 'lucide-react';

const ICONS = {
  success: CheckCircle,
  error:   XCircle,
  warning: AlertCircle,
  info:    Info,
};

const STYLES = {
  success: 'bg-emerald-50 border-emerald-200 text-emerald-800',
  error:   'bg-rose-50    border-rose-200    text-rose-800',
  warning: 'bg-amber-50   border-amber-200   text-amber-800',
  info:    'bg-blue-50    border-blue-200    text-blue-800',
};

const ICON_STYLES = {
  success: 'text-emerald-500',
  error:   'text-rose-500',
  warning: 'text-amber-500',
  info:    'text-blue-500',
};

function ToastItem({ id, type = 'info', message, onDismiss }) {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const enterTimer = setTimeout(() => setVisible(true), 10);
    const exitTimer = setTimeout(() => {
      setVisible(false);
      setTimeout(() => onDismiss(id), 300);
    }, 4000);
    return () => { clearTimeout(enterTimer); clearTimeout(exitTimer); };
  }, [id, onDismiss]);

  const Icon = ICONS[type] ?? Info;

  return (
    <div
      className={`
        flex items-start gap-3 px-4 py-3.5 rounded-2xl border shadow-lg w-80 max-w-full
        transform transition-all duration-300 ease-out
        ${STYLES[type]}
        ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'}
      `}
    >
      <Icon size={16} className={`shrink-0 mt-0.5 ${ICON_STYLES[type]}`} />
      <p className="text-sm font-medium flex-1 leading-snug">{message}</p>
      <button
        onClick={() => {
          setVisible(false);
          setTimeout(() => onDismiss(id), 300);
        }}
        className="shrink-0 opacity-50 hover:opacity-100 transition-opacity"
      >
        <X size={14} />
      </button>
    </div>
  );
}

export function ToastContainer({ toasts, onDismiss }) {
  return (
    <div className="fixed bottom-6 right-6 z-100 flex flex-col gap-2 items-end">
      {toasts.map(t => (
        <ToastItem key={t.id} {...t} onDismiss={onDismiss} />
      ))}
    </div>
  );
}