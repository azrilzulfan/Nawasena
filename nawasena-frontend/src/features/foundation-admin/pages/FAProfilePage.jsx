// src/features/foundation-admin/pages/FAProfilePage.jsx
import { useState, useEffect } from 'react';
import { useAuth }  from '../../../context/AuthContext';
import { useToast } from '../../../context/ToastContext';
import { api }      from '../../../lib/api';

export default function FAProfilePage() {
  const { user, myFoundationId } = useAuth();
  const toast = useToast();

  const [form,       setForm]       = useState({ full_name: user?.full_name ?? '', email: user?.email ?? '' });
  const [foundation, setFoundation] = useState(null);
  const [fForm,       setFForm]      = useState(null);
  const [saving,     setSaving]     = useState(false);
  const [fSaving,    setFSaving]    = useState(false);

  useEffect(() => {
    if (!myFoundationId) return;
    api.get(`/foundations/${myFoundationId}`)
      .then(data => {
        setFoundation(data);
        setFForm({
          name:           data.name,
          address:        data.address,
          contact_phone:  data.contact_phone,
          description:    data.description ?? '',
          bank_name:      data.bank_account?.bank_name ?? '',
          account_number: data.bank_account?.account_number ?? '',
          account_name:   data.bank_account?.account_name ?? '',
        });
      })
      .catch(() => {});
  }, [myFoundationId]);

  const handleSaveProfile = async () => {
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

  const handleSaveFoundation = async () => {
    setFSaving(true);
    try {
      await api.put(`/foundations/${myFoundationId}`, {
        name:          fForm.name,
        address:       fForm.address,
        contact_phone: fForm.contact_phone,
        description:   fForm.description,
        ...(fForm.bank_name && {
          bank_account: {
            bank_name:      fForm.bank_name,
            account_number: fForm.account_number,
            account_name:   fForm.account_name,
          },
        }),
      });
      toast.success('Data yayasan berhasil diperbarui.');
    } catch (err) {
      toast.error(err.message);
    } finally {
      setFSaving(false);
    }
  };

  const initials = form.full_name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();

  return (
    <div className="max-w-lg space-y-5 font-sans">
      {/* — Profil Pengguna — */}
      <div className="bg-white rounded-2xl border border-muted shadow-sm p-6 space-y-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-primary flex items-center justify-center text-white font-bold text-lg shrink-0">
            {initials}
          </div>
          <div>
            <p className="font-semibold text-accent">{form.full_name}</p>
            <p className="text-sm text-text-muted">Pengelola Panti</p>
          </div>
        </div>

        <div className="space-y-3">
          {[
            { label: 'Nama Lengkap', name: 'full_name', type: 'text' },
            { label: 'Email',        name: 'email',     type: 'email' },
          ].map(({ label, name, type }) => (
            <div key={name}>
              <label className="block text-xs font-medium text-text-muted mb-1.5">{label}</label>
              <input type={type} name={name} value={form[name]}
                onChange={e => setForm(p => ({ ...p, [e.target.name]: e.target.value }))}
                className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
          ))}
        </div>

        <button onClick={handleSaveProfile} disabled={saving}
          className="w-full bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors">
          {saving ? 'Menyimpan...' : 'Simpan Profil'}
        </button>
      </div>

      {/* — Data Yayasan — */}
      {fForm && (
        <div className="bg-white rounded-2xl border border-muted shadow-sm p-6 space-y-4">
          <div>
            <p className="font-semibold text-accent">Data Yayasan</p>
            <p className="text-xs text-text-muted mt-0.5">
              Status:&nbsp;
              <span className={foundation?.is_verified ? 'text-primary font-medium' : 'text-amber-600 font-medium'}>
                {foundation?.is_verified ? 'Terverifikasi ✓' : 'Menunggu Verifikasi'}
              </span>
            </p>
          </div>

          <div className="space-y-3">
            {[
              { label: 'Nama Yayasan',  key: 'name' },
              { label: 'Alamat',        key: 'address' },
              { label: 'Nomor Telepon', key: 'contact_phone' },
            ].map(({ label, key }) => (
              <div key={key}>
                <label className="block text-xs font-medium text-text-muted mb-1.5">{label}</label>
                <input value={fForm[key]} onChange={e => setFForm(p => ({ ...p, [key]: e.target.value }))}
                  className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                />
              </div>
            ))}
            <div>
              <label className="block text-xs font-medium text-text-muted mb-1.5">Deskripsi</label>
              <textarea value={fForm.description} onChange={e => setFForm(p => ({ ...p, description: e.target.value }))}
                rows={3} className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none resize-none focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <p className="text-xs font-semibold text-text-muted uppercase tracking-wide mb-3">
              Rekening Bank <span className="text-slate-300 font-normal normal-case">(opsional)</span>
            </p>
            <div className="space-y-3 pl-3 border-l-2 border-muted">
              {[
                { label: 'Nama Bank',             key: 'bank_name' },
                { label: 'Nomor Rekening',        key: 'account_number' },
                { label: 'Nama Pemilik Rekening', key: 'account_name' },
              ].map(({ label, key }) => (
                <div key={key}>
                  <label className="block text-xs font-medium text-text-muted mb-1.5">{label}</label>
                  <input value={fForm[key]} onChange={e => setFForm(p => ({ ...p, [key]: e.target.value }))}
                    className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                  />
                </div>
              ))}
            </div>
          </div>

          <button onClick={handleSaveFoundation} disabled={fSaving}
            className="w-full bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors">
            {fSaving ? 'Menyimpan...' : 'Simpan Data Yayasan'}
          </button>
        </div>
      )}
    </div>
  );
}