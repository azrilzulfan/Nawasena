// src/components/ui/StatCard.jsx

const colorMap = {
  emerald: 'bg-emerald-50 text-emerald-600',
  amber:   'bg-amber-50 text-amber-600',
  rose:    'bg-rose-50 text-rose-600',
  blue:    'bg-blue-50 text-blue-600',
};

export default function StatCard({ icon: Icon, label, value, sub, color = 'emerald' }) {
  return (
    <div className="bg-white rounded-2xl border border-muted p-5 flex items-center gap-4 shadow-sm">
      <div className={`p-3 rounded-xl ${colorMap[color]}`}>
        <Icon size={22} />
      </div>
      <div>
        <p className="text-xs text-text-muted font-medium">{label}</p>
        <p className="text-2xl font-bold text-accent">{value ?? '—'}</p>
        {sub && <p className="text-xs text-text-muted mt-0.5">{sub}</p>}
      </div>
    </div>
  );
}