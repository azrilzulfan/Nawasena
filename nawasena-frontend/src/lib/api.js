// src/lib/api.js

const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://nawasena-backend.test/api';

function getToken() {
  return localStorage.getItem('nawasena_token');
}

function authHeaders() {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${getToken()}`,
    'Accept': 'application/json',
  };
}

async function request(method, path, body = null) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: authHeaders(),
    body: body ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401) {
    localStorage.removeItem('nawasena_token');
    window.location.href = '/login';
    return;
  }

  const data = await res.json();
  if (!res.ok) throw new Error(data.message ?? 'Terjadi kesalahan server');
  return data;
}

export const api = {
  get:   (path)         => request('GET', path),
  post:  (path, body)   => request('POST', path, body),
  put:   (path, body)   => request('PUT', path, body),
  patch: (path, body)   => request('PATCH', path, body),
  del:   (path)         => request('DELETE', path),
};