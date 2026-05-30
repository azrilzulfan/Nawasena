// src/pages/foundation-admin/FAInventoryAddPage.jsx
import { useState } from 'react';
import { CheckCircle } from 'lucide-react';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';
import VerifiedGate from '../../components/Auth/VerifiedGate';

const CATEGORIES   = ['Logistik', 'Edukasi', 'Medis'];
const URGENCY_OPTS = [
  { value: 'low',    label: 'Rendah' },
  { value: 'medium', label: 'Sedang' },
  { value: 'high',   label: 'Tinggi' },
];

function Field({ label, name, type = 'text', value, onChange, error, placeholder, required = true, children }) {
  return (
    <div>
      <label className="block text-xs font-medium text-slate-500 mb-1.5">
        {label} {required && <span className="text-rose-400">*</span>}
      </label>
      {children ?? (
        <input
          type={type} name={name} value={value} onChange={onChange}
          placeholder={placeholder} required={required}
          className={`w-full border rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none transition
            focus:ring-2 focus:border-transparent
            ${error ? 'border-rose-300 focus:ring-rose-300 bg-rose-50' : 'border-slate-200 focus:ring-blue-500'}`}
        />
      )}
      {error && <p className="mt-1 text-xs text-rose-500">{error}</p>}
    </div>
  );
}

export default function FAInventoryAddPage({ onNavigate }) {
  const { myFoundationId } = useAuth();
  const [form, setForm] = useState({
    item_name:    '',
    category:     'Logistik',
    unit:         '',
    target_qty:   '',
    current_qty:  '0',
    urgent_level: 'medium',
    description:  '',
  });
  const [errors,   setErrors]   = useState({});
  const [saving,   setSaving]   = useState(false);
  const [success,  setSuccess]  = useState(false);
  const [apiError, setApiError] = useState('');

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(p => ({ ...p, [name]: value }));
    if (errors[name]) setErrors(p => { const n = { ...p }; delete n[name]; return n; });
  };

  const validate = () => {
    const errs = {};
    if (!form.item_name.trim())  errs.item_name  = 'Nama item wajib diisi';
    if (!form.unit.trim())       errs.unit       = 'Satuan wajib diisi';
    if (!form.target_qty || Number(form.target_qty) < 1)
      errs.target_qty = 'Target harus lebih dari 0';
    return errs;
  };

  const handleSubmit = async () => {
    const errs = validate();
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }

    setSaving(true);
    setApiError('');
    try {
      await api.post(`/foundations/${myFoundationId}/inventories`, {
        ...form,
        target_qty:  Number(form.target_qty),
        current_qty: Number(form.current_qty),
      });
      setSuccess(true);
    } catch (err) {
      if (err.message?.includes('{')) {
        try {
          const parsed = JSON.parse(err.message);
          const mapped = {};
          Object.entries(parsed.errors ?? {}).forEach(([k, v]) => { mapped[k] = v[0]; });
          setErrors(mapped);
        } catch (_) { setApiError(err.message); }
      } else {
        setApiError(err.message);
      }
    } finally {
      setSaving(false);
    }
  };

  if (success) {
    return (
      <div className="max-w-md mx-auto">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8 text-center">
          <div className="w-14 h-14 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle size={28} className="text-emerald-600" />
          </div>
          <h3 className="font-bold text-slate-800 mb-2">Item Berhasil Ditambahkan!</h3>
          <p className="text-sm text-slate-400 mb-6">Item kebutuhan baru telah terdaftar di yayasan Anda.</p>
          <div className="flex gap-3">
            <button
              onClick={() => { setSuccess(false); setForm({ item_name: '', category: 'Logistik', unit: '', target_qty: '', current_qty: '0', urgent_level: 'medium', description: '' }); }}
              className="flex-1 border border-slate-200 text-slate-600 hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl"
            >
              Tambah Lagi
            </button>
            <button
              onClick={() => onNavigate('fa-inventories')}
              className="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium py-2.5 rounded-xl"
            >
              Lihat Daftar
            </button>
          </div>
        </div>
      </div>
    );
  }
  
  return (
    <div className="max-w-lg">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
        <VerifiedGate showLockedOverlay={true}>
        <div className="mb-2">
        <h2 className="font-bold text-slate-800">Tambah Item Kebutuhan</h2>
        <p className="text-sm text-slate-400">Item yang ditambahkan akan tampil di daftar kebutuhan publik</p>
        </div>

        {apiError && (
        <div className="px-4 py-3 bg-rose-50 border border-rose-200 rounded-xl text-sm text-rose-600">
            {apiError}
        </div>
        )}

        <Field label="Nama Item" name="item_name" value={form.item_name} onChange={handleChange}
        error={errors.item_name} placeholder="Beras 5kg" />

        <div className="grid grid-cols-2 gap-4">
        <Field label="Kategori" name="category" error={errors.category}>
            <select name="category" value={form.category} onChange={handleChange}
            className="w-full border border-slate-200 rounded-xl px-3 py-2.5 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-blue-500">
            {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
            </select>
        </Field>
        <Field label="Satuan" name="unit" value={form.unit} onChange={handleChange}
            error={errors.unit} placeholder="karung / kotak / set" />
        </div>

        <div className="grid grid-cols-2 gap-4">
        <Field label="Stok Saat Ini" name="current_qty" type="number" value={form.current_qty}
            onChange={handleChange} error={errors.current_qty} placeholder="0" />
        <Field label="Target Kebutuhan" name="target_qty" type="number" value={form.target_qty}
            onChange={handleChange} error={errors.target_qty} placeholder="100" />
        </div>

        <Field label="Tingkat Urgensi" name="urgent_level" error={errors.urgent_level}>
        <div className="flex gap-2">
            {URGENCY_OPTS.map(o => (
            <button
                key={o.value}
                type="button"
                onClick={() => setForm(p => ({ ...p, urgent_level: o.value }))}
                className={`flex-1 py-2.5 rounded-xl text-sm font-medium transition-colors border
                ${form.urgent_level === o.value
                    ? o.value === 'high'   ? 'bg-rose-600 text-white border-rose-600'
                    : o.value === 'medium' ? 'bg-amber-500 text-white border-amber-500'
                    :                        'bg-emerald-600 text-white border-emerald-600'
                    : 'bg-white text-slate-500 border-slate-200 hover:bg-slate-50'
                }`}
            >
                {o.label}
            </button>
            ))}
        </div>
        </Field>

        <div>
        <label className="block text-xs font-medium text-slate-500 mb-1.5">Deskripsi</label>
        <textarea name="description" value={form.description} onChange={handleChange} rows={3}
            placeholder="Jelaskan kebutuhan ini, kondisi stok, atau informasi tambahan..."
            className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
        </div>

        <button
        onClick={handleSubmit} disabled={saving}
        className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2 mt-2"
        >
        {saving
            ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />Menyimpan...</>
            : 'Tambah Item'
        }
        </button>
        </VerifiedGate>
      </div>
    </div>
  );
}