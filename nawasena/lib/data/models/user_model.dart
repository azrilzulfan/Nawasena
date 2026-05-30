import 'dart:convert';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final Map<String, dynamic>? volunteerProfile;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.volunteerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'] ?? json['id'] ?? '',
        fullName: json['full_name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'donor',
        avatarUrl: json['avatar_url'],
        volunteerProfile: json['volunteer_profile'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'avatar_url': avatarUrl,
        'volunteer_profile': volunteerProfile,
      };

  String toJsonString() => jsonEncode(toJson());

  int get volunteerHours =>
      (volunteerProfile?['hours_completed'] as int?) ?? 0;
  int get foundationsHelped =>
      (volunteerProfile?['foundations_helped'] as int?) ?? 0;
  List<String> get skills =>
      List<String>.from(volunteerProfile?['skills'] ?? []);
}