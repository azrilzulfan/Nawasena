import 'package:dio/dio.dart';
import 'package:nawasena_mobile/core/constants/storage_keys.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/core/utils/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor({required this._storage});

  bool _isPublicPath(String path) {
    final uri = Uri.parse(path);
    final pathSegments = uri.pathSegments;

    // 1. Route Auth (Login / Register Akun) SELALU Publik
    if (pathSegments.contains('auth') ||
        pathSegments.contains('login') ||
        pathSegments.contains('register_account')) { // bedakan dengan register workshop
      return true;
    }

    // 2. Deteksi Sub-Resource Privat untuk Foundations
    if (pathSegments.contains('foundations') &&
        (pathSegments.last == 'inventories' ||
            pathSegments.last == 'workshops' ||
            pathSegments.last == 'donations')) {
      return false; // WAJIB PAKAI TOKEN
    }

    // 3. Deteksi Detail Workshop & Fitur Register/Checkin Workshop (Pencegah Bug Anda Saat Ini)
    // Jika path mengandung 'workshops' dan setelahnya ada ID atau aksi privat
    // Contoh: /api/workshops/{id} ATAU /api/workshops/{id}/register
    if (pathSegments.contains('workshops')) {
      // Jika jalurnya murni hanya /api/workshops (untuk list/daftar list workshop publik)
      if (pathSegments.last == 'workshops') {
        return true;
      }
      // Jika setelah kata 'workshops' ada ID atau aksi seperti 'register', 'checkin'
      // Maka ini adalah jalur privat/detail yang membutuhkan kepemilikan token!
      return false;
    }

    // 4. Jalur publik sisa yang sangat ketat (Hanya untuk LIST global murni)
    final String checkPath = '/${pathSegments.join('/')}';
    final List<String> strictPublicPaths = [
      '/api/foundations',
      '/foundations',
      '/api/foundations/nearby',
      '/foundations/nearby',
      '/api/inventories',
      '/inventories',
    ];

    return strictPublicPaths.any((p) => checkPath == p || checkPath.endsWith(p));
  }

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // KONEKSIKAN KE DETEKTOR PATH PUBLIK
    final isPublic = _isPublicPath(options.path);

    // Jika BUKAN rute publik, maka WAJIB mengambil dan menyisipkan token terbaru dari storage
    if (!isPublic) {
      final token = await _storage.read(StorageKeys.authToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;
      final errorMessage = responseData is Map<String, dynamic>
          ? (responseData['message'] ?? '').toString().toLowerCase()
          : '';

      // Proteksi agar tidak salah hapus token akibat request paralel yang error sesaat
      if (errorMessage.contains('unauthenticated') ||
          errorMessage.contains('expired') ||
          errorMessage.contains('session expired')) {

        print("TOKEN FIX EXPIRED. CLEARING STORAGE TOKEN.");
        await _storage.delete(StorageKeys.authToken);
      }
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }
}