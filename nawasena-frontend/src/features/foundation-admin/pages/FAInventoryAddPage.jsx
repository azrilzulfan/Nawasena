// src/features/foundation-admin/pages/FAInventoryAddPage.jsx
import { useState }   from 'react';
import { useNavigate } from 'react-router-dom';
import FormField      from '../../../components/ui/FormField';
import Spinner        from '../../../components/ui/Spinner';
import VerifiedGate   from '../../auth/components/VerifiedGate';
import { useToast }   from '../../../context/ToastContext';
import { api }        from '../../../lib/api';
import { useAuth }    from '../../../context/AuthContext';

const CATEGORIES   = ['Logistik', 'Edukasi', 'Medis'];
const URGENCY_OPTS = [
  { value: 'low',    label: 'Rendah' },
  { value: 'medium', label: 'Sedang' },
  { value: 'high',   label: 'Tinggi' },
];

const INITIAL_FORM = {
  item_name: '', category: 'Logistik', unit: '',
  target_qty: '', current_qty: '0', urgent_level: 'medium', description: '',
};

export default function FAInventoryAddPage() {
  const { myFoundationId } = useAuth();
  const navigate = useNavigate();
  const toast    = useToast();

  const [form,   setForm]   = useState(INITIAL_FORM);
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(p => ({ ...p, [name]: value }));
    if (errors[name]) setErrors(p => { const n = { ...p }; delete n[name]; return n; });
  };

  const validate = () => {
    const errs = {};
    if (!form.item_name.trim()) errs.item_name = 'Nama item wajib diisi';
    if (!form.unit.trim())      errs.unit      = 'Satuan wajib diisi';
    if (!form.target_qty || Number(form.target_qty) < 1)
      errs.target_qty = 'Target harus lebih dari 0';
    return errs;
  };

  const handleSubmit = async () => {
    const errs = validate();
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }
    setSaving(true);
    try {
      await api.post(`/foundations/${myFoundationId}/inventories`, {
        ...form,
        target_qty:  Number(form.target_qty),
        current_qty: Number(form.current_qty),
      });
      toast.success('Item kebutuhan berhasil ditambahkan!');
      navigate('/fa/inventories');
    } catch (err) {
      try {
        const parsed = JSON.parse(err.message);
        const mapped = {};
        Object.entries(parsed.errors ?? {}).forEach(([k, v]) => { mapped[k] = v[0]; });
        setErrors(mapped);
      } catch (_) {
        toast.error(err.message);
      }
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="max-w-lg font-sans">
      <div className="bg-white rounded-2xl border border-muted shadow-sm p-6 space-y-4">
        <VerifiedGate showLockedOverlay>
          <div className="mb-2">
            <h2 className="font-bold text-accent">Tambah Item Kebutuhan</h2>
            <p className="text-sm text-text-muted">Item yang ditambahkan akan tampil di daftar kebutuhan publik</p>
          </div>

          <FormField label="Nama Item" name="item_name" value={form.item_name}
            onChange={handleChange} error={errors.item_name} placeholder="Beras 5kg" />

          <div className="grid grid-cols-2 gap-4">
            <FormField label="Kategori" name="category" error={errors.category}>
              <select name="category" value={form.category} onChange={handleChange}
                className="w-full border border-muted rounded-xl px-3 py-2.5 text-sm text-accent outline-none focus:ring-2 focus:ring-primary focus:border-transparent bg-white">
                {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </FormField>
            <FormField label="Satuan" name="unit" value={form.unit}
              onChange={handleChange} error={errors.unit} placeholder="karung / kotak" />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <FormField label="Stok Saat Ini" name="current_qty" type="number"
              value={form.current_qty} onChange={handleChange} error={errors.current_qty} placeholder="0" />
            <FormField label="Target Kebutuhan" name="target_qty" type="number"
              value={form.target_qty} onChange={handleChange} error={errors.target_qty} placeholder="100" />
          </div>

          <FormField label="Tingkat Urgensi" name="urgent_level" error={errors.urgent_level}>
            <div className="flex gap-2">
              {URGENCY_OPTS.map(o => (
                <button key={o.value} type="button"
                  onClick={() => setForm(p => ({ ...p, urgent_level: o.value }))}
                  className={`flex-1 py-2.5 rounded-xl text-sm font-medium transition-colors border
                    ${form.urgent_level === o.value
                      ? o.value === 'high'   ? 'bg-rose-600 text-white border-rose-600'
                        : o.value === 'medium' ? 'bg-amber-500 text-white border-amber-500'
                        :                        'bg-primary text-white border-primary'
                      : 'bg-white text-text-muted border-muted hover:bg-slate-50'
                    }`}
                >
                  {o.label}
                </button>
              ))}
            </div>
          </FormField>

          <div>
            <label className="block text-xs font-medium text-text-muted mb-1.5">Deskripsi</label>
            <textarea name="description" value={form.description} onChange={handleChange} rows={3}
              placeholder="Jelaskan kebutuhan ini..."
              className="w-full border border-muted rounded-xl px-4 py-2.5 text-sm text-accent outline-none resize-none focus:ring-2 focus:ring-primary focus:border-transparent" />
          </div>

          <div className="flex gap-3 mt-2">
            <button type="button" onClick={() => navigate('/fa/inventories')}
              className="flex-1 border border-muted text-accent hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl transition-colors">
              Batal
            </button>
            <button onClick={handleSubmit} disabled={saving}
              className="flex-1 bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2">
              {saving ? <><Spinner />Menyimpan...</> : 'Tambah Item'}
            </button>
          </div>
        </VerifiedGate>
      </div>
    </div>
  );
}