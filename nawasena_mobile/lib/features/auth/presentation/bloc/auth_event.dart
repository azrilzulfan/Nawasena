import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, email, password, passwordConfirmation, role];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}