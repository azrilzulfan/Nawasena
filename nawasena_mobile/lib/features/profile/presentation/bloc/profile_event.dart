import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class LoadPortfolio extends ProfileEvent {
  final String userId;
  const LoadPortfolio({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final String? fullName;
  final String? avatarImagePath;
  final List<String>? skills;

  const UpdateProfile({
    this.fullName,
    this.avatarImagePath,
    this.skills,
  });

  @override
  List<Object?> get props => [fullName, avatarImagePath, skills];
}