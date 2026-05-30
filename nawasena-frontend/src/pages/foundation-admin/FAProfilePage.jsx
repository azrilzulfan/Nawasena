// src/pages/foundation-admin/FAProfilePage.jsx
import { useState, useEffect } from 'react';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../lib/api';

export default function FAProfilePage() {
  const { user, myFoundationId } = useAuth();
  const [form,       setForm]       = useState({ full_name: user?.full_name ?? '', email: user?.email ?? '' });
  const [foundation, setFoundation] = useState(null);
  const [fForm,      setFForm]      = useState(null);
  const [saving,     setSaving]     = useState(false);
  const [fSaving,    setFSaving]    = useState(false);
  const [message,    setMessage]    = useState(null);
  const [fMessage,   setFMessage]   = useState(null);

  useEffect(() => {
    if (!myFoundationId) return;
    api.get(`/foundations/${myFoundationId}`)
      .then(data => {
        setFoundation(data);
        setFForm({
          name:          data.name,
          address:       data.address,
          contact_phone: data.contact_phone,
          description:   data.description ?? '',
          bank_name:     data.bank_account?.bank_name ?? '',
          account_number:data.bank_account?.account_number ?? '',
          account_name:  data.bank_account?.account_name ?? '',
        });
      })
      .catch(() => {});
  }, [myFoundationId]);

  const handleSaveProfile = async () => {
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

  const handleSaveFoundation = async () => {
    setFSaving(true);
    setFMessage(null);
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
      setFMessage({ type: 'success', text: 'Data yayasan berhasil diperbarui.' });
    } catch (err) {
      setFMessage({ type: 'error', text: err.message });
    } finally {
      setFSaving(false);
    }
  };

  const initials = form.full_name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();

  const msgClass = (m) => m?.type === 'success'
    ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
    : 'bg-rose-50 text-rose-600 border border-rose-200';

  return (
    <div className="max-w-lg space-y-5">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-blue-600 flex items-center justify-center text-white font-bold text-lg shrink-0">
            {initials}
          </div>
          <div>
            <p className="font-semibold text-slate-800">{form.full_name}</p>
            <p className="text-sm text-slate-400">Pengelola Panti</p>
          </div>
        </div>

        {message && <div className={`px-4 py-3 rounded-xl text-sm ${msgClass(message)}`}>{message.text}</div>}

        <div className="space-y-3">
          {[
            { label: 'Nama Lengkap', name: 'full_name', type: 'text' },
            { label: 'Email',        name: 'email',     type: 'email' },
          ].map(({ label, name, type }) => (
            <div key={name}>
              <label className="block text-xs font-medium text-slate-500 mb-1.5">{label}</label>
              <input type={type} name={name} value={form[name]}
                onChange={e => setForm(p => ({ ...p, [e.target.name]: e.target.value }))}
                className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          ))}
        </div>

        <button onClick={handleSaveProfile} disabled={saving}
          className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors">
          {saving ? 'Menyimpan...' : 'Simpan Profil'}
        </button>
      </div>

      {fForm && (
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
          <div>
            <p className="font-semibold text-slate-800">Data Yayasan</p>
            <p className="text-xs text-slate-400 mt-0.5">
              Status:&nbsp;
              <span className={foundation?.is_verified ? 'text-emerald-600 font-medium' : 'text-amber-600 font-medium'}>
                {foundation?.is_verified ? 'Terverifikasi ✓' : 'Menunggu Verifikasi'}
              </span>
            </p>
          </div>

          {fMessage && <div className={`px-4 py-3 rounded-xl text-sm ${msgClass(fMessage)}`}>{fMessage.text}</div>}

          <div className="space-y-3">
            {[
              { label: 'Nama Yayasan',   key: 'name' },
              { label: 'Alamat',         key: 'address' },
              { label: 'Nomor Telepon',  key: 'contact_phone' },
            ].map(({ label, key }) => (
              <div key={key}>
                <label className="block text-xs font-medium text-slate-500 mb-1.5">{label}</label>
                <input value={fForm[key]} onChange={e => setFForm(p => ({ ...p, [key]: e.target.value }))}
                  className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            ))}
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1.5">Deskripsi</label>
              <textarea value={fForm.description} onChange={e => setFForm(p => ({ ...p, description: e.target.value }))}
                rows={3} className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          <div>
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">
              Rekening Bank <span className="text-slate-300 font-normal normal-case">(opsional)</span>
            </p>
            <div className="space-y-3 pl-3 border-l-2 border-slate-100">
              {[
                { label: 'Nama Bank',             key: 'bank_name' },
                { label: 'Nomor Rekening',        key: 'account_number' },
                { label: 'Nama Pemilik Rekening', key: 'account_name' },
              ].map(({ label, key }) => (
                <div key={key}>
                  <label className="block text-xs font-medium text-slate-500 mb-1.5">{label}</label>
                  <input value={fForm[key]} onChange={e => setFForm(p => ({ ...p, [key]: e.target.value }))}
                    className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              ))}
            </div>
          </div>

          <button onClick={handleSaveFoundation} disabled={fSaving}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors">
            {fSaving ? 'Menyimpan...' : 'Simpan Data Yayasan'}
          </button>
        </div>
      )}
    </div>
  );
}