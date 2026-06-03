import 'package:equatable/equatable.dart';

class VolunteerProfile extends Equatable {
  final List<String> skills;
  final int totalHours;

  const VolunteerProfile({
    this.skills = const [],
    this.totalHours = 0,
  });

  factory VolunteerProfile.fromJson(Map<String, dynamic> json) {
    return VolunteerProfile(
      skills: List<String>.from(json['skills'] ?? []),
      totalHours: (json['total_hours'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'skills': skills,
    'total_hours': totalHours,
  };

  VolunteerProfile copyWith({
    List<String>? skills,
    int? totalHours,
  }) {
    return VolunteerProfile(
      skills: skills ?? this.skills,
      totalHours: totalHours ?? this.totalHours,
    );
  }

  @override
  List<Object?> get props => [skills, totalHours];
}

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;
  final VolunteerProfile? volunteerProfile;
  final String? managedFoundationId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.volunteerProfile,
    this.managedFoundationId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'donor',
      avatarUrl: json['avatar_url']?.toString(),
      volunteerProfile: json['volunteer_profile'] != null
          ? VolunteerProfile.fromJson(
        Map<String, dynamic>.from(json['volunteer_profile']),
      )
          : null,
      managedFoundationId: json['managed_foundation_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'full_name': fullName,
    'email': email,
    'role': role,
    'avatar_url': avatarUrl,
    'volunteer_profile': volunteerProfile?.toJson(),
    'managed_foundation_id': managedFoundationId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    String? avatarUrl,
    VolunteerProfile? volunteerProfile,
    String? managedFoundationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      volunteerProfile: volunteerProfile ?? this.volunteerProfile,
      managedFoundationId: managedFoundationId ?? this.managedFoundationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isDonor => role == 'donor';
  bool get isVolunteer => role == 'volunteer';
  bool get isFoundationAdmin => role == 'foundation_admin';

  @override
  List<Object?> get props => [
    id, fullName, email, role, avatarUrl,
    volunteerProfile, managedFoundationId, createdAt, updatedAt,
  ];
}