// src/features/users/pages/ProfilePage.jsx
import { useState } from 'react';
import { useAuth }  from '../../../context/AuthContext';
import { useToast } from '../../../context/ToastContext';
import { api }      from '../../../lib/api';

export default function ProfilePage() {
  const { user }  = useAuth();
  const toast     = useToast();

  const [form, setForm] = useState({
    full_name: user?.full_name ?? '',
    email:     user?.email     ?? '',
  });
  const [saving, setSaving] = useState(false);

  const handleChange = e => setForm(p => ({ ...p, [e.target.name]: e.target.value }));

  const handleSave = async () => {
    setSaving(true);
    try {
      await api.put('/users/me', form);
      toast.success('Profil berhasil diperbarui.');
    } catch (err) {
      toast.error(err.message);
    } finally {
      setSaving(false);
    }
  };

  const initials = form.full_name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();

  return (
    <div className="max-w-lg space-y-4 font-sans">
      <div className="bg-white rounded-2xl border border-muted shadow-sm p-6 space-y-5">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-primary flex items-center justify-center text-white font-bold text-lg shrink-0">
            {initials}
          </div>
          <div>
            <p className="font-semibold text-accent">{form.full_name}</p>
            <p className="text-sm text-text-muted capitalize">{user?.role}</p>
          </div>
        </div>

        <div className="space-y-4">
          {[
            { label: 'Nama Lengkap', name: 'full_name', type: 'text' },
            { label: 'Email',        name: 'email',     type: 'email' },
          ].map(({ label, name, type }) => (
            <div key={name}>
              <label className="block text-xs font-medium text-text-muted mb-1.5">{label}</label>
              <input
                type={type} name={name} value={form[name]} onChange={handleChange}
                className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
          ))}
        </div>

        <button
          onClick={handleSave} disabled={saving}
          className="w-full bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors"
        >
          {saving ? 'Menyimpan...' : 'Simpan Perubahan'}
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-muted shadow-sm p-5">
        <p className="text-xs font-semibold text-text-muted uppercase tracking-wide mb-3">Informasi Akun</p>
        <div className="space-y-2 text-sm text-accent">
          <div className="flex justify-between">
            <span className="text-text-muted">ID Pengguna</span>
            <span className="font-mono text-xs">{user?._id ?? user?.id}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-text-muted">Role</span>
            <span className="capitalize">{user?.role}</span>
          </div>
        </div>
      </div>
    </div>
  );
}