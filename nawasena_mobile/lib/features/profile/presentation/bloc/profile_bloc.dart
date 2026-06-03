import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/profile/data/repositories/user_repository.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_state.dart';

import '../../../auth/data/models/user_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _repository;

  ProfileBloc({required this._repository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadPortfolio>(_onLoadPortfolio);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(const ProfileLoading());
    try {
      final user = await _repository.getMe();
      emit(ProfileLoaded(user: user));
    } on UnauthorizedException {
      emit(const ProfileError(message: 'Sesi telah berakhir. Silakan login kembali.'));
    } on ServerException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onLoadPortfolio(
      LoadPortfolio event,
      Emitter<ProfileState> emit,
      ) async {
    // PROTEKSI: Ambil data user yang sudah tersimpan di state saat ini agar tidak hilang
    final currentState = state;
    UserModel? existingUser;
    PortfolioModel? oldPortfolio;

    if (currentState is ProfileLoaded) {
      existingUser = currentState.user;
      oldPortfolio = currentState.portfolio;
    }

    // Jika belum ada data profil sama sekali di memori, barulah tampilkan loading penuh
    if (existingUser == null) {
      emit(const ProfileLoading());
    }

    try {
      final portfolio = await _repository.getPortfolio(event.userId);

      // Jika profil sudah ada, gabungkan datanya secara asinkronus menggunakan copyWith
      if (existingUser != null) {
        emit(ProfileLoaded(user: existingUser, portfolio: portfolio));
      } else {
        emit(ProfileLoaded(user: portfolio.user, portfolio: portfolio));
      }
    } on ServerException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(const ProfileLoading());
    try {
      String? avatarUrl;
      if (event.avatarImagePath != null) {
        avatarUrl = await _repository.uploadAvatar(event.avatarImagePath!);
      }
      final user = await _repository.updateMe(
        fullName:  event.fullName,
        avatarUrl: avatarUrl,
        skills:    event.skills,
      );
      emit(ProfileUpdateSuccess(user: user));
    } on ValidationException catch (e) {
      emit(ProfileError(message: e.firstError));
    } on ServerException catch (e) {
      emit(ProfileError(message: e.message));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}