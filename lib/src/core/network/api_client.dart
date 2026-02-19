import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/network/api_response.dart';

/// Centralized HTTP client for all API operations.
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// final response = await client.post<AuthResponse>(
///   ApiEndpoints.login,
///   data: loginDto.toJson(),
///   headers: ApiClient.traceHeaders(),
///   fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
/// );
/// ```
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const _uuid = Uuid();

  final http.Client _client = http.Client();
  String? _authToken;
  final Duration _timeout = const Duration(seconds: 30);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Generates idempotency + trace headers required by the API.
  ///
  /// Call this and merge into the `headers` parameter for endpoints
  /// that require `Idempotency-Key` and `x-trace-id`.
  static Map<String, String> traceHeaders() {
    final id = _uuid.v4();
    return {
      'Idempotency-Key': id,
      'idempotency-key': id,
      'x-trace-id': _uuid.v4(),
    };
  }

  /// Update the authorization token (e.g., after login).
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Remove the authorization token (e.g., after logout).
  void clearAuthToken() {
    _authToken = null;
  }

  /// GET request with typed response.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final requestHeaders = {..._headers, ...?headers};
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(_timeout);
      return _processResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request with typed response.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    final uri = _buildUri(path);
    try {
      final requestHeaders = {..._headers, ...?headers};
      final response = await _client
          .post(uri, headers: requestHeaders, body: jsonEncode(data))
          .timeout(_timeout);
      return _processResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request with typed response.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    final uri = _buildUri(path);
    try {
      final requestHeaders = {..._headers, ...?headers};
      final response = await _client
          .put(uri, headers: requestHeaders, body: jsonEncode(data))
          .timeout(_timeout);
      return _processResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request with typed response.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    final uri = _buildUri(path);
    try {
      final requestHeaders = {..._headers, ...?headers};
      final response = await _client
          .patch(uri, headers: requestHeaders, body: jsonEncode(data))
          .timeout(_timeout);
      return _processResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request.
  Future<ApiResponse<bool>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    try {
      final requestHeaders = {..._headers, ...?headers};
      final response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(_timeout);
      return _processResponse(response, (_) => true);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- Internal Helpers ---

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    String baseUrl = ApiEndpoints.baseUrl;
    if (path.startsWith('http')) return Uri.parse(path);

    if (!baseUrl.endsWith('/')) baseUrl += '/';
    if (path.startsWith('/')) path = path.substring(1);

    final uriString = '$baseUrl$path';
    final uri = Uri.parse(uriString);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic body = jsonDecode(response.body);
      return ApiResponse.fromJson(
        body is Map<String, dynamic> ? body : {'data': body},
        fromJson,
      );
    } else {
      throw _handleHttpError(response);
    }
  }

  ApiException _handleHttpError(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }
    final String? message = body is Map ? body['message'] as String? : null;
    final dynamic data = body is Map ? body : null;

    switch (response.statusCode) {
      case 400:
        return ValidationException(
          message: message ?? 'Bad Request',
          errors: data is Map<String, dynamic> && data['errors'] != null
              ? (data['errors'] as Map<String, dynamic>).map(
                  (k, v) => MapEntry(k, List<String>.from(v as List)),
                )
              : null,
        );
      case 401:
        return UnauthorizedException(message: message ?? 'Unauthorized');
      case 403:
        return ApiException(
          message: message ?? 'Forbidden',
          statusCode: 403,
          data: data,
        );
      case 404:
        return NotFoundException(message: message ?? 'Not Found');
      case 500:
      case 502:
        return ServerException(message: message ?? 'Server Error');
      default:
        return ApiException(
          message: message ?? 'Unknown Error',
          statusCode: response.statusCode,
          data: data,
        );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    if (error is SocketException || error is http.ClientException) {
      return const NetworkException();
    }
    if (error is TimeoutException) {
      return const NetworkException(message: 'Connection timed out');
    }
    return ApiException(message: error.toString());
  }
}
