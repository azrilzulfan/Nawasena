// src/features/foundation-admin/layouts/FoundationAdminLayout.jsx
import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import { useAuth } from '../../../context/AuthContext';
import FoundationSidebar  from '../components/FoundationSidebar';
import FoundationTopbar   from '../components/FoundationTopbar';
import VerificationBanner from '../components/VerificationBanner';

export default function FoundationAdminLayout() {
  const { foundation } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      <FoundationSidebar
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        foundationName={foundation?.name}
      />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <VerificationBanner />
        <FoundationTopbar
          onMenuToggle={() => setSidebarOpen(o => !o)}
        />
        <main className="flex-1 overflow-y-auto p-4 md:p-6">
          <Outlet /> 
        </main>
      </div>
    </div>
  );
}