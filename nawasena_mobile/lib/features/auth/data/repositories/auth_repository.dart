import 'package:nawasena_mobile/core/constants/api_constants.dart';
import 'package:nawasena_mobile/core/constants/storage_keys.dart';
import 'package:nawasena_mobile/core/network/api_client.dart';
import 'package:nawasena_mobile/core/utils/secure_storage_service.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _api;
  final SecureStorageService _storage;

  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storage,
  })  : _api = apiClient ?? ApiClient.instance,
        _storage = storage ?? SecureStorageService.instance;

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    final user  = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
    final token = data['token'].toString();
    await _persistSession(user: user, token: token);
    return (user: user, token: token);
  }

  Future<({UserModel user, String token})> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'full_name':              fullName,
        'email':                  email,
        'password':               password,
        'password_confirmation':  passwordConfirmation,
        'role':                   role,
      },
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    final user  = UserModel.fromJson(Map<String, dynamic>.from(data['user']));
    final token = data['token'].toString();
    await _persistSession(user: user, token: token);
    return (user: user, token: token);
  }

  Future<void> logout() async {
    try {
      await _api.post<void>(ApiConstants.logout);
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<UserModel?> getMe() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.me,
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    return UserModel.fromJson(data);
  }

  Future<String?> getStoredToken() => _storage.read(StorageKeys.authToken);

  Future<void> _persistSession({
    required UserModel user,
    required String token,
  }) async {
    await _storage.write(StorageKeys.authToken, token);
    await _storage.write(StorageKeys.userId, user.id);
    await _storage.write(StorageKeys.userRole, user.role);
    await _storage.write(StorageKeys.userEmail, user.email);
  }
}