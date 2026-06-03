import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/constants/storage_keys.dart';
import 'package:nawasena_mobile/core/utils/secure_storage_service.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:nawasena_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:nawasena_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:nawasena_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/donation_detail_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/donation_history_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/donation_pledge_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/donor_home_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/explore_needs_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/foundation_detail_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/item_detail_screen.dart';
import 'package:nawasena_mobile/features/donor/presentation/screens/qr_code_screen.dart';
import 'package:nawasena_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:nawasena_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/screens/geofence_checkin_screen.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/screens/workshop_detail_screen.dart';

// ── Named Route Paths ───────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash             = '/';
  static const String login              = '/login';
  static const String register           = '/register';

  // Shared
  static const String profile            = '/profile';
  static const String editProfile        = '/profile/edit';

  // Donor
  static const String donorHome          = '/donor/home';
  static const String exploreNeeds       = '/donor/explore';
  static const String foundationDetail   = '/donor/foundation/:id';
  static const String itemDetail         = '/donor/item/:id';
  static const String donationPledge     = '/donor/pledge/:inventoryId';
  static const String donationHistory    = '/donor/donations';
  static const String donationDetail     = '/donor/donations/:id';
  static const String qrCode             = '/donor/donations/:id/qr';

  // Volunteer
  static const String volunteerDashboard = '/volunteer/dashboard';
  static const String workshopDetail     = '/volunteer/workshop/:id';
  static const String geofenceCheckin    = '/volunteer/workshop/:id/checkin';

  // Helpers
  static String foundationDetailPath(String id)        => '/donor/foundation/$id';
  static String itemDetailPath(String id)              => '/donor/item/$id';
  static String donationPledgePath(String inventoryId) => '/donor/pledge/$inventoryId';
  static String donationDetailPath(String id)          => '/donor/donations/$id';
  static String qrCodePath(String id)                  => '/donor/donations/$id/qr';
  static String workshopDetailPath(String id)          => '/volunteer/workshop/$id';
  static String geofenceCheckinPath(String id)         => '/volunteer/workshop/$id/checkin';
}

// ── Router Factory ──────────────────────────────────────────────────────────
GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) async {
      final authState = authBloc.state;
      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (authState is AuthLoading) return null;

      if (authState is AuthUnauthenticated) {
        return isOnAuthPage ? null : AppRoutes.login;
      }

      if (authState is AuthAuthenticated) {
        if (isOnAuthPage) {
          final role = authState.user.role;
          return role == 'volunteer'
              ? AppRoutes.volunteerDashboard
              : AppRoutes.donorHome;
        }
      }

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Shared ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),

      // ── Donor ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.donorHome,
        name: 'donorHome',
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.exploreNeeds,
        name: 'exploreNeeds',
        builder: (context, state) => const ExploreNeedsScreen(),
      ),
      GoRoute(
        path: AppRoutes.foundationDetail,
        name: 'foundationDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FoundationDetailScreen(foundationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.itemDetail,
        name: 'itemDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ItemDetailScreen(inventoryId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.donationPledge,
        name: 'donationPledge',
        builder: (context, state) {
          final inventoryId = state.pathParameters['inventoryId']!;
          final foundationId = state.uri.queryParameters['foundationId'] ?? '';
          return DonationPledgeScreen(
            inventoryId: inventoryId,
            foundationId: foundationId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.donationHistory,
        name: 'donationHistory',
        builder: (context, state) => const DonationHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.donationDetail,
        name: 'donationDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DonationDetailScreen(donationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.qrCode,
        name: 'qrCode',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return QrCodeScreen(donationId: id);
        },
      ),

      // ── Volunteer ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.volunteerDashboard,
        name: 'volunteerDashboard',
        builder: (context, state) => const VolunteerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.workshopDetail,
        name: 'workshopDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkshopDetailScreen(workshopId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.geofenceCheckin,
        name: 'geofenceCheckin',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GeofenceCheckinScreen(workshopId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53935)),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── GoRouter Refresh Stream Helper ─────────────────────────────────────────
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}