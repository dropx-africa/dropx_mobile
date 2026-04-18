import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:dropx_mobile/src/core/network/api_endpoints.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/network/api_response.dart';
import 'package:flutter/foundation.dart';

class SseEvent {
  final String type;
  final String data;
  const SseEvent({required this.type, required this.data});
}

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
  String? _refreshToken;
  final Duration _timeout = const Duration(seconds: 30);

  bool _isRefreshing = false;
  Future<void>? _refreshFuture;
  void Function(String, String)? onTokenRefreshed;
  void Function()? onUnauthorized;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Generates idempotency + trace headers required by the API.
  static Map<String, String> traceHeaders() {
    final id = _uuid.v4();
    return {
      'Idempotency-Key': id,
      'idempotency-key': id,
      'x-trace-id': _uuid.v4(),
    };
  }

  /// Update the authorization tokens.
  void setAuthToken(String token, {String? refreshToken}) {
    _authToken = token;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  /// Remove the authorization tokens.
  void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
  }

  /// GET request with typed response.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    return _executeWithRefresh(() async {
      final uri = _buildUri(path, queryParams);
      final requestHeaders = {..._headers, ...?headers};
      return await _client.get(uri, headers: requestHeaders).timeout(_timeout);
    }, fromJson);
  }

  /// POST request with typed response.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    return _executeWithRefresh(() async {
      final uri = _buildUri(path);
      final requestHeaders = {..._headers, ...?headers};
      return await _client
          .post(uri, headers: requestHeaders, body: jsonEncode(data))
          .timeout(_timeout);
    }, fromJson);
  }

  /// PUT request with typed response.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    return _executeWithRefresh(() async {
      final uri = _buildUri(path);
      final requestHeaders = {..._headers, ...?headers};
      return await _client
          .put(uri, headers: requestHeaders, body: jsonEncode(data))
          .timeout(_timeout);
    }, fromJson);
  }

  /// PATCH request with typed response.
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    required T Function(dynamic) fromJson,
  }) async {
    return _executeWithRefresh(() async {
      final uri = _buildUri(path);
      final requestHeaders = {..._headers, ...?headers};
      return await _client
          .patch(uri, headers: requestHeaders, body: jsonEncode(data))
          .timeout(_timeout);
    }, fromJson);
  }

  /// DELETE request.
  Future<ApiResponse<bool>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _executeWithRefresh(() async {
      final uri = _buildUri(path);
      final requestHeaders = {..._headers, ...?headers};
      return await _client
          .delete(uri, headers: requestHeaders)
          .timeout(_timeout);
    }, (_) => true);
  }

  /// Opens a Server-Sent Events stream. Yields [SseEvent] objects as they arrive.
  /// The stream ends when the server closes the connection.
  Stream<SseEvent> sseStream(String path) async* {
    final uri = _buildUri(path);
    final request = http.Request('GET', uri);
    request.headers.addAll({
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    });

    http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } catch (_) {
      return;
    }
    if (response.statusCode != 200) return;

    String eventType = '';
    String eventData = '';

    try {
      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.isEmpty) {
          if (eventData.isNotEmpty) {
            yield SseEvent(
              type: eventType.isEmpty ? 'message' : eventType,
              data: eventData,
            );
          }
          eventType = '';
          eventData = '';
        } else if (line.startsWith('event:')) {
          eventType = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          eventData = line.substring(5).trim();
        }
        // ignore comment lines (': heartbeat')
      }
    } catch (_) {
      // Stream ended or error — caller handles reconnect
    }
  }

  // --- Internal Helpers ---

  Future<ApiResponse<T>> _executeWithRefresh<T>(
    Future<http.Response> Function() requestFunc,
    T Function(dynamic) fromJson,
  ) async {
    try {
      var response = await requestFunc();

      debugPrint('[API] Request to ${response.request?.url}');
      debugPrint('[API] Response status: ${response.statusCode}');
      debugPrint('[API] Response body: ${response.body}');

      if (response.statusCode == 401) {
        if (_refreshToken != null) {
          if (!_isRefreshing) {
            _isRefreshing = true;
            _refreshFuture = _performRefresh();
          }
          try {
            await _refreshFuture;
            // Retry the request after refreshing token
            response = await requestFunc();
          } catch (e) {
            // Refresh failed — clear tokens and redirect to login
            clearAuthToken();
            onUnauthorized?.call();
          } finally {
            _isRefreshing = false;
            _refreshFuture = null;
          }
        } else if (_authToken != null) {
          // Had a token but it's invalid and no refresh token available
          clearAuthToken();
          onUnauthorized?.call();
        }
      }

      return _processResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _performRefresh() async {
    final uri = _buildUri(ApiEndpoints.refreshToken);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({'refresh_token': _refreshToken});

    final res = await _client
        .post(uri, headers: headers, body: body)
        .timeout(_timeout);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final jsonBody = jsonDecode(res.body);
      final data = jsonBody['data'];
      _authToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      if (onTokenRefreshed != null &&
          _authToken != null &&
          _refreshToken != null) {
        onTokenRefreshed!(_authToken!, _refreshToken!);
      }
    } else {
      throw _handleHttpError(res);
    }
  }

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

    // Extract error details from API response structure
    String? errorCode;
    String? errorMessage;
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        errorCode = error['code'] as String?;
        errorMessage = error['message'] as String?;
      }
    }

    // Use the actual error message from the API if available
    final String displayMessage = errorMessage ?? message ?? 'Unknown Error';

    switch (response.statusCode) {
      case 400:
        return ValidationException(
          message: displayMessage,
          errors: data is Map<String, dynamic> && data['errors'] != null
              ? (data['errors'] as Map<String, dynamic>).map(
                  (k, v) => MapEntry(k, List<String>.from(v as List)),
                )
              : null,
        );
      case 401:
        // Check if this is an OTP error vs authentication error
        if (errorCode == 'INVALID_OTP' || errorCode == 'OTP_EXPIRED') {
          return ValidationException(message: displayMessage);
        }
        return UnauthorizedException(message: displayMessage);
      case 403:
        return ApiException(
          message: displayMessage,
          statusCode: 403,
          data: data,
        );
      case 404:
        return NotFoundException(message: displayMessage);
      case 500:
      case 502:
        return ServerException(message: displayMessage);
      default:
        return ApiException(
          message: displayMessage,
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
