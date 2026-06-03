// src/components/ui/FormField.jsx
import { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';

export default function FormField({
  label, name, type = 'text', value, onChange, error,
  placeholder, hint, required = true, children,
}) {
  const [show, setShow] = useState(false);
  const isPassword = type === 'password';

  return (
    <div>
      <label className="block text-xs font-medium text-text-muted mb-1.5">
        {label} {required && <span className="text-rose-400">*</span>}
      </label>
      {children ?? (
        <div className="relative">
          <input
            type={isPassword ? (show ? 'text' : 'password') : type}
            name={name}
            value={value}
            onChange={onChange}
            placeholder={placeholder}
            required={required}
            className={`w-full border rounded-xl px-4 py-2.5 text-sm text-accent outline-none transition
              focus:ring-2 focus:border-transparent
              ${isPassword ? 'pr-10' : ''}
              ${error
                ? 'border-rose-300 focus:ring-rose-300 bg-rose-50'
                : 'border-muted focus:ring-primary bg-white'
              }`}
          />
          {isPassword && (
            <button
              type="button"
              onClick={() => setShow(s => !s)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-accent"
            >
              {show ? <EyeOff size={15} /> : <Eye size={15} />}
            </button>
          )}
        </div>
      )}
      {error && <p className="mt-1 text-xs text-rose-500">{error}</p>}
      {hint && !error && <p className="mt-1 text-xs text-text-muted">{hint}</p>}
    </div>
  );
}