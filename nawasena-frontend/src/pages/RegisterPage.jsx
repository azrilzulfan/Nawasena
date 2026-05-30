// src/pages/RegisterPage.jsx
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { 
  Eye, 
  EyeOff, 
  CheckCircle, 
  AlertCircle, 
  MapPin, 
  UploadCloud, 
  FileText, 
  Trash2 
} from 'lucide-react';

import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';
const DefaultIcon = L.icon({
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = DefaultIcon;

const STEPS = ['Akun', 'Panti', 'Selesai'];

function Field({ label, name, type = 'text', value, onChange, error, placeholder, hint, required = true }) {
  const [show, setShow] = useState(false);
  const isPassword = type === 'password';

  return (
    <div>
      <label className="block text-xs font-medium text-slate-500 mb-1.5">
        {label} {required && <span className="text-rose-400">*</span>}
      </label>
      <div className="relative">
        <input
          type={isPassword ? (show ? 'text' : 'password') : type}
          name={name}
          value={value}
          onChange={onChange}
          placeholder={placeholder}
          required={required}
          className={`w-full border rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none transition
            focus:ring-2 focus:border-transparent pr-${isPassword ? '10' : '4'}
            ${error
              ? 'border-rose-300 focus:ring-rose-300 bg-rose-50'
              : 'border-slate-200 focus:ring-emerald-500 bg-white'
            }`}
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShow(s => !s)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
          >
            {show ? <EyeOff size={15} /> : <Eye size={15} />}
          </button>
        )}
      </div>
      {error && <p className="mt-1 text-xs text-rose-500">{error}</p>}
      {hint && !error && <p className="mt-1 text-xs text-slate-400">{hint}</p>}
    </div>
  );
}

function validateStep1(form) {
  const errors = {};
  if (!form.full_name.trim())       errors.full_name = 'Nama lengkap wajib diisi';
  if (!form.email.trim())           errors.email = 'Email wajib diisi';
  else if (!/\S+@\S+\.\S+/.test(form.email)) errors.email = 'Format email tidak valid';
  if (form.password.length < 8)     errors.password = 'Password minimal 8 karakter';
  if (form.password !== form.password_confirmation)
    errors.password_confirmation = 'Konfirmasi password tidak cocok';
  return errors;
}

function validateStep2(form) {
  const errors = {};
  if (!form.foundation_name.trim())    errors.foundation_name = 'Nama yayasan wajib diisi';
  if (!form.foundation_address.trim()) errors.foundation_address = 'Alamat wajib diisi';
  if (!form.contact_phone.trim())      errors.contact_phone = 'Nomor telepon wajib diisi';
  else if (!/^[0-9+\-\s]{8,15}$/.test(form.contact_phone))
    errors.contact_phone = 'Format nomor telepon tidak valid';
  if (!form.description.trim())        errors.description = 'Deskripsi wajib diisi';
  if (!form.latitude)                  errors.latitude = 'Titik lokasi panti wajib ditentukan';
  if (!form.longitude)                 errors.longitude = 'Titik lokasi panti wajib ditentukan';
  if (form.verification_docs.length === 0) errors.verification_docs = 'Minimal unggah 1 dokumen verifikasi';
  return errors;
}

function MapClickHandler({ onClick }) {
  useMapEvents({
    click: (e) => {
      onClick(e.latlng.lat.toFixed(6), e.latlng.lng.toFixed(6));
    },
  });
  return null;
}

export default function RegisterPage({ onGoLogin }) {
  const { login } = useAuth();

  const [step, setStep] = useState(0);
  const [form, setForm] = useState({
    full_name:             '',
    email:                 '',
    password:              '',
    password_confirmation: '',
    
    foundation_name:    '',
    foundation_address: '',
    contact_phone:      '',
    description:        '',
    latitude:           '-6.200000',
    longitude:          '106.816666',

    verification_docs:   [],

    bank_name:          '',
    account_number:     '',
    account_name:       '',
  });

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
    if (errors.latitude || errors.longitude) {
      setErrors(p => { const n = { ...p }; delete n.latitude; delete n.longitude; return n; });
    }
  };

  const handleMarkerDragEnd = (e) => {
    const latlng = e.target.getLatLng();
    updateCoordinates(latlng.lat.toFixed(6), latlng.lng.toFixed(6));
  };

  const handleFileChange = (e) => {
    const files = Array.from(e.target.files);
    if (files.length === 0) return;

    const newDocs = files.map(file => ({
      id: Math.random().toString(36).substr(2, 9),
      file: file,
      name: file.name,
      size: (file.size / (1024 * 1024)).toFixed(2) + ' MB',
      type: file.type,
      previewUrl: file.type.startsWith('image/') ? URL.createObjectURL(file) : null
    }));

    setForm(p => ({ ...p, verification_docs: [...p.verification_docs, ...newDocs] }));
    if (errors.verification_docs) setErrors(p => { const n = { ...p }; delete n.verification_docs; return n; });
  };

  const handleRemoveFile = (id) => {
    setForm(p => {
      const selectedDoc = p.verification_docs.find(d => d.id === id);
      if (selectedDoc?.previewUrl) URL.revokeObjectURL(selectedDoc.previewUrl);
      return {
        ...p,
        verification_docs: p.verification_docs.filter(d => d.id !== id)
      };
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
      const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://nawasena-backend.test/api';
      const regRes = await fetch(`${BASE_URL}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({
          full_name:             form.full_name,
          email:                 form.email,
          password:              form.password,
          password_confirmation: form.password_confirmation,
          role:                  'foundation_admin',
        }),
      });

      const regData = await regRes.json();
      if (!regRes.ok) {
        if (regData.errors) {
          const mapped = {};
          Object.entries(regData.errors).forEach(([k, v]) => { mapped[k] = v[0]; });
          setErrors(mapped);
          setStep(0); 
        } else {
          setApiError(regData.message ?? 'Registrasi gagal');
        }
        setLoading(false);
        return;
      }

      const token = regData.token;

      const uploadedUrls = [];
      for (const doc of form.verification_docs) {
        const formData = new FormData();
        formData.append('file', doc.file);

        const uploadRes = await fetch(`${BASE_URL}/uploads`, {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Authorization': `Bearer ${token}`,
          },
          body: formData,
        });

        if (!uploadRes.ok) {
          throw new Error(`Gagal mengunggah berkas: ${doc.name}. Silakan coba lagi.`);
        }

        const uploadData = await uploadRes.json();
        const cloudUrl = uploadData.url ?? uploadData.data?.url;
        if (cloudUrl) uploadedUrls.push(cloudUrl);
      }

      const foundationBody = {
        name:         form.foundation_name,
        description:  form.description,
        address:      form.foundation_address,
        contact_phone: form.contact_phone,
        location: {
          type: 'Point',
          coordinates: [parseFloat(form.longitude), parseFloat(form.latitude)],
        },
        verification_docs: uploadedUrls,
        ...(form.bank_name && {
          bank_account: {
            bank_name:      form.bank_name,
            account_number: form.account_number,
            account_name:   form.account_name,
          },
        }),
      };

      const foundRes = await fetch(`${BASE_URL}/foundations`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify(foundationBody),
      });

      if (!foundRes.ok) {
        const foundData = await foundRes.json();
        setApiError(foundData.message ?? 'Pendaftaran yayasan gagal. Akun sudah terbuat, silakan login.');
        setLoading(false);
        return;
      }

      setStep(2);
      setTimeout(async () => {
        try {
          await login(form.email, form.password);
        } catch (_) {
          localStorage.setItem('nawasena_token', token);
          window.location.reload();
        }
      }, 1800);

    } catch (err) {
      console.error("Detail Error Registrasi:", err);
      setApiError(err.message || 'Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    } finally {
      setLoading(false);
    }
  };

  const StepIndicator = () => (
    <div className="flex items-center justify-center gap-0 mb-8">
      {STEPS.map((label, i) => (
        <div key={i} className="flex items-center">
          <div className="flex flex-col items-center">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold transition-colors
              ${i < step  ? 'bg-emerald-600 text-white'
              : i === step ? 'bg-emerald-600 text-white ring-4 ring-emerald-100'
              : 'bg-slate-100 text-slate-400'}`}
            >
              {i < step ? <CheckCircle size={14} /> : i + 1}
            </div>
            <span className={`text-xs mt-1.5 font-medium ${i <= step ? 'text-emerald-600' : 'text-slate-400'}`}>
              {label}
            </span>
          </div>
          {i < STEPS.length - 1 && (
            <div className={`w-16 h-0.5 mb-5 mx-1 transition-colors ${i < step ? 'bg-emerald-500' : 'bg-slate-200'}`} />
          )}
        </div>
      ))}
    </div>
  );

  if (step === 2) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center px-4">
        <div className="w-full max-w-sm text-center">
          <div className="w-16 h-16 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle size={32} className="text-emerald-600" />
          </div>
          <h2 className="text-xl font-bold text-slate-800 mb-2">Pendaftaran Berhasil!</h2>
          <p className="text-sm text-slate-500 mb-1">
            Akun dan yayasan <strong>{form.foundation_name}</strong> telah terdaftar.
          </p>
          <p className="text-sm text-slate-400 mb-6">
            Yayasan Anda sedang menunggu verifikasi dari Super Admin. Anda akan masuk ke dashboard sebentar lagi...
          </p>
          <div className="flex items-center justify-center gap-2 text-emerald-600 text-sm">
            <div className="w-4 h-4 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin" />
            Mengalihkan ke dashboard...
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center px-4 py-10">
      <div className="w-full max-w-md">
        <div className="flex items-center gap-3 mb-8 justify-center">
          <div className="w-10 h-10 rounded-xl bg-emerald-600 flex items-center justify-center">
            <span className="text-white font-bold">N</span>
          </div>
          <div>
            <p className="font-bold text-slate-800 text-lg leading-tight">Nawasena</p>
            <p className="text-xs text-slate-400">Daftar sebagai Pengelola Panti</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 md:p-8">
          <StepIndicator />

          {apiError && (
            <div className="mb-5 flex items-start gap-2.5 px-4 py-3 bg-rose-50 border border-rose-200 rounded-xl">
              <AlertCircle size={16} className="text-rose-500 mt-0.5 shrink-0" />
              <p className="text-sm text-rose-600">{apiError}</p>
            </div>
          )}

          {step === 0 && (
            <div className="space-y-4">
              <div className="mb-5">
                <h2 className="text-lg font-bold text-slate-800">Data Akun</h2>
                <p className="text-sm text-slate-400">Informasi untuk masuk ke dashboard</p>
              </div>

              <Field
                label="Nama Lengkap" name="full_name" value={form.full_name}
                onChange={handleChange} error={errors.full_name}
                placeholder="Ahmad Fauzi"
              />
              <Field
                label="Email" name="email" type="email" value={form.email}
                onChange={handleChange} error={errors.email}
                placeholder="ahmad@yayasan.org"
              />
              <Field
                label="Password" name="password" type="password" value={form.password}
                onChange={handleChange} error={errors.password}
                placeholder="Minimal 8 karakter"
              />
              <Field
                label="Konfirmasi Password" name="password_confirmation" type="password"
                value={form.password_confirmation} onChange={handleChange}
                error={errors.password_confirmation}
                placeholder="Ulangi password"
              />

              <button
                onClick={handleNext}
                className="w-full mt-2 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium py-2.5 rounded-xl transition-colors"
              >
                Lanjutkan →
              </button>
            </div>
          )}

          {step === 1 && (
            <div className="space-y-4">
              <div className="mb-5">
                <h2 className="text-lg font-bold text-slate-800">Data Yayasan</h2>
                <p className="text-sm text-slate-400">Informasi panti asuhan yang Anda kelola</p>
              </div>

              <Field
                label="Nama Yayasan / Panti" name="foundation_name" value={form.foundation_name}
                onChange={handleChange} error={errors.foundation_name}
                placeholder="Yayasan Harapan Bangsa"
              />
              <Field
                label="Alamat Lengkap" name="foundation_address" value={form.foundation_address}
                onChange={handleChange} error={errors.foundation_address}
                placeholder="Jl. Merdeka No.12, Jakarta Pusat"
              />
              <Field
                label="Nomor Telepon" name="contact_phone" type="tel" value={form.contact_phone}
                onChange={handleChange} error={errors.contact_phone}
                placeholder="0812-0000-0000"
              />
              <div>
                <label className="block text-xs font-medium text-slate-500 mb-1.5">
                  Deskripsi Yayasan <span className="text-rose-400">*</span>
                </label>
                <textarea
                  name="description"
                  value={form.description}
                  onChange={handleChange}
                  rows={3}
                  placeholder="Ceritakan singkat tentang yayasan, visi misi, dan anak-anak yang dilayani..."
                  className={`w-full border rounded-xl px-4 py-2.5 text-sm text-slate-700 outline-none resize-none transition
                    focus:ring-2 focus:border-transparent
                    ${errors.description
                      ? 'border-rose-300 focus:ring-rose-300 bg-rose-50'
                      : 'border-slate-200 focus:ring-emerald-500'
                    }`}
                />
                {errors.description && <p className="mt-1 text-xs text-rose-500">{errors.description}</p>}
              </div>
              <div className="space-y-2">
                <label className="block text-xs font-medium text-slate-500">
                  Titik Lokasi Panti Asuhan (OpenStreetMap) <span className="text-rose-400">*</span>
                </label>
                
                <div className="w-full rounded-xl overflow-hidden border border-slate-200 relative bg-slate-50 z-0">
                  <MapContainer 
                    center={[parseFloat(form.latitude), parseFloat(form.longitude)]} 
                    zoom={13} 
                    style={{ width: '100%', height: '240px' }}
                    zoomControl={true}
                  >
                    <TileLayer
                      attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                    />
                    
                    <MapClickHandler onClick={updateCoordinates} />
                    
                    <Marker 
                      position={[parseFloat(form.latitude), parseFloat(form.longitude)]}
                      draggable={true}
                      eventHandlers={{
                        dragend: handleMarkerDragEnd
                      }}
                    />
                  </MapContainer>
                </div>

                <div className="grid grid-cols-2 gap-3 text-[11px] text-slate-500 bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                  <div className="flex items-center gap-1.5">
                    <MapPin size={13} className="text-emerald-600 shrink-0" />
                    <span className="truncate">Lat: <strong className="text-slate-700">{form.latitude}</strong></span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <MapPin size={13} className="text-emerald-600 shrink-0" />
                    <span className="truncate">Lng: <strong className="text-slate-700">{form.longitude}</strong></span>
                  </div>
                </div>
                <p className="text-[10px] text-slate-400">Petunjuk: Klik pada peta atau geser penanda untuk menentukan koordinat panti secara presisi.</p>
              </div>

              <div className="space-y-2">
                <label className="block text-xs font-medium text-slate-500">
                  Dokumen Legalitas / Verifikasi <span className="text-rose-400">*</span>
                </label>
                
                <div className="border-2 border-dashed border-slate-200 hover:border-emerald-500 rounded-xl p-5 text-center cursor-pointer transition relative bg-slate-50/50 hover:bg-slate-50">
                  <input
                    type="file"
                    multiple
                    accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                    onChange={handleFileChange}
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                  />
                  <UploadCloud size={26} className="text-slate-400 mx-auto mb-1.5" />
                  <p className="text-xs font-medium text-slate-700">Pilih berkas dokumen atau drop di sini</p>
                  <p className="text-[10px] text-slate-400 mt-0.5">Mendukung format PDF, Word, atau Gambar (Maks. 5MB)</p>
                </div>

                {form.verification_docs.length > 0 && (
                  <div className="space-y-2 pt-1">
                    <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Berkas Terpilih ({form.verification_docs.length})</p>
                    <div className="max-h-40 overflow-y-auto space-y-2 pr-1">
                      {form.verification_docs.map((doc) => (
                        <div key={doc.id} className="flex items-center justify-between p-2.5 bg-white border border-slate-100 rounded-xl shadow-sm gap-3">
                          <div className="flex items-center gap-2.5 min-w-0">
                            {doc.previewUrl ? (
                              <img src={doc.previewUrl} alt="preview" className="w-8 h-8 object-cover rounded-lg border border-slate-100 shrink-0" />
                            ) : (
                              <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                                <FileText size={16} />
                              </div>
                            )}
                            <div className="min-w-0">
                              <p className="text-xs font-medium text-slate-700 truncate">{doc.name}</p>
                              <p className="text-[10px] text-slate-400">{doc.size}</p>
                            </div>
                          </div>
                          <button
                            type="button"
                            onClick={() => handleRemoveFile(doc.id)}
                            className="text-slate-400 hover:text-rose-500 p-1.5 rounded-lg hover:bg-rose-50 transition shrink-0"
                          >
                            <Trash2 size={13} />
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
                {errors.verification_docs && <p className="text-xs text-rose-500">{errors.verification_docs}</p>}
              </div>

              <div className="pt-2">
                <p className="text-xs font-semibold text-slate-500 uppercase tracking-wide mb-3">
                  Rekening Bank <span className="text-slate-300 font-normal normal-case">(opsional)</span>
                </p>
                <div className="space-y-3 pl-3 border-l-2 border-slate-100">
                  <Field
                    label="Nama Bank" name="bank_name" value={form.bank_name}
                    onChange={handleChange} error={errors.bank_name}
                    placeholder="BCA / BNI / Mandiri" required={false}
                  />
                  <Field
                    label="Nomor Rekening" name="account_number" value={form.account_number}
                    onChange={handleChange} error={errors.account_number}
                    placeholder="1234567890" required={false}
                  />
                  <Field
                    label="Nama Pemilik Rekening" name="account_name" value={form.account_name}
                    onChange={handleChange} error={errors.account_name}
                    placeholder="Yayasan Harapan Bangsa" required={false}
                  />
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  onClick={() => { setStep(0); setErrors({}); setApiError(''); }}
                  className="flex-1 border border-slate-200 text-slate-600 hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl transition-colors"
                >
                  ← Kembali
                </button>
                <button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="flex-1 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2"
                >
                  {loading
                    ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> Mendaftar...</>
                    : 'Daftar Sekarang'
                  }
                </button>
              </div>
            </div>
          )}

          <p className="text-center text-xs text-slate-400 mt-6">
            Sudah punya akun?{' '}
            <button onClick={onGoLogin} className="text-emerald-600 hover:text-emerald-800 font-medium">
              Masuk di sini
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}