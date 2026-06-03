// src/features/foundation-admin/pages/FAQrScanPage.jsx
import { useState, useEffect, useRef, useCallback } from 'react';
import { Html5Qrcode } from 'html5-qrcode';
import {
  QrCode, CheckCircle2, XCircle, RotateCcw,
  Package, Hash, Calendar, ArrowRight,
  ScanLine, AlertTriangle, Video, VideoOff
} from 'lucide-react';
import VerifiedGate from '../../auth/components/VerifiedGate';
import Spinner      from '../../../components/ui/Spinner';
import { api }      from '../../../lib/api';

const STATUS_META = {
  pending:  { label: 'Menunggu',      color: 'text-amber-600',  bg: 'bg-amber-50',  border: 'border-amber-200' },
  sent:     { label: 'Dikirim',       color: 'text-primary',   bg: 'bg-blue-50',   border: 'border-blue-200'  },
  received: { label: 'Diterima',      color: 'text-indigo-600', bg: 'bg-indigo-50', border: 'border-indigo-200'},
  verified: { label: 'Terverifikasi', color: 'text-emerald-600',bg: 'bg-emerald-50',border: 'border-emerald-200'},
};

// ─── Sub-komponen: Kamera Scanner Terisolasi (Aman & Stabil) ─────────────────

function CameraScanner({ onScanSuccess }) {
  // Ubah default awal menjadi false agar tidak otomatis menyala saat pindah page
  const [isCameraActive, setIsCameraActive] = useState(false);
  const [cameraReady, setCameraReady] = useState(false);
  const [scanError, setScanError] = useState('');
  const html5QrcodeRef = useRef(null);
  const isMounted = useRef(true);

  // Fungsi internal mematikan kamera secara bersih ke sistem operasi
  const stopScanningSafely = async (instance) => {
    if (instance && instance.isScanning) {
      try {
        await instance.stop();
      } catch (err) {
        console.error("Gagal menghentikan track kamera:", err);
      }
    }
  };

  // Fungsi internal menghidupkan kamera
  const startScanning = useCallback(async (instance) => {
    if (!instance) return;
    setCameraReady(false);
    setScanError('');
    
    try {
      const element = document.getElementById("camera-reader");
      if (!element) return;

      await instance.start(
        { facingMode: "environment" },
        {
          fps: 15,
          qrbox: (width, height) => {
            const minEdge = Math.min(width, height);
            const size = Math.max(Math.floor(minEdge * 0.65), 150);
            return { width: size, height: size };
          },
        },
        (decodedText) => {
          if (isMounted.current) {
            stopScanningSafely(instance).then(() => {
              onScanSuccess(decodedText.trim());
            });
          }
        },
        () => { /* Silent tracking frame */ }
      );
      
      if (isMounted.current) setCameraReady(true);
    } catch (err) {
      if (isMounted.current) {
        setScanError("Kamera tidak ditemukan atau izin akses ditolak browser.");
        console.error(err);
      }
    }
  }, [onScanSuccess]);

  // Efek Lifecycle: Mengatur kapan instance dibuat & dihancurkan
  useEffect(() => {
    isMounted.current = true;
    
    // Instance HANYA dibuat jika status aktif (elemen div sudah masuk ke DOM)
    if (isCameraActive) {
      const html5Qrcode = new Html5Qrcode("camera-reader");
      html5QrcodeRef.current = html5Qrcode;
      startScanning(html5Qrcode);
    }

    return () => {
      isMounted.current = false;
      if (html5QrcodeRef.current) {
        stopScanningSafely(html5QrcodeRef.current);
      }
    };
  }, [isCameraActive, startScanning]);

  // Handler klik tombol: Menjamin STOP selesai sebelum ELEMEN hilang
  const toggleCamera = async () => {
    if (isCameraActive) {
      setCameraReady(false);
      // 1. Stop streaming hardware terlebih dahulu
      await stopScanningSafely(html5QrcodeRef.current);
      html5QrcodeRef.current = null;
      
      // 2. Setelah hardware lepas, barulah hilangkan elemen dari DOM (Lampu LED Mati Total)
      if (isMounted.current) {
        setIsCameraActive(false);
      }
    } else {
      setIsCameraActive(true);
    }
  };

  return (
    <div className="space-y-4">
      {/* Tombol Navigasi Kontrol Daya Kamera */}
      <div className="flex justify-center">
        <button
          type="button"
          onClick={toggleCamera}
          className={`flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-xl shadow-sm transition-all border ${
            isCameraActive
              ? 'bg-rose-50 text-rose-600 border-rose-200 hover:bg-rose-100'
              : 'bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100'
          }`}
        >
          {isCameraActive ? (
            <><VideoOff size={14} /> Matikan Kamera</>
          ) : (
            <><Video size={14} /> Nyalakan Kamera</>
          )}
        </button>
      </div>

      {/* Box Pembungkus Scanner */}
      <div className="relative w-full max-w-sm mx-auto aspect-square bg-slate-900 rounded-2xl overflow-hidden shadow-inner border border-slate-800 flex items-center justify-center">
        
        {/* JAMINAN PRIVASI: Elemen benar-benar di-unmount jika nonaktif, memaksa LED padam */}
        {isCameraActive ? (
          <div id="camera-reader" className="w-full h-full object-cover"></div>
        ) : (
          <div className="absolute inset-0 bg-slate-950 flex flex-col items-center justify-center p-6 text-center gap-2.5">
            <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center text-slate-400">
              <VideoOff size={16} />
            </div>
            <p className="text-xs font-semibold text-slate-400">Kamera Dinonaktifkan</p>
            <p className="text-[11px] text-slate-500 max-w-[200px]">Klik tombol di atas untuk menyalakan webcam pemindai.</p>
          </div>
        )}

        {/* Layar Loading saat Membuka Jalur Kamera */}
        {isCameraActive && !cameraReady && !scanError && (
          <div className="absolute inset-0 bg-slate-900 flex flex-col items-center justify-center gap-2 text-slate-400">
            <Spinner size="md" />
            <p className="text-xs font-medium">Mengaktifkan perangkat webcam...</p>
          </div>
        )}

        {/* Overlay Animasi Laser Scanner */}
        {isCameraActive && cameraReady && !scanError && (
          <div className="absolute inset-0 pointer-events-none flex flex-col items-center justify-center">
            <div className="w-[65%] h-[65%] border-2 border-primary rounded-xl relative shadow-[0_0_0_400px_rgba(15,23,42,0.55)]">
              <div className="absolute top-0 left-0 w-full h-[2px] bg-gradient-to-r from-transparent via-primary to-transparent animate-[bounce_2s_infinite] shadow-[0_0_8px_#3b82f6]" />
            </div>
            <span className="absolute bottom-6 text-[11px] font-medium text-white/80 bg-slate-950/60 px-3 py-1 rounded-full backdrop-blur-sm tracking-wide">
              Memindai QR Code...
            </span>
          </div>
        )}

        {/* Notifikasi Tampilan Jika Izin Kamera Ditolak */}
        {isCameraActive && scanError && (
          <div className="absolute inset-0 bg-slate-900 p-6 flex flex-col items-center justify-center text-center gap-3">
            <div className="w-12 h-12 rounded-xl bg-rose-500/10 flex items-center justify-center text-rose-500">
              <AlertTriangle size={24} />
            </div>
            <p className="text-xs font-medium text-slate-300 leading-relaxed max-w-xs">{scanError}</p>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── Sub-komponen: Wadah Induk Halaman Scanner ───────────────────────────────

function QrScannerContainer({ onScanSuccess, loading }) {
  return (
    <div className="max-w-lg mx-auto font-sans">
      <div className="flex flex-col items-center mb-6">
        <div className="w-16 h-16 rounded-2xl bg-primary flex items-center justify-center mb-3 shadow-lg shadow-blue-100">
          <QrCode size={30} className="text-white" />
        </div>
        <h2 className="text-xl font-bold text-slate-800">Verifikasi QR Donasi</h2>
        <p className="text-xs text-slate-400 mt-1 text-center max-w-sm">
          Arahkan QR Code donatur dari aplikasi mobile Nawasena ke kamera laptop Anda untuk pembaruan stok instan.
        </p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
        {loading ? (
          <div className="py-20 flex flex-col items-center justify-center gap-3">
            <Spinner size="lg" />
            <p className="text-sm font-medium text-slate-500">Memproses verifikasi data...</p>
          </div>
        ) : (
          <div className="space-y-4">
            <CameraScanner onScanSuccess={onScanSuccess} />
            <p className="text-center text-[11px] text-slate-400">
              *Pastikan ruangan memiliki cahaya yang cukup agar pola kode QR terbaca dengan akurat.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

// ─── Sub-komponen: Detail Informasi Baris ───────────────────────────────────

function DetailRow({ icon: Icon, label, value, mono = false }) {
  return (
    <div className="flex items-start gap-3 py-3 border-b border-slate-50 last:border-0">
      <div className="w-7 h-7 rounded-lg bg-slate-100 flex items-center justify-center shrink-0 mt-0.5">
        <Icon size={13} className="text-slate-500" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-xs text-slate-400 mb-0.5">{label}</p>
        <p className={`text-sm font-medium text-slate-800 ${mono ? 'font-mono break-all' : ''}`}>
          {value ?? '—'}
        </p>
      </div>
    </div>
  );
}

// ─── Sub-komponen: Hasil Sukses ────────────────────────────────────────────────

function SuccessResult({ donation, onReset }) {
  const item      = donation.item_detail ?? {};
  const statusMeta = STATUS_META[donation.status] ?? STATUS_META.verified;
  const lastLog   = donation.history_logs?.at(-1);

  return (
    <div className="max-w-lg mx-auto space-y-4 font-sans">
      <div className="bg-emerald-600 rounded-2xl p-6 text-center">
        <div className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mx-auto mb-3">
          <CheckCircle2 size={36} className="text-white" />
        </div>
        <h2 className="text-xl font-bold text-white mb-1">Donasi Terverifikasi!</h2>
        <p className="text-sm text-emerald-100">Stok inventori telah diperbarui secara otomatis.</p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-50">
          <p className="text-sm font-semibold text-slate-800">Ringkasan Donasi</p>
        </div>
        <div className="px-5">
          <DetailRow icon={Package} label="Item Donasi" value={`${item.qty ?? 0}x ${item.name ?? '—'} (${item.unit ?? ''})`} />
          <DetailRow icon={Hash} label="ID Donasi" value={donation._id || donation.id} mono />
          <DetailRow
            icon={Calendar}
            label="Waktu Verifikasi"
            value={lastLog?.timestamp ? new Date(lastLog.timestamp).toLocaleString('id-ID') : new Date().toLocaleString('id-ID')}
          />
        </div>
      </div>

      <div className={`rounded-2xl border border-slate-100 px-5 py-4 flex items-center gap-3 ${statusMeta.bg} ${statusMeta.border}`}>
        <CheckCircle2 size={18} className={statusMeta.color} />
        <div>
          <p className={`text-sm font-semibold ${statusMeta.color}`}>Status: {statusMeta.label}</p>
          <p className="text-xs text-slate-500 mt-0.5">{lastLog?.note ?? 'Barang terverifikasi via QR Code'}</p>
        </div>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-2xl px-5 py-4 flex items-start gap-3">
        <ArrowRight size={16} className="text-primary shrink-0 mt-0.5" />
        <p className="text-sm text-blue-700">
          Stok <strong>{item.name}</strong> pada inventori yayasan Anda telah bertambah{' '}
          <strong>{item.qty ?? 0} {item.unit}</strong> secara otomatis.
        </p>
      </div>

      <button
        onClick={onReset}
        className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-primary-hover text-white text-sm font-medium py-2.5 rounded-xl transition-colors"
      >
        <RotateCcw size={14} /> Scan Berikutnya
      </button>
    </div>
  );
}

// ─── Sub-komponen: Hasil Error ─────────────────────────────────────────────────

function ErrorResult({ message, onReset }) {
  const isAlreadyVerified = message?.toLowerCase().includes('already been verified') || message?.toLowerCase().includes('terverifikasi');
  const isNotFound = message?.toLowerCase().includes('not found') || message?.toLowerCase().includes('tidak ditemukan');

  const title = isAlreadyVerified ? 'Donasi Sudah Terverifikasi' : isNotFound ? 'QR Code Tidak Ditemukan' : 'Verifikasi Gagal';
  const hint = isAlreadyVerified ? 'QR code ini sudah pernah diverifikasi sebelumnya.' : message;

  return (
    <div className="max-w-lg mx-auto space-y-4 font-sans">
      <div className={`rounded-2xl p-6 text-center ${isAlreadyVerified ? 'bg-amber-500' : 'bg-rose-500'}`}>
        <div className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mx-auto mb-3">
          {isAlreadyVerified ? <AlertTriangle size={36} className="text-white" /> : <XCircle size={36} className="text-white" />}
        </div>
        <h2 className="text-xl font-bold text-white mb-1">{title}</h2>
        <p className="text-sm text-white/80">{hint}</p>
      </div>

      <button
        onClick={onReset}
        className="w-full flex items-center justify-center gap-2 bg-primary hover:bg-blue-700 text-white text-sm font-medium py-2.5 rounded-xl transition-colors"
      >
        <RotateCcw size={14} /> Coba Lagi
      </button>
    </div>
  );
}

// ─── Komponen Utama Halaman ───────────────────────────────────────────────────

export default function FAQrScanPage() {
  const [phase,    setPhase]    = useState('idle'); // 'idle' | 'loading' | 'success' | 'error'
  const [donation, setDonation] = useState(null);
  const [errMsg,   setErrMsg]   = useState('');

  const handleVerify = useCallback(async (hash) => {
    setPhase('loading');
    try {
      const res = await api.post('/donations/verify-qr', {
        qr_code_hash: hash,
      });
      setDonation(res.donation);
      setPhase('success');
    } catch (err) {
      const errorString = err.response?.data?.message || err.message || 'Verifikasi gagal';
      setErrMsg(errorString);
      setPhase('error');
    }
  }, []);

  const handleReset = useCallback(() => {
    setPhase('idle');
    setDonation(null);
    setErrMsg('');
  }, []);

  return (
    <VerifiedGate showLockedOverlay>
      <div className="py-2">
        {phase === 'idle' || phase === 'loading' ? (
          <QrScannerContainer
            onScanSuccess={handleVerify}
            loading={phase === 'loading'}
          />
        ) : phase === 'success' ? (
          <SuccessResult
            donation={donation}
            onReset={handleReset}
          />
        ) : (
          <ErrorResult
            message={errMsg}
            onReset={handleReset}
          />
        )}
      </div>
    </VerifiedGate>
  );
}