// src/layouts/SuperAdminLayout.jsx
import { useState } from 'react';
import Sidebar from '../components/layout/Sidebar';
import Topbar  from '../components/layout/Topbar';

import OverviewPage            from '../pages/OverviewPage';
import VerificationQueuePage   from '../pages/foundations/VerificationQueuePage';
import FoundationListPage      from '../pages/foundations/FoundationListPage';
import FoundationAnalyticsPage from '../pages/foundations/FoundationAnalyticsPage';
import DonorsPage              from '../pages/users/DonorsPage';
import VolunteersPage          from '../pages/users/VolunteersPage';
import FoundationAdminsPage    from '../pages/users/FoundationAdminsPage';
import GlobalInventoriesPage   from '../pages/logistics/GlobalInventoriesPage';
import DonationLedgerPage      from '../pages/logistics/DonationLedgerPage';
import WorkshopMonitorPage     from '../pages/workshops/WorkshopMonitorPage';
import ProfilePage             from '../pages/settings/ProfilePage';

const PAGES = {
  'overview':              <OverviewPage />,
  'foundation-queue':      <VerificationQueuePage />,
  'foundation-list':       <FoundationListPage />,
  'foundation-analytics':  <FoundationAnalyticsPage />,
  'donors':                <DonorsPage />,
  'volunteers':            <VolunteersPage />,
  'foundation-admins':     <FoundationAdminsPage />,
  'inventories':           <GlobalInventoriesPage />,
  'donations':             <DonationLedgerPage />,
  'workshops':             <WorkshopMonitorPage />,
  'profile':               <ProfilePage />,
};

export default function SuperAdminLayout() {
  const [activePage,  setActivePage]  = useState('overview');
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      <Sidebar
        activePage={activePage}
        onNavigate={setActivePage}
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <Topbar activePage={activePage} onMenuToggle={() => setSidebarOpen(o => !o)} />
        <main className="flex-1 overflow-y-auto p-4 md:p-6">
          {PAGES[activePage] ?? <OverviewPage />}
        </main>
      </div>
    </div>
  );
}