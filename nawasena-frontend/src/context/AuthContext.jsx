// src/context/AuthContext.jsx
import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { api } from '../lib/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user,    setUser]    = useState(null);
  const [foundation, setFoundation] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('nawasena_token');
    if (!token) { setLoading(false); return; }
    api.get('/users/me')
      .then(setUser)
      .catch(() => localStorage.removeItem('nawasena_token'))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    if (user?.role === 'foundation_admin' && user?.managed_foundation_id) {
      api.get(`/foundations/${user.managed_foundation_id}`)
        .then((data) => {
          setFoundation(data.foundation ?? data);
        })
        .catch((err) => {
          console.error("Gagal memuat status verifikasi panti:", err);
          setFoundation(null);
        });
    } else {
      setFoundation(null);
    }
  }, [user?.managed_foundation_id, user?.role]);

  const login = async (email, password) => {
    const data = await api.post('/auth/login', { email, password });
    localStorage.setItem('nawasena_token', data.token);
    setUser(data.user);
    return data.user;
  };

  const logout = async () => {
    try { await api.post('/auth/logout'); } catch (_) {}
    localStorage.removeItem('nawasena_token');
    setUser(null);
    setFoundation(null);
  };

  const refreshUser = useCallback(async () => {
    try {
      const fresh = await api.get('/users/me');
      setUser(fresh);
      return fresh;
    } catch (_) {}
  }, []);

  const myFoundationId = user?.managed_foundation_id ?? null;
  const isVerified = foundation?.is_verified ?? false;

  return (
    <AuthContext.Provider value={{ 
      user, 
      foundation,      
      isVerified,      
      login, 
      logout, 
      refreshUser, 
      myFoundationId 
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);