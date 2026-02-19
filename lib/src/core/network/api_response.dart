/// Generic API response wrapper.
///
/// Provides a consistent shape for all API responses,
/// regardless of the endpoint. Supports both single objects and lists.
library;

class ApiResponse<T> {
  final T data;
  final String? message;
  final int statusCode;
  final bool success;

  const ApiResponse({
    required this.data,
    this.message,
    required this.statusCode,
    this.success = true,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: fromJsonT(json['data'] ?? json), // Fallback if data is not wrapped
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int? ?? 200,
      success: json['success'] as bool? ?? true,
    );
  }
}
