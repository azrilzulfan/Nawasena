import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });

    final user = UserModel.fromJson(response.data['user']);
    final token = response.data['token'] as String;

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUser(user.toJsonString());

    return user;
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await SecureStorage.clearToken();
    }
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data);
  }
}