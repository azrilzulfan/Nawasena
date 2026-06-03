// src/pages/LoginPage.jsx
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../../context/AuthContext';
import logoNawasena from '../../../assets/Logo.png';

export default function LoginPage() {
  const { login } = useAuth();
  const [form, setForm]       = useState({ email: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState('');

  const handleChange = e => setForm(p => ({ ...p, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      await login(form.email, form.password);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center px-4 font-sans">
      <div className="w-full max-w-sm">
        <div className="flex items-center gap-3 mb-8 justify-center">
          <div className="w-12 h-12 rounded-xl flex items-center justify-center">
            <img src={logoNawasena} alt="Nawasena"/>
          </div>
          <div>
            <p className="font-bold text-accent text-lg leading-tight">Nawasena</p>
            <p className="text-xs text-text-muted">Admin Dashboard</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-muted shadow-sm p-6">
          <h2 className="text-lg font-bold text-accent mb-1">Masuk ke Dashboard</h2>
          <p className="text-sm text-text-muted mb-6">Gunakan kredensial admin Anda</p>

          {error && (
            <div className="mb-4 px-4 py-3 bg-rose-50 border border-rose-200 rounded-xl text-sm text-rose-600">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-medium text-text-muted mb-1.5">Email</label>
              <input
                type="email" name="email" value={form.email} onChange={handleChange} required
                placeholder="admin@nawasena.id"
                className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-text-muted mb-1.5">Password</label>
              <input
                type="password" name="password" value={form.password} onChange={handleChange} required
                placeholder="••••••••"
                className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
            <button
              type="submit" disabled={loading}
              className="w-full bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors"
            >
              {loading ? 'Memverifikasi...' : 'Masuk'}
            </button>
          </form>

          <div className="mt-5 pt-5 border-t border-muted text-center">
            <p className="text-xs text-text-muted">
              Pengelola panti baru?{' '}
              <Link
                to="/register"
                className="text-primary hover:text-primary-hover font-medium"
              >
                Daftar yayasan di sini
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}