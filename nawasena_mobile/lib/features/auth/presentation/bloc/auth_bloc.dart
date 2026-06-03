import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required this._repository})
      : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ── AppStarted: cek token lokal saat aplikasi dibuka ───────────────────
  Future<void> _onAppStarted(
      AppStarted event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final token = await _repository.getStoredToken();
      if (token == null || token.isEmpty) {
        emit(const AuthUnauthenticated());
        return;
      }
      final user = await _repository.getMe();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on UnauthorizedException {
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────
  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final result = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: result.user));
    } on ValidationException catch (e) {
      emit(AuthFailure(message: e.firstError));
    } on ServerException catch (e) {
      emit(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: 'Terjadi kesalahan tak terduga: ${e.toString()}'));
    }
  }

  // ── Register ───────────────────────────────────────────────────────────
  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final result = await _repository.register(
        fullName:             event.fullName,
        email:                event.email,
        password:             event.password,
        passwordConfirmation: event.passwordConfirmation,
        role:                 event.role,
      );
      emit(AuthAuthenticated(user: result.user));
    } on ValidationException catch (e) {
      emit(AuthFailure(message: e.firstError));
    } on ServerException catch (e) {
      emit(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      emit(AuthFailure(message: e.message));
    } catch (e) {
      emit(AuthFailure(message: 'Registrasi gagal: ${e.toString()}'));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await _repository.logout();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }
}