// src/layouts/FoundationAdminLayout.jsx
import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { api } from '../lib/api';
import FoundationSidebar from '../components/layout/FoundationSidebar';
import FoundationTopbar  from '../components/layout/FoundationTopbar';

import FAOverviewPage      from '../pages/foundation-admin/FAOverviewPage';
import FAInventoriesPage   from '../pages/foundation-admin/FAInventoriesPage';
import FAInventoryAddPage  from '../pages/foundation-admin/FAInventoryAddPage';
import FADonationsPage     from '../pages/foundation-admin/FADonationsPage';
import FAWorkshopsPage     from '../pages/foundation-admin/FAWorkshopsPage';
import FAWorkshopAddPage   from '../pages/foundation-admin/FAWorkshopAddPage';
import FAProfilePage       from '../pages/foundation-admin/FAProfilePage';

export default function FoundationAdminLayout() {
  const { myFoundationId } = useAuth();
  const [activePage,    setActivePage]    = useState('fa-overview');
  const [sidebarOpen,   setSidebarOpen]   = useState(false);
  const [foundationName, setFoundationName] = useState('');

  useEffect(() => {
    if (!myFoundationId) return;
    api.get(`/foundations/${myFoundationId}`)
      .then(data => setFoundationName(data.name))
      .catch(() => {});
  }, [myFoundationId]);

  const renderPage = () => {
    switch (activePage) {
      case 'fa-overview':      return <FAOverviewPage />;
      case 'fa-inventories':   return <FAInventoriesPage />;
      case 'fa-inventory-add': return <FAInventoryAddPage onNavigate={setActivePage} />;
      case 'fa-donations':     return <FADonationsPage />;
      case 'fa-workshops':     return <FAWorkshopsPage onNavigate={setActivePage} />;
      case 'fa-workshop-add':  return <FAWorkshopAddPage onNavigate={setActivePage} />;
      case 'fa-profile':       return <FAProfilePage />;
      default:                 return <FAOverviewPage />;
    }
  };

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      <FoundationSidebar
        activePage={activePage}
        onNavigate={setActivePage}
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        foundationName={foundationName}
      />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <FoundationTopbar
          activePage={activePage}
          onMenuToggle={() => setSidebarOpen(o => !o)}
        />
        <main className="flex-1 overflow-y-auto p-4 md:p-6">
          {renderPage()}
        </main>
      </div>
    </div>
  );
}