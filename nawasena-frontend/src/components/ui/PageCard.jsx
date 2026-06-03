// src/components/ui/PageCard.jsx
export default function PageCard({ title, count, actions, children, overflow = true }) {
  return (
    <div className={`bg-white rounded-2xl border border-muted shadow-sm ${overflow ? 'overflow-hidden' : ''}`}>
      {(title || actions) && (
        <div className="px-5 py-4 border-b border-muted flex items-center justify-between">
          <p className="font-semibold text-accent">
            {title}
            {count !== undefined && (
              <span className="text-text-muted font-normal text-sm ml-1">({count})</span>
            )}
          </p>
          {actions}
        </div>
      )}
      {children}
    </div>
  );
}