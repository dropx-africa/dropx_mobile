/// Custom exceptions for the API layer.
///
/// These provide structured error handling for network operations,
/// making it easy to show user-friendly messages.
library;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.statusCode = 401,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Something went wrong. Please try again later.',
    super.statusCode = 500,
  });
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'Validation failed. Please check your input.',
    super.statusCode = 422,
    this.errors,
  });
}
