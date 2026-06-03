class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
  @override
  String toString() => 'UnauthorizedException: Session expired. Please login again.';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class ValidationException implements Exception {
  final Map<String, dynamic> errors;
  const ValidationException({required this.errors});

  String get firstError {
    if (errors.isEmpty) return 'Validation error.';
    final firstKey = errors.keys.first;
    final value = errors[firstKey];
    if (value is List && value.isNotEmpty) return value.first.toString();
    return value.toString();
  }

  @override
  String toString() => 'ValidationException: $errors';
}