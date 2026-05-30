// src/pages/settings/ProfilePage.jsx
import { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../lib/api';

export default function ProfilePage() {
  const { user, login } = useAuth();

  const [form, setForm]         = useState({
    full_name: user?.full_name ?? '',
    email:     user?.email ?? '',
  });
  const [password, setPassword] = useState({ current: '', new: '', confirm: '' });
  const [saving,   setSaving]   = useState(false);
  const [message,  setMessage]  = useState(null);

  const handleChange  = e => setForm(p => ({ ...p, [e.target.name]: e.target.value }));
  const handlePwdChange = e => setPassword(p => ({ ...p, [e.target.name]: e.target.value }));

  const handleSave = async () => {
    setSaving(true);
    setMessage(null);
    try {
      await api.put('/users/me', form);
      setMessage({ type: 'success', text: 'Profil berhasil diperbarui.' });
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    } finally {
      setSaving(false);
    }
  };

  const initials = form.full_name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();

  return (
    <div className="max-w-lg space-y-4">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-5">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-emerald-600 flex items-center justify-center text-white font-bold text-lg shrink-0">
            {initials}
          </div>
          <div>
            <p className="font-semibold text-slate-800">{form.full_name}</p>
            <p className="text-sm text-slate-400 capitalize">{user?.role}</p>
          </div>
        </div>

        {message && (
          <div className={`px-4 py-3 rounded-xl text-sm ${
            message.type === 'success'
              ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
              : 'bg-rose-50 text-rose-600 border border-rose-200'
          }`}>
            {message.text}
          </div>
        )}

        <div className="space-y-4">
          {[
            { label: 'Nama Lengkap', name: 'full_name', type: 'text' },
            { label: 'Email',        name: 'email',     type: 'email' },
          ].map(({ label, name, type }) => (
            <div key={name}>
              <label className="block text-xs font-medium text-slate-500 mb-1.5">{label}</label>
              <input
                type={type} name={name} value={form[name]} onChange={handleChange}
                className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
              />
            </div>
          ))}
        </div>

        <button
          onClick={handleSave} disabled={saving}
          className="w-full bg-emerald-600 hover:bg-emerald-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors"
        >
          {saving ? 'Menyimpan...' : 'Simpan Perubahan'}
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
        <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">Informasi Akun</p>
        <div className="space-y-2 text-sm text-slate-600">
          <div className="flex justify-between">
            <span className="text-slate-400">ID Pengguna</span>
            <span className="font-mono text-xs">{user?._id}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-slate-400">Role</span>
            <span className="capitalize">{user?.role}</span>
          </div>
        </div>
      </div>
    </div>
  );
}