// src/components/ui/Pagination.jsx
export default function Pagination({ meta, page, onPageChange }) {
  if (!meta || meta.last_page <= 1) return null;

  return (
    <div className="px-5 py-3 border-t border-muted flex items-center justify-between">
      <button
        disabled={page <= 1}
        onClick={() => onPageChange(page - 1)}
        className="text-xs px-3 py-1.5 border border-muted rounded-lg disabled:opacity-40 hover:bg-slate-50 text-accent"
      >
        ← Sebelumnya
      </button>
      <span className="text-xs text-text-muted">{meta.current_page} / {meta.last_page}</span>
      <button
        disabled={page >= meta.last_page}
        onClick={() => onPageChange(page + 1)}
        className="text-xs px-3 py-1.5 border border-muted rounded-lg disabled:opacity-40 hover:bg-slate-50 text-accent"
      >
        Berikutnya →
      </button>
    </div>
  );
}