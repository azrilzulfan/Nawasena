// src/App.jsx
import { Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import LoginPage from './features/auth/pages/LoginPage';
import RegisterPage from './features/auth/pages/RegisterPage';
import SuperAdminLayout from './layouts/SuperAdminLayout';
import FoundationAdminLayout from './features/foundation-admin/layouts/FoundationAdminLayout';

// Super Admin Pages
import OverviewPage            from './pages/OverviewPage';
import VerificationQueuePage   from './features/foundations/pages/VerificationQueuePage';
import FoundationListPage      from './features/foundations/pages/FoundationListPage';
import FoundationAnalyticsPage from './features/foundations/pages/FoundationAnalyticsPage';
import DonorsPage              from './features/users/pages/DonorsPage';
import VolunteersPage          from './features/users/pages/VolunteersPage';
import FoundationAdminsPage    from './features/users/pages/FoundationAdminsPage';
import GlobalInventoriesPage   from './features/logistics/pages/GlobalInventoriesPage';
import DonationLedgerPage      from './features/logistics/pages/DonationLedgerPage';
import WorkshopMonitorPage     from './features/workshops/pages/WorkshopMonitorPage';
import ProfilePage             from './features/users/pages/ProfilePage';

// Foundation Admin Pages
import FAOverviewPage     from './features/foundation-admin/pages/FAOverviewPage';
import FAInventoriesPage  from './features/foundation-admin/pages/FAInventoriesPage';
import FAInventoryAddPage from './features/foundation-admin/pages/FAInventoryAddPage';
import FADonationsPage    from './features/foundation-admin/pages/FADonationsPage';
import FAQrScanPage       from './features/foundation-admin/pages/FAQrScanPage';
import FAWorkshopsPage    from './features/foundation-admin/pages/FAWorkshopsPage';
import FAWorkshopAddPage  from './features/foundation-admin/pages/FAWorkshopAddPage';
import FAProfilePage      from './features/foundation-admin/pages/FAProfilePage';

function LoadingScreen() {
  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center">
      <div className="flex items-center gap-3 text-slate-400">
        <div className="w-5 h-5 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin" />
        <span className="text-sm">Memuat sesi...</span>
      </div>
    </div>
  );
}

function RequireRole({ role }) {
  const { user, loading } = useAuth();
  if (loading) return <LoadingScreen />;
  if (!user) return <Navigate to="/login" replace />;
  if (user.role !== role) return <Navigate to="/unauthorized" replace />;
  return <Outlet />;
}

function GuestOnly() {
  const { user, loading } = useAuth();
  if (loading) return <LoadingScreen />;
  if (user?.role === 'admin') return <Navigate to="/admin" replace />;
  if (user?.role === 'foundation_admin') return <Navigate to="/fa" replace />;
  return <Outlet />;
}

function UnauthorizedPage() {
  const { logout } = useAuth();
  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center px-4">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8 max-w-sm text-center">
        <p className="font-semibold text-slate-800 mb-2">Akses Terbatas</p>
        <p className="text-sm text-slate-400 mb-5">Akun Anda tidak memiliki akses ke halaman ini.</p>
        <button onClick={logout} className="text-sm text-rose-500 hover:text-rose-700 font-medium">
          Keluar
        </button>
      </div>
    </div>
  );
}

function RootRedirect() {
  const { user, loading } = useAuth();
  if (loading) return <LoadingScreen />;
  if (!user) return <Navigate to="/login" replace />;
  if (user.role === 'admin') return <Navigate to="/admin" replace />;
  if (user.role === 'foundation_admin') return <Navigate to="/fa" replace />;
  return <Navigate to="/unauthorized" replace />;
}

export default function App() {
  return (
    <Routes>
      {/* Root */}
      <Route path="/" element={<RootRedirect />} />

      {/* Auth routes */}
      <Route element={<GuestOnly />}>
        <Route path="/login"    element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
      </Route>

      {/* Super Admin routes */}
      <Route element={<RequireRole role="admin" />}>
        <Route element={<SuperAdminLayout />}>
          <Route index path="/admin"                    element={<OverviewPage />} />
          <Route path="/admin/foundation-queue"         element={<VerificationQueuePage />} />
          <Route path="/admin/foundation-list"          element={<FoundationListPage />} />
          <Route path="/admin/foundation-analytics"     element={<FoundationAnalyticsPage />} />
          <Route path="/admin/donors"                   element={<DonorsPage />} />
          <Route path="/admin/volunteers"               element={<VolunteersPage />} />
          <Route path="/admin/foundation-admins"        element={<FoundationAdminsPage />} />
          <Route path="/admin/inventories"              element={<GlobalInventoriesPage />} />
          <Route path="/admin/donations"                element={<DonationLedgerPage />} />
          <Route path="/admin/workshops"                element={<WorkshopMonitorPage />} />
          <Route path="/admin/profile"                  element={<ProfilePage />} />
        </Route>
      </Route>

      {/* Foundation Admin routes */}
      <Route element={<RequireRole role="foundation_admin" />}>
        <Route element={<FoundationAdminLayout />}>
          <Route path="/fa"                   element={<FAOverviewPage />} />
          <Route path="/fa/inventories"       element={<FAInventoriesPage />} />
          <Route path="/fa/inventory-add"     element={<FAInventoryAddPage />} />
          <Route path="/fa/donations"         element={<FADonationsPage />} />
          <Route path="/fa/qr-scan"           element={<FAQrScanPage />}/>
          <Route path="/fa/workshops"         element={<FAWorkshopsPage />} />
          <Route path="/fa/workshop-add"      element={<FAWorkshopAddPage />} />
          <Route path="/fa/profile"           element={<FAProfilePage />} />
        </Route>
      </Route>

      {/* Fallback */}
      <Route path="/unauthorized" element={<UnauthorizedPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}