// src/features/foundation-admin/pages/FAWorkshopAddPage.jsx
import { useState } from 'react';
import { CheckCircle } from 'lucide-react';
import FormField    from '../../../components/ui/FormField';
import Spinner      from '../../../components/ui/Spinner';
import VerifiedGate from '../../auth/components/VerifiedGate';
import { api }      from '../../../lib/api';
import { useAuth }  from '../../../context/AuthContext';

const INITIAL_FORM = {
  title: '', description: '', event_date: '',
  mentor_needed: '1', geofence_radius_meters: '100',
};

export default function FAWorkshopAddPage({ onNavigate }) {
  const { myFoundationId } = useAuth();
  const [form,     setForm]     = useState(INITIAL_FORM);
  const [errors,   setErrors]   = useState({});
  const [saving,   setSaving]   = useState(false);
  const [success,   setSuccess]  = useState(false);
  const [apiError, setApiError] = useState('');

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(p => ({ ...p, [name]: value }));
    if (errors[name]) setErrors(p => { const n = { ...p }; delete n[name]; return n; });
  };

  const validate = () => {
    const errs = {};
    if (!form.title.trim())       errs.title       = 'Judul wajib diisi';
    if (!form.description.trim()) errs.description = 'Deskripsi wajib diisi';
    if (!form.event_date)         errs.event_date  = 'Tanggal acara wajib diisi';
    if (Number(form.mentor_needed) < 1) errs.mentor_needed = 'Minimal 1 mentor';
    return errs;
  };

  const handleSubmit = async () => {
    const errs = validate();
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }
    setSaving(true);
    setApiError('');
    try {
      await api.post(`/foundations/${myFoundationId}/workshops`, {
        title:                  form.title,
        description:            form.description,
        event_date:             new Date(form.event_date).toISOString(),
        mentor_needed:          Number(form.mentor_needed),
        geofence_radius_meters: Number(form.geofence_radius_meters),
        status:                 'open',
        location:               { type: 'Point', coordinates: [0, 0] },
      });
      setSuccess(true);
    } catch (err) {
      setApiError(err.message);
    } finally {
      setSaving(false);
    }
  };

  if (success) {
    return (
      <div className="max-w-md mx-auto font-sans">
        <div className="bg-white rounded-2xl border border-muted shadow-sm p-8 text-center">
          <div className="w-14 h-14 bg-secondary/20 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle size={28} className="text-primary" />
          </div>
          <h3 className="font-bold text-accent mb-2">Workshop Berhasil Dibuat!</h3>
          <p className="text-sm text-text-muted mb-6">Workshop baru telah terdaftar dan dibuka untuk pendaftaran relawan.</p>
          <div className="flex gap-3">
            <button onClick={() => { setSuccess(false); setForm(INITIAL_FORM); }}
              className="flex-1 border border-muted text-accent hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl">
              Buat Lagi
            </button>
            <button onClick={() => onNavigate('fa-workshops')}
              className="flex-1 bg-primary hover:bg-primary-hover text-white text-sm font-medium py-2.5 rounded-xl">
              Lihat Workshop
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-lg font-sans">
      <div className="bg-white rounded-2xl border border-muted shadow-sm p-6 space-y-4">
        <VerifiedGate showLockedOverlay>
          <div className="mb-2">
            <h2 className="font-bold text-accent">Buat Workshop Baru</h2>
            <p className="text-sm text-text-muted">Workshop akan langsung terbuka untuk pendaftaran relawan</p>
          </div>
          {apiError && (
            <div className="px-4 py-3 bg-rose-50 border border-rose-200 rounded-xl text-sm text-rose-600">
              {apiError}
            </div>
          )}
          <FormField label="Judul Workshop" name="title" value={form.title}
            onChange={handleChange} error={errors.title} placeholder="Pelatihan Baca Tulis Anak" />
          <div>
            <label className="block text-xs font-medium text-text-muted mb-1.5">
              Deskripsi <span className="text-rose-400">*</span>
            </label>
            <textarea name="description" value={form.description} onChange={handleChange} rows={3}
              placeholder="Jelaskan tujuan, materi, dan hal yang perlu disiapkan relawan..."
              className={`w-full border rounded-xl px-4 py-2.5 text-sm text-accent outline-none resize-none transition
                focus:ring-2 focus:border-transparent
                ${errors.description ? 'border-rose-300 focus:ring-rose-300 bg-rose-50' : 'border-muted focus:ring-primary'}`}
            />
            {errors.description && <p className="mt-1 text-xs text-rose-500">{errors.description}</p>}
          </div>
          <FormField label="Tanggal & Waktu Acara" name="event_date" type="datetime-local"
            value={form.event_date} onChange={handleChange} error={errors.event_date} />
          <div className="grid grid-cols-2 gap-4">
            <FormField label="Jumlah Mentor Dibutuhkan" name="mentor_needed" type="number"
              value={form.mentor_needed} onChange={handleChange} error={errors.mentor_needed} placeholder="5" />
            <FormField label="Radius Geofence (meter)" name="geofence_radius_meters" type="number"
              value={form.geofence_radius_meters} onChange={handleChange}
              error={errors.geofence_radius_meters} placeholder="100" required={false} />
          </div>
          <button onClick={handleSubmit} disabled={saving}
            className="w-full bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2 mt-2">
            {saving ? <><Spinner />Menyimpan...</> : 'Buat Workshop'}
          </button>
        </VerifiedGate>
      </div>
    </div>
  );
}