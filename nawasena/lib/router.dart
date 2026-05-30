import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/explore/explore_screen.dart';
import 'presentation/screens/explore/foundation_detail_screen.dart';
import 'presentation/screens/donation/donation_detail_screen.dart';
import 'presentation/screens/donation/payment_screen.dart';
import 'presentation/screens/donation/success_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
        GoRoute(
          path: '/explore/:id',
          builder: (_, state) =>
              FoundationDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/donate/:inventoryId',
      builder: (_, state) =>
          DonationDetailScreen(inventoryId: state.pathParameters['inventoryId']!),
    ),
    GoRoute(
      path: '/payment/:donationId',
      builder: (_, state) =>
          PaymentScreen(donationId: state.pathParameters['donationId']!),
    ),
    GoRoute(
      path: '/success/:donationId',
      builder: (_, state) =>
          SuccessScreen(donationId: state.pathParameters['donationId']!),
    ),
  ],
);