import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:nawasena_mobile/core/constants/api_constants.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/core/network/auth_interceptor.dart';
import 'package:nawasena_mobile/core/utils/secure_storage_service.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(storage: SecureStorageService.instance),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    ]);
  }

  Dio get dio => _dio;

  Future<T> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: options);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> post<T>(
      String path, {
        dynamic data,
        Options? options,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> put<T>(
      String path, {
        dynamic data,
        Options? options, // <-- Tambahkan parameter options
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.put(path, data: data, options: options);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> patch<T>(
      String path, {
        dynamic data,
        Options? options, // <-- Tambahkan parameter options
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.patch(path, data: data, options: options);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> delete<T>(
      String path, {
        Options? options, // <-- Tambahkan parameter options
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.delete(path, options: options);
      return fromJson != null ? fromJson(response.data) : response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<String> uploadFile(
      String path,
      FormData formData,
      ) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data['url'] as String;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    if (e.error is UnauthorizedException) {
      return const UnauthorizedException();
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException(message: 'Connection timeout. Check your network.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'Cannot reach server. Check your internet connection.');
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    switch (statusCode) {
      case 401:
        return const UnauthorizedException();
      case 422:
        final errors = responseData is Map<String, dynamic>
            ? (responseData['errors'] as Map<String, dynamic>? ?? {})
            : <String, dynamic>{};
        return ValidationException(errors: errors);
      case 403:
        return ServerException(
          message: responseData?['message'] ?? 'Access forbidden.',
          statusCode: 403,
        );
      case 404:
        return ServerException(
          message: responseData?['message'] ?? 'Resource not found.',
          statusCode: 404,
        );
      case 409:
        return ServerException(
          message: responseData?['message'] ?? 'Conflict error.',
          statusCode: 409,
        );
      case 500:
      default:
        final message = responseData is Map<String, dynamic>
            ? responseData['message'] ?? 'Server error.'
            : 'Unexpected error.';
        return ServerException(message: message.toString(), statusCode: statusCode);
    }
  }
}