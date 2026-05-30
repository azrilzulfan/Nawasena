import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/foundation_repository.dart';
import 'data/repositories/inventory_repository.dart';
import 'data/repositories/donation_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'router.dart';

void main() {
  runApp(const NawasenaApp());
}

class NawasenaApp extends StatelessWidget {
  const NawasenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => FoundationRepository()),
        RepositoryProvider(create: (_) => InventoryRepository()),
        RepositoryProvider(create: (_) => DonationRepository()),
      ],
      child: BlocProvider(
        create: (ctx) => AuthBloc(ctx.read<AuthRepository>())
          ..add(AuthCheckRequested()),
        child: MaterialApp.router(
          title: 'Nawasena',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: AppColors.primary,
            fontFamily: 'Inter',
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.background,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}