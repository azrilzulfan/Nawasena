import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawasena_mobile/core/theme/app_theme.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_bloc.dart';

/// Membungkus widget dengan semua provider yang dibutuhkan untuk widget test
Widget buildTestableWidget({
  required Widget child,
  required AuthBloc authBloc,
  DonorBloc? donorBloc,
  VolunteerBloc? volunteerBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      if (donorBloc != null)
        BlocProvider<DonorBloc>.value(value: donorBloc),
      if (volunteerBloc != null)
        BlocProvider<VolunteerBloc>.value(value: volunteerBloc),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

/// Helper matcher untuk async Bloc test
extension BlocStateExtension<T> on List<T> {
  bool containsStateOfType<S>() => whereType<S>().isNotEmpty;
}