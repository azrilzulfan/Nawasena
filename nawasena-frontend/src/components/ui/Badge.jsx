// src/components/ui/Badge.jsx

const variantMap = {
  pending:  'bg-amber-100 text-amber-700 border border-amber-200',
  sent:     'bg-blue-100 text-blue-700 border border-blue-200',
  received: 'bg-indigo-100 text-indigo-700 border border-indigo-200',
  verified: 'bg-emerald-100 text-emerald-700 border border-emerald-200',
  open:     'bg-emerald-100 text-emerald-700 border border-emerald-200',
  closed:   'bg-zinc-100 text-zinc-500 border border-zinc-200',
  finished: 'bg-slate-100 text-slate-500 border border-slate-200',
  high:     'bg-rose-100 text-rose-700 border border-rose-200',
  medium:   'bg-amber-100 text-amber-700 border border-amber-200',
  low:      'bg-emerald-100 text-emerald-700 border border-emerald-200',
};

const labelMap = {
  pending: 'Pending', sent: 'Dikirim', received: 'Diterima', verified: 'Terverifikasi',
  open: 'Buka', closed: 'Tutup', finished: 'Selesai',
  high: 'Tinggi', medium: 'Sedang', low: 'Rendah',
};

export default function Badge({ value }) {
  const cls = variantMap[value] ?? 'bg-zinc-100 text-zinc-600';
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${cls}`}>
      {labelMap[value] ?? value}
    </span>
  );
}