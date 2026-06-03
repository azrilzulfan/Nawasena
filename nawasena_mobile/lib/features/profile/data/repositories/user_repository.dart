import 'package:dio/dio.dart';
import 'package:nawasena_mobile/core/constants/api_constants.dart';
import 'package:nawasena_mobile/core/network/api_client.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';

class PortfolioModel {
  final UserModel user;
  final int totalDonations;
  final int foundationsHelped;
  final int totalGoodsQty;
  final int volunteerHours;
  final int workshopsAttended;

  const PortfolioModel({
    required this.user,
    required this.totalDonations,
    required this.foundationsHelped,
    required this.totalGoodsQty,
    required this.volunteerHours,
    required this.workshopsAttended,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final impact = Map<String, dynamic>.from(json['impact'] ?? {});
    return PortfolioModel(
      user:              UserModel.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
      totalDonations:    (impact['total_donations'] as num?)?.toInt() ?? 0,
      foundationsHelped: (impact['foundations_helped'] as num?)?.toInt() ?? 0,
      totalGoodsQty:     (impact['total_goods_qty'] as num?)?.toInt() ?? 0,
      volunteerHours:    (impact['volunteer_hours'] as num?)?.toInt() ?? 0,
      workshopsAttended: (impact['workshops_attended'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserRepository {
  final ApiClient _api;

  UserRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  Future<UserModel> getMe() async {
    return await _api.get<UserModel>(
      ApiConstants.me,
      fromJson: (json) => UserModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  Future<UserModel> updateMe({
    String? fullName,
    String? avatarUrl,
    List<String>? skills,
  }) async {
    final body = <String, dynamic>{};
    if (fullName  != null) body['full_name']  = fullName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (skills    != null) {
      body['volunteer_profile'] = {'skills': skills};
    }

    final data = await _api.put<Map<String, dynamic>>(
      ApiConstants.me,
      data: body,
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    return UserModel.fromJson(Map<String, dynamic>.from(data['user']));
  }

  Future<PortfolioModel> getPortfolio(String userId) async {
    return await _api.get<PortfolioModel>(
      ApiConstants.portfolio(userId),
      fromJson: (json) => PortfolioModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file':   await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      'folder': 'avatars',
    });
    return await _api.uploadFile(ApiConstants.uploads, formData);
  }
}