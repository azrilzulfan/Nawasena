import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_theme.dart';
import 'package:nawasena_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/donation_repository.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/foundation_repository.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/profile/data/repositories/user_repository.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nawasena_mobile/features/volunteer/data/repositories/workshop_repository.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_bloc.dart';

class NawasenaApp extends StatefulWidget {
  const NawasenaApp({super.key});

  @override
  State<NawasenaApp> createState() => _NawasenaAppState();
}

class _NawasenaAppState extends State<NawasenaApp> {
  late final AuthBloc _authBloc;
  late final DonorBloc _donorBloc;
  late final VolunteerBloc _volunteerBloc;
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(repository: AuthRepository())
      ..add(const AppStarted());
    _donorBloc = DonorBloc(
      foundationRepository: FoundationRepository(),
      donationRepository: DonationRepository(),
    );
    _volunteerBloc = VolunteerBloc(repository: WorkshopRepository());
    _profileBloc = ProfileBloc(repository: UserRepository());
  }

  @override
  void dispose() {
    _authBloc.close();
    _donorBloc.close();
    _volunteerBloc.close();
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _donorBloc),
        BlocProvider.value(value: _volunteerBloc),
        BlocProvider.value(value: _profileBloc),
      ],
      child: Builder(
        builder: (context) {
          final router = createAppRouter(_authBloc);
          return MaterialApp.router(
            title: 'Nawasena',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,

            locale: const Locale('id', 'ID'),
            supportedLocales: const [
              Locale('id', 'ID'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}