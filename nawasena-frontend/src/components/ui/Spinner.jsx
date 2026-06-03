// src/components/ui/Spinner.jsx
export default function Spinner({ size = 'sm' }) {
  const dim = size === 'sm' ? 'w-4 h-4' : 'w-5 h-5';
  return (
    <div className={`${dim} border-2 border-white border-t-transparent rounded-full animate-spin`} />
  );
}