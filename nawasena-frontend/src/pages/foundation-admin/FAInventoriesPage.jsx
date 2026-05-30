// src/pages/foundation-admin/FAInventoriesPage.jsx
import { useState, useEffect, useCallback } from 'react';
import { Pencil, Trash2, X, Check } from 'lucide-react';
import Badge from '../../components/ui/Badge';
import ProgressBar from '../../components/ui/ProgressBar';
import ErrorState from '../../components/ui/ErrorState';
import { SkeletonRow } from '../../components/ui/Skeleton';
import { api } from '../../lib/api';
import { useAuth } from '../../context/AuthContext';

const CATEGORIES    = ['Logistik', 'Edukasi', 'Medis'];
const URGENCY_OPTS  = ['low', 'medium', 'high'];

function EditModal({ item, onClose, onSaved }) {
  const [form, setForm]     = useState({
    item_name:    item.item_name,
    category:     item.category,
    unit:         item.unit,
    target_qty:   item.target_qty,
    current_qty:  item.current_qty,
    urgent_level: item.urgent_level,
    description:  item.description ?? '',
  });
  const [saving, setSaving] = useState(false);
  const [error,  setError]  = useState('');

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(p => ({ ...p, [name]: ['target_qty', 'current_qty'].includes(name) ? Number(value) : value }));
  };

  const handleSave = async () => {
    setSaving(true);
    setError('');
    try {
      await api.put(`/inventories/${item._id}`, form);
      onSaved();
      onClose();
    } catch (err) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-6">
        <div className="flex items-center justify-between mb-5">
          <p className="font-semibold text-slate-800">Edit Item Inventori</p>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600"><X size={18} /></button>
        </div>

        {error && <p className="mb-4 text-xs text-rose-500 bg-rose-50 px-3 py-2 rounded-lg">{error}</p>}

        <div className="space-y-3">
          <div>
            <label className="block text-xs font-medium text-slate-500 mb-1">Nama Item</label>
            <input name="item_name" value={form.item_name} onChange={handleChange}
              className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500" />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1">Kategori</label>
              <select name="category" value={form.category} onChange={handleChange}
                className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500">
                {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1">Satuan</label>
              <input name="unit" value={form.unit} onChange={handleChange}
                className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1">Stok Saat Ini</label>
              <input type="number" name="current_qty" value={form.current_qty} onChange={handleChange} min={0}
                className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-500 mb-1">Target</label>
              <input type="number" name="target_qty" value={form.target_qty} onChange={handleChange} min={1}
                className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
          </div>
          <div>
            <label className="block text-xs font-medium text-slate-500 mb-1">Tingkat Urgensi</label>
            <select name="urgent_level" value={form.urgent_level} onChange={handleChange}
              className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500">
              {URGENCY_OPTS.map(o => <option key={o} value={o}>{o}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-xs font-medium text-slate-500 mb-1">Deskripsi</label>
            <textarea name="description" value={form.description} onChange={handleChange} rows={2}
              className="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm outline-none resize-none focus:ring-2 focus:ring-blue-500" />
          </div>
        </div>

        <div className="flex gap-3 mt-5">
          <button onClick={onClose}
            className="flex-1 border border-slate-200 text-slate-600 hover:bg-slate-50 text-sm font-medium py-2.5 rounded-xl">
            Batal
          </button>
          <button onClick={handleSave} disabled={saving}
            className="flex-1 bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white text-sm font-medium py-2.5 rounded-xl flex items-center justify-center gap-2">
            {saving
              ? <><div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />Menyimpan...</>
              : <><Check size={14} />Simpan</>
            }
          </button>
        </div>
      </div>
    </div>
  );
}

export default function FAInventoriesPage() {
  const { myFoundationId } = useAuth();
  const [items,     setItems]    = useState([]);
  const [loading,   setLoading]  = useState(true);
  const [error,     setError]    = useState(null);
  const [editItem,  setEditItem] = useState(null);
  const [deleting,  setDeleting] = useState(null);

  const load = useCallback(async () => {
    if (!myFoundationId) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.get(`/foundations/${myFoundationId}/inventories`);
      setItems(Array.isArray(data) ? data : data.data ?? []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [myFoundationId]);

  useEffect(() => { load(); }, [load]);

  const handleDelete = async (id) => {
    if (!confirm('Hapus item ini dari daftar kebutuhan?')) return;
    setDeleting(id);
    try {
      await api.del(`/inventories/${id}`);
      setItems(prev => prev.filter(i => i._id !== id));
    } catch (err) {
      alert(err.message);
    } finally {
      setDeleting(null);
    }
  };

  return (
    <>
      {editItem && (
        <EditModal item={editItem} onClose={() => setEditItem(null)} onSaved={load} />
      )}

      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
          <p className="font-semibold text-slate-800">
            Daftar Kebutuhan
            {!loading && <span className="text-slate-400 font-normal text-sm ml-1">({items.length})</span>}
          </p>
        </div>

        {error ? (
          <ErrorState message={error} onRetry={load} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-xs text-slate-500 uppercase tracking-wide">
                <tr>
                  <th className="text-left px-5 py-3">Item</th>
                  <th className="text-left px-5 py-3 hidden md:table-cell">Kategori</th>
                  <th className="text-left px-5 py-3">Progress</th>
                  <th className="text-left px-5 py-3 hidden lg:table-cell">Urgensi</th>
                  <th className="text-left px-5 py-3">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {loading
                  ? [...Array(4)].map((_, i) => <SkeletonRow key={i} cols={5} />)
                  : items.map(item => (
                    <tr key={item._id}
                      className={`transition-colors ${item.urgent_level === 'high' ? 'bg-rose-50 hover:bg-rose-100' : 'hover:bg-slate-50'}`}
                    >
                      <td className="px-5 py-3.5">
                        <p className="font-medium text-slate-800">{item.item_name}</p>
                        <p className="text-xs text-slate-400">{item.unit}</p>
                      </td>
                      <td className="px-5 py-3.5 text-slate-500 hidden md:table-cell">{item.category}</td>
                      <td className="px-5 py-3.5 min-w-35">
                        <ProgressBar current={item.current_qty} total={item.target_qty} />
                      </td>
                      <td className="px-5 py-3.5 hidden lg:table-cell">
                        <Badge value={item.urgent_level} />
                      </td>
                      <td className="px-5 py-3.5">
                        <div className="flex items-center gap-1.5">
                          <button onClick={() => setEditItem(item)}
                            className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                            <Pencil size={14} />
                          </button>
                          <button
                            onClick={() => handleDelete(item._id)}
                            disabled={deleting === item._id}
                            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors disabled:opacity-40">
                            <Trash2 size={14} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                }
              </tbody>
            </table>
          </div>
        )}
      </div>
    </>
  );
}