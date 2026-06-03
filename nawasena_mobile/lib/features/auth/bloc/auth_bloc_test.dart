import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';
import 'package:nawasena_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';

// ── Mock ──────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements AuthRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────
final _mockUser = UserModel(
  id:       'user_001',
  fullName: 'Budi Santoso',
  email:    'budi@nawasena.id',
  role:     'donor',
);

final _mockVolunteer = UserModel(
  id:       'user_002',
  fullName: 'Siti Rahayu',
  email:    'siti@nawasena.id',
  role:     'volunteer',
);

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── AppStarted ─────────────────────────────────────────────────────────────
  group('AppStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when token valid and getMe succeeds',
      build: () {
        when(() => mockRepo.getStoredToken())
            .thenAnswer((_) async => 'valid_token');
        when(() => mockRepo.getMe())
            .thenAnswer((_) async => _mockUser);
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: _mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no token stored',
      build: () {
        when(() => mockRepo.getStoredToken()).thenAnswer((_) async => null);
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when token exists but getMe throws UnauthorizedException',
      build: () {
        when(() => mockRepo.getStoredToken())
            .thenAnswer((_) async => 'expired_token');
        when(() => mockRepo.getMe())
            .thenThrow(const UnauthorizedException());
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  // ── LoginRequested ─────────────────────────────────────────────────────────
  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => mockRepo.login(
          email:    'budi@nawasena.id',
          password: 'password123',
        )).thenAnswer((_) async => (user: _mockUser, token: 'token_abc'));
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email:    'budi@nawasena.id',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: _mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on invalid credentials (ValidationException)',
      build: () {
        when(() => mockRepo.login(
          email:    'wrong@email.com',
          password: 'wrongpass',
        )).thenThrow(const ValidationException(errors: {
          'email': ['The provided credentials are incorrect.'],
        }));
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email:    'wrong@email.com',
        password: 'wrongpass',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(
            message: 'The provided credentials are incorrect.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on network error',
      build: () {
        when(() => mockRepo.login(
          email:    'budi@nawasena.id',
          password: 'password123',
        )).thenThrow(const NetworkException(
          message: 'No internet connection.',
        ));
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email:    'budi@nawasena.id',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'No internet connection.'),
      ],
    );
  });

  // ── RegisterRequested ──────────────────────────────────────────────────────
  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful registration',
      build: () {
        when(() => mockRepo.register(
          fullName:             'Siti Rahayu',
          email:                'siti@nawasena.id',
          password:             'password123',
          passwordConfirmation: 'password123',
          role:                 'volunteer',
        )).thenAnswer((_) async =>
        (user: _mockVolunteer, token: 'token_xyz'));
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        fullName:             'Siti Rahayu',
        email:                'siti@nawasena.id',
        password:             'password123',
        passwordConfirmation: 'password123',
        role:                 'volunteer',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: _mockVolunteer),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when email already taken',
      build: () {
        when(() => mockRepo.register(
          fullName:             any(named: 'fullName'),
          email:                any(named: 'email'),
          password:             any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
          role:                 any(named: 'role'),
        )).thenThrow(const ValidationException(errors: {
          'email': ['The email has already been taken.'],
        }));
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        fullName:             'Test',
        email:                'taken@email.com',
        password:             'password123',
        passwordConfirmation: 'password123',
        role:                 'donor',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'The email has already been taken.'),
      ],
    );
  });

  // ── LogoutRequested ────────────────────────────────────────────────────────
  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      build: () {
        when(() => mockRepo.logout()).thenAnswer((_) async {});
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] even if logout API call fails',
      build: () {
        when(() => mockRepo.logout())
            .thenThrow(const ServerException(message: 'Server error'));
        return AuthBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}