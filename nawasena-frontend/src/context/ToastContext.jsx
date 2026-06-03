// src/context/ToastContext.jsx
import { createContext, useContext, useState, useCallback } from 'react';
import { ToastContainer } from '../components/ui/Toast';

const ToastContext = createContext(null);

let _idCounter = 0;

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);

  const dismiss = useCallback((id) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  }, []);

  const toast = useCallback((type, message) => {
    const id = ++_idCounter;
    setToasts(prev => [...prev, { id, type, message }]);
  }, []);

  const success = useCallback((msg) => toast('success', msg), [toast]);
  const error   = useCallback((msg) => toast('error',   msg), [toast]);
  const warning = useCallback((msg) => toast('warning', msg), [toast]);
  const info    = useCallback((msg) => toast('info',    msg), [toast]);

  return (
    <ToastContext.Provider value={{ toast, success, error, warning, info }}>
      {children}
      <ToastContainer toasts={toasts} onDismiss={dismiss} />
    </ToastContext.Provider>
  );
}

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast must be used inside ToastProvider');
  return ctx;
}