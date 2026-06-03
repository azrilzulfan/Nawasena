// src/features/auth/pages/RegisterPage.jsx
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { CheckCircle, AlertCircle, MapPin, UploadCloud, FileText, Trash2 } from 'lucide-react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import markerIcon   from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

import logoNawasena from '../../../assets/Logo.png';
import FormField from '../../../components/ui/FormField';
import Spinner   from '../../../components/ui/Spinner';
import { api }   from '../../../lib/api';
import { useAuth } from '../../../context/AuthContext';

const DefaultIcon = L.icon({ iconUrl: markerIcon, shadowUrl: markerShadow, iconSize: [25, 41], iconAnchor: [12, 41] });
L.Marker.prototype.options.icon = DefaultIcon;

const STEPS = ['Akun', 'Panti', 'Selesai'];

const INITIAL_FORM = {
  full_name: '', email: '', password: '', password_confirmation: '',
  foundation_name: '', foundation_address: '', contact_phone: '',
  description: '', latitude: '-6.638156', longitude: '106.838207',
  verification_docs: [],
  bank_name: '', account_number: '', account_name: '',
};

function MapClickHandler({ onClick }) {
  useMapEvents({ click: e => onClick(e.latlng.lat.toFixed(6), e.latlng.lng.toFixed(6)) });
  return null;
}

function validateStep1(form) {
  const errors = {};
  if (!form.full_name.trim()) errors.full_name = 'Nama lengkap wajib diisi';
  if (!form.email.trim())     errors.email     = 'Email wajib diisi';
  else if (!/\S+@\S+\.\S+/.test(form.email)) errors.email = 'Format email tidak valid';
  if (form.password.length < 8) errors.password = 'Password minimal 8 karakter';
  if (form.password !== form.password_confirmation)
    errors.password_confirmation = 'Konfirmasi password tidak cocok';
  return errors;
}

function validateStep2(form) {
  const errors = {};
  if (!form.foundation_name.trim())    errors.foundation_name    = 'Nama yayasan wajib diisi';
  if (!form.foundation_address.trim()) errors.foundation_address = 'Alamat wajib diisi';
  if (!form.contact_phone.trim())      errors.contact_phone      = 'Nomor telepon wajib diisi';
  else if (!/^[0-9+\-\s]{8,15}$/.test(form.contact_phone))
    errors.contact_phone = 'Format nomor telepon tidak valid';
  if (!form.description.trim())        errors.description        = 'Deskripsi wajib diisi';
  if (form.verification_docs.length === 0)
    errors.verification_docs = 'Minimal unggah 1 dokumen verifikasi';
  return errors;
}

export default function RegisterPage() {
  const { login } = useAuth();
  const [step,    setStep]    = useState(0);
  const [form,    setForm]    = useState(INITIAL_FORM);
  const [errors,  setErrors]  = useState({});
  const [loading, setLoading] = useState(false);
  const [apiError, setApiError] = useState('');

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(p => ({ ...p, [name]: value }));
    if (errors[name]) setErrors(p => { const n = { ...p }; delete n[name]; return n; });
  };

  const updateCoordinates = (lat, lng) => {
    setForm(p => ({ ...p, latitude: lat, longitude: lng }));
    setErrors(p => { const n = { ...p }; delete n.latitude; delete n.longitude; return n; });
  };

  const handleFileChange = (e) => {
    const files = Array.from(e.target.files);
    if (!files.length) return;
    const newDocs = files.map(file => ({
      id: Math.random().toString(36).slice(2, 11),
      file,
      name: file.name,
      size: (file.size / (1024 * 1024)).toFixed(2) + ' MB',
      previewUrl: file.type.startsWith('image/') ? URL.createObjectURL(file) : null,
    }));
    setForm(p => ({ ...p, verification_docs: [...p.verification_docs, ...newDocs] }));
    if (errors.verification_docs)
      setErrors(p => { const n = { ...p }; delete n.verification_docs; return n; });
  };

  const handleRemoveFile = (id) => {
    setForm(p => {
      const doc = p.verification_docs.find(d => d.id === id);
      if (doc?.previewUrl) URL.revokeObjectURL(doc.previewUrl);
      return { ...p, verification_docs: p.verification_docs.filter(d => d.id !== id) };
    });
  };

  const handleNext = () => {
    const errs = validateStep1(form);
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }
    setErrors({});
    setStep(1);
  };

  const handleSubmit = async () => {
    const errs = validateStep2(form);
    if (Object.keys(errs).length > 0) { setErrors(errs); return; }
    setErrors({});
    setApiError('');
    setLoading(true);

    try {
      const regData = await api.post('/auth/register', {
        full_name: form.full_name, email: form.email,
        password: form.password, password_confirmation: form.password_confirmation,
        role: 'foundation_admin',
      });

      const token = regData.token;

      const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://nawasena-backend.test/api';
      let docUrls = [];
      if (form.verification_docs.length > 0) {
        const uploadPromises = form.verification_docs.map(async (doc) => {
          const fd = new FormData();
          fd.append('file', doc.file);       
          fd.append('folder', 'docs');       

          const uploadRes = await fetch(`${BASE_URL}/uploads`, {
            method: 'POST',
            headers: { 
              Authorization: `Bearer ${token}`, 
              Accept: 'application/json' 
            },
            body: fd,
          });

          const uploadData = await uploadRes.json();
          
          if (!uploadRes.ok) {
            throw new Error(uploadData.message ?? `Gagal mengunggah file ${doc.name}`);
          }

          return uploadData.url; 
        });

        docUrls = await Promise.all(uploadPromises);
      }

      await fetch(`${BASE_URL}/foundations`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}`, Accept: 'application/json' },
        body: JSON.stringify({
          name:        form.foundation_name,
          address:     form.foundation_address,
          contact_phone: form.contact_phone,
          description: form.description,
          location:    { type: 'Point', coordinates: [parseFloat(form.longitude), parseFloat(form.latitude)] },
          verification_docs: docUrls,
          ...(form.bank_name && {
            bank_account: { bank_name: form.bank_name, account_number: form.account_number, account_name: form.account_name },
          }),
        }),
      });

      localStorage.setItem('nawasena_token', token);
      await login(form.email, form.password);
    } catch (err) {
      if (err.message?.startsWith('{')) {
        try {
          const parsed = JSON.parse(err.message);
          const mapped = {};
          Object.entries(parsed.errors ?? {}).forEach(([k, v]) => { mapped[k] = v[0]; });
          setErrors(mapped);
          setStep(0);
        } catch (_) { setApiError(err.message); }
      } else {
        setApiError(err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md">
        <div className="flex items-center gap-3 mb-6 justify-center">
          <div className="w-12 h-12 flex items-center justify-center">
            <img src={logoNawasena} alt="Nawasen" />
          </div>
          <div>
            <p className="font-bold text-accent text-lg leading-tight">Nawasena</p>
            <p className="text-xs text-text-muted">Daftar Yayasan</p>
          </div>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-3 mb-6 font-sans">
          {STEPS.map((s, i) => (
            <div key={s} className="flex items-center gap-1.5">
              <div 
                className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold transition-colors
                  ${i < step 
                    ? 'bg-primary text-white' 
                    : i === step 
                      ? 'bg-secondary/20 text-primary ring-2 ring-primary' 
                      : 'bg-muted text-text-muted' 
                  }`}
              >
                {i < step ? <CheckCircle size={14} /> : i + 1}
              </div>

              <span 
                className={`text-xs font-medium transition-colors ${
                  i === step ? 'text-accent font-bold' : 'text-text-muted'
                }`}
              >
                {s}
              </span>

              {i < STEPS.length - 1 && (
                <div 
                  className={`w-8 h-px transition-colors ${
                    i < step ? 'bg-primary' : 'bg-muted'
                  }`} 
                />
              )}
            </div>
          ))}
        </div>

        <div className="bg-white rounded-2xl border border-muted shadow-sm p-6">
          {apiError && (
            <div className="mb-4 flex items-start gap-2 px-4 py-3 bg-rose-50 border border-rose-200 rounded-xl">
              <AlertCircle size={15} className="text-rose-500 mt-0.5 shrink-0" />
              <p className="text-sm text-rose-600">{apiError}</p>
            </div>
          )}

          {step === 0 && (
            <div className="space-y-4">
              <div className="mb-5">
                <h2 className="text-lg font-bold text-accent">Data Akun</h2>
                <p className="text-sm text-text-muted">Informasi login pengelola yayasan</p>
              </div>
              <FormField label="Nama Lengkap" name="full_name" value={form.full_name}
                onChange={handleChange} error={errors.full_name} placeholder="Budi Santoso" />
              <FormField label="Email" name="email" type="email" value={form.email}
                onChange={handleChange} error={errors.email} placeholder="budi@yayasan.id" />
              <FormField label="Password" name="password" type="password" value={form.password}
                onChange={handleChange} error={errors.password} hint="Minimal 8 karakter" />
              <FormField label="Konfirmasi Password" name="password_confirmation" type="password"
                value={form.password_confirmation} onChange={handleChange} error={errors.password_confirmation} />
              <button onClick={handleNext}
                className="w-full mt-2 bg-primary hover:bg-primary-hover text-white text-sm font-medium py-2.5 rounded-xl transition-colors">
                Lanjutkan →
              </button>
            </div>
          )}

          {step === 1 && (
            <div className="space-y-4">
              <div className="mb-5">
                <h2 className="text-lg font-bold text-accent">Data Yayasan</h2>
                <p className="text-sm text-text-muted">Informasi panti asuhan yang Anda kelola</p>
              </div>
              <FormField label="Nama Yayasan / Panti" name="foundation_name" value={form.foundation_name}
                onChange={handleChange} error={errors.foundation_name} placeholder="Yayasan Harapan Bangsa" />
              <FormField label="Alamat Lengkap" name="foundation_address" value={form.foundation_address}
                onChange={handleChange} error={errors.foundation_address} placeholder="Jl. Merdeka No.12, Jakarta Pusat" />
              <FormField label="Nomor Telepon" name="contact_phone" type="tel" value={form.contact_phone}
                onChange={handleChange} error={errors.contact_phone} placeholder="0812-0000-0000" />
              <div>
                <label className="block text-xs font-medium text-text-muted mb-1.5">
                  Deskripsi Yayasan <span className="text-rose-400">*</span>
                </label>
                <textarea name="description" value={form.description} onChange={handleChange} rows={3}
                  placeholder="Ceritakan singkat tentang yayasan..."
                  className={`w-full border rounded-xl px-4 py-2.5 text-sm text-accent outline-none resize-none transition
                    focus:ring-2 focus:border-transparent
                    ${errors.description ? 'border-rose-300 focus:ring-rose-300 bg-rose-50' : 'border-muted focus:ring-primary'}`}
                />
                {errors.description && <p className="mt-1 text-xs text-rose-500">{errors.description}</p>}
              </div>

              <div className="space-y-2">
                <label className="block text-xs font-medium text-text-muted">
                  Titik Lokasi Panti <span className="text-rose-400">*</span>
                </label>
                <div className="w-full rounded-xl overflow-hidden border border-muted relative bg-slate-50 z-0">
                  <MapContainer center={[parseFloat(form.latitude), parseFloat(form.longitude)]}
                    zoom={13} style={{ width: '100%', height: '240px' }}>
                    <TileLayer
                      attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    />
                    <MapClickHandler onClick={updateCoordinates} />
                    <Marker
                      position={[parseFloat(form.latitude), parseFloat(form.longitude)]}
                      draggable
                      eventHandlers={{ dragend: e => {
                        const ll = e.target.getLatLng();
                        updateCoordinates(ll.lat.toFixed(6), ll.lng.toFixed(6));
                      }}}
                    />
                  </MapContainer>
                </div>
                <div className="grid grid-cols-2 gap-3 text-[11px] text-text-muted bg-slate-50 p-2.5 rounded-xl border border-muted">
                  <div className="flex items-center gap-1.5"><MapPin size={13} className="text-primary shrink-0" />
                    Lat: <strong className="text-accent">{form.latitude}</strong></div>
                  <div className="flex items-center gap-1.5"><MapPin size={13} className="text-primary shrink-0" />
                    Lng: <strong className="text-accent">{form.longitude}</strong></div>
                </div>
              </div>

              <div className="space-y-2">
                <label className="block text-xs font-medium text-text-muted">
                  Dokumen Legalitas <span className="text-rose-400">*</span>
                </label>
                <div className="border-2 border-dashed border-muted hover:border-primary rounded-xl p-5 text-center cursor-pointer transition relative bg-slate-50/50">
                  <input type="file" multiple accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                    onChange={handleFileChange}
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer" />
                  <UploadCloud size={26} className="text-text-muted mx-auto mb-1.5" />
                  <p className="text-xs font-medium text-accent">Pilih berkas atau drop di sini</p>
                  <p className="text-[10px] text-text-muted mt-0.5">PDF, Word, atau Gambar (Maks. 5MB)</p>
                </div>
                {form.verification_docs.length > 0 && (
                  <div className="space-y-2 pt-1 max-h-40 overflow-y-auto">
                    {form.verification_docs.map(doc => (
                      <div key={doc.id} className="flex items-center justify-between p-2.5 bg-white border border-muted rounded-xl shadow-sm gap-3">
                        <div className="flex items-center gap-2.5 min-w-0">
                          {doc.previewUrl
                            ? <img src={doc.previewUrl} alt="preview" className="w-8 h-8 object-cover rounded-lg border border-muted shrink-0" />
                            : <div className="w-8 h-8 rounded-lg bg-secondary/10 text-primary flex items-center justify-center shrink-0"><FileText size={16} /></div>
                          }
                          <div className="min-w-0">
                            <p className="text-xs font-medium text-accent truncate">{doc.name}</p>
                            <p className="text-[10px] text-text-muted">{doc.size}</p>
                          </div>
                        </div>
                        <button onClick={() => handleRemoveFile(doc.id)}
                          className="text-text-muted hover:text-rose-500 p-1.5 rounded-lg hover:bg-rose-50 transition shrink-0">
                          <Trash2 size={13} />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
                {errors.verification_docs && <p className="text-xs text-rose-500">{errors.verification_docs}</p>}
              </div>

              <div className="space-y-2">
                <p className="text-xs font-semibold text-text-muted uppercase tracking-wide mb-3">
                  Rekening Bank <span className="text-slate-300 font-normal normal-case">(opsional)</span>
                </p>
                <div className="space-y-3 pl-3 border-l-2 border-muted">
                  <FormField label="Nama Bank" name="bank_name" value={form.bank_name}
                    onChange={handleChange} error={errors.bank_name} placeholder="BCA / BNI / Mandiri" required={false} />
                  <FormField label="Nomor Rekening" name="account_number" value={form.account_number}
                    onChange={handleChange} error={errors.account_number} placeholder="1234567890" required={false} />
                  <FormField label="Nama Pemilik Rekening" name="account_name" value={form.account_name}
                    onChange={handleChange} error={errors.account_name} placeholder="Yayasan Harapan Bangsa" required={false} />
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <button onClick={() => { setStep(0); setErrors({}); setApiError(''); }}
                  className="flex-1 border border-muted text-accent hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl transition-colors">
                  ← Kembali
                </button>
                <button onClick={handleSubmit} disabled={loading}
                  className="flex-1 bg-primary hover:bg-primary-hover disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2">
                  {loading ? <><Spinner />Mendaftar...</> : 'Daftar Sekarang'}
                </button>
              </div>
            </div>
          )}

          <p className="text-center text-xs text-text-muted mt-6">
            Sudah punya akun?{' '}
            <Link to="/login" className="text-primary hover:text-primary-hover font-medium">
              Masuk di sini
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}