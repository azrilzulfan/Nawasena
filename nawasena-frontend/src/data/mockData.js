// src/data/mockData.js

// --- CHART DATA ---
export const donationTrendData = [
  { month: 'Jan', total: 12 }, { month: 'Feb', total: 19 },
  { month: 'Mar', total: 14 }, { month: 'Apr', total: 28 },
  { month: 'Mei', total: 23 }, { month: 'Jun', total: 35 },
];

export const inventoryCategoryData = [
  { name: 'Logistik', value: 42, fill: '#10b981' },
  { name: 'Edukasi',  value: 31, fill: '#3b82f6' },
  { name: 'Medis',    value: 27, fill: '#f59e0b' },
];

// --- FOUNDATIONS ---
export const mockFoundations = [
  {
    _id: 'f1', name: 'Panti Asuhan Harapan Bangsa', address: 'Jl. Merdeka No.12, Jakarta',
    contact_phone: '0812-0001-0001', is_verified: true,
    location: { type: 'Point', coordinates: [106.8272, -6.1751] }, admin_id: 'u3', created_at: '2024-01-10',
  },
  {
    _id: 'f2', name: 'Panti Al-Ikhlas Surabaya', address: 'Jl. Pahlawan No.5, Surabaya',
    contact_phone: '0812-0002-0002', is_verified: true,
    location: { type: 'Point', coordinates: [112.7376, -7.2575] }, admin_id: 'u4', created_at: '2024-02-15',
  },
  {
    _id: 'f3', name: 'Yayasan Cahaya Anak Nusantara', address: 'Jl. Imam Bonjol No.9, Bandung',
    contact_phone: '0812-0003-0003', is_verified: false,
    location: { type: 'Point', coordinates: [107.6191, -6.9175] }, admin_id: 'u5', created_at: '2024-06-01',
  },
];

// --- USERS ---
export const mockUsers = [
  { _id: 'u1', full_name: 'Andi Pratama', email: 'andi@mail.com', role: 'donor', created_at: '2024-03-01', avatar_url: null },
  { _id: 'u2', full_name: 'Siti Rahayu', email: 'siti@mail.com', role: 'donor', created_at: '2024-03-15', avatar_url: null },
  {
    _id: 'v1', full_name: 'Budi Santoso', email: 'budi@mail.com', role: 'volunteer', created_at: '2024-04-01',
    volunteer_profile: { skills: ['Mengajar', 'Desain Grafis'], volunteer_hours: 120, workshops_attended: 8 },
  },
  {
    _id: 'v2', full_name: 'Dewi Lestari', email: 'dewi@mail.com', role: 'volunteer', created_at: '2024-04-20',
    volunteer_profile: { skills: ['Medis', 'Konseling'], volunteer_hours: 85, workshops_attended: 5 },
  },
  { _id: 'u3', full_name: 'Ahmad Fauzi', email: 'ahmad@mail.com', role: 'foundation_admin', created_at: '2024-01-10', managed_foundation_id: 'f1' },
  { _id: 'u4', full_name: 'Rina Wulandari', email: 'rina@mail.com', role: 'foundation_admin', created_at: '2024-02-15', managed_foundation_id: 'f2' },
];

// --- INVENTORIES ---
export const mockInventories = [
  { _id: 'i1', foundation_id: 'f1', item_name: 'Beras 5kg', category: 'Logistik', unit: 'karung', target_qty: 100, current_qty: 12, urgent_level: 'high', description: 'Stok hampir habis' },
  { _id: 'i2', foundation_id: 'f1', item_name: 'Buku Pelajaran SD', category: 'Edukasi', unit: 'paket', target_qty: 50, current_qty: 30, urgent_level: 'medium' },
  { _id: 'i3', foundation_id: 'f2', item_name: 'Obat P3K', category: 'Medis', unit: 'kotak', target_qty: 30, current_qty: 5, urgent_level: 'high' },
  { _id: 'i4', foundation_id: 'f2', item_name: 'Seragam Sekolah', category: 'Edukasi', unit: 'set', target_qty: 40, current_qty: 38, urgent_level: 'low' },
  { _id: 'i5', foundation_id: 'f1', item_name: 'Minyak Goreng', category: 'Logistik', unit: 'liter', target_qty: 60, current_qty: 25, urgent_level: 'medium' },
];

// --- DONATIONS ---
export const mockDonations = [
  {
    _id: 'd1', donor_id: 'u1', foundation_id: 'f1', inventory_id: 'i1',
    type: 'goods', item_detail: { name: 'Beras 5kg', qty: 10, unit: 'karung' },
    status: 'verified', is_anonymous: false, created_at: '2024-06-10',
  },
  {
    _id: 'd2', donor_id: 'u2', foundation_id: 'f2', inventory_id: 'i3',
    type: 'goods', item_detail: { name: 'Obat P3K', qty: 5, unit: 'kotak' },
    status: 'pending', is_anonymous: true, created_at: '2024-06-18',
  },
  {
    _id: 'd3', donor_id: 'u1', foundation_id: 'f1', inventory_id: 'i2',
    type: 'money', item_detail: { name: 'Dana Pendidikan', qty: 500000, unit: 'IDR' },
    status: 'sent', is_anonymous: false, created_at: '2024-06-20',
  },
  {
    _id: 'd4', donor_id: 'u2', foundation_id: 'f2', inventory_id: 'i4',
    type: 'goods', item_detail: { name: 'Seragam Sekolah', qty: 3, unit: 'set' },
    status: 'received', is_anonymous: false, created_at: '2024-06-22',
  },
];

// --- WORKSHOPS ---
export const mockWorkshops = [
  {
    _id: 'w1', foundation_id: 'f1', title: 'Pelatihan Baca Tulis untuk Relawan',
    description: 'Workshop intensif untuk relawan pengajar.', event_date: '2024-07-15T08:00:00Z',
    status: 'open', mentor_needed: 10, mentor_registered_count: 7,
  },
  {
    _id: 'w2', foundation_id: 'f2', title: 'Seminar Kesehatan Anak',
    description: 'Edukasi gizi dan sanitasi dasar.', event_date: '2024-07-20T09:00:00Z',
    status: 'open', mentor_needed: 5, mentor_registered_count: 5,
  },
  {
    _id: 'w3', foundation_id: 'f1', title: 'Workshop Kreativitas Seni',
    description: 'Menggambar dan kerajinan tangan.', event_date: '2024-06-01T08:00:00Z',
    status: 'finished', mentor_needed: 4, mentor_registered_count: 4,
  },
];

// --- CURRENT ADMIN ---
export const mockCurrentAdmin = {
  _id: 'admin1', full_name: 'Super Admin Nawasena', email: 'superadmin@nawasena.id',
  role: 'admin', avatar_url: null,
};