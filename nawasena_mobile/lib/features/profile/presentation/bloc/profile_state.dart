import 'package:equatable/equatable.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';
import 'package:nawasena_mobile/features/profile/data/repositories/user_repository.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// SOLUSI UTAMA: Satukan User dan Portfolio ke dalam satu State yang Terintegrasi
class ProfileLoaded extends ProfileState {
  final UserModel user;
  final PortfolioModel? portfolio;

  const ProfileLoaded({
    required this.user,
    this.portfolio,
  });

  // Fungsi pembantu untuk memperbarui salah satu properti tanpa kehilangan properti lainnya
  ProfileLoaded copyWith({
    UserModel? user,
    PortfolioModel? portfolio,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      portfolio: portfolio ?? this.portfolio,
    );
  }

  @override
  List<Object?> get props => [user, portfolio];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserModel user;
  const ProfileUpdateSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}