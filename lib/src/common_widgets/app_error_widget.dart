import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

/// Standard API error shape:
/// ```json
/// {
///   "ok": false,
///   "error": {
///     "code": "NOT_FOUND",
///     "message": "OTP challenge not found.",
///     "retryable": false,
///     "details": { "trace_id": "trc_error_001" }
///   }
/// }
/// ```
class ApiError {
  final String code;
  final String message;
  final bool retryable;
  final String? traceId;

  const ApiError({
    required this.code,
    required this.message,
    this.retryable = false,
    this.traceId,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>? ?? {};
    final details = error['details'] as Map<String, dynamic>?;
    return ApiError(
      code: error['code'] as String? ?? 'UNKNOWN',
      message: error['message'] as String? ?? 'Something went wrong.',
      retryable: error['retryable'] as bool? ?? false,
      traceId: details?['trace_id'] as String?,
    );
  }
}

/// Reusable error display widget.
///
/// Can be built from a plain [message] string or from a typed [ApiError]
/// using [AppErrorWidget.fromApiError].
///
/// Usage — plain:
/// ```dart
/// AppErrorWidget(message: 'Failed to load feed', onRetry: _reload)
/// ```
///
/// Usage — from parsed API error JSON:
/// ```dart
/// AppErrorWidget.fromApiError(
///   ApiError.fromJson(responseJson),
///   onRetry: _reload,
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? errorCode;
  final String? traceId;
  final bool showRetry;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.message = 'Something went wrong.',
    this.errorCode,
    this.traceId,
    this.showRetry = true,
    this.onRetry,
  });

  factory AppErrorWidget.fromApiError(
    ApiError error, {
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      message: error.message,
      errorCode: error.code,
      traceId: error.traceId,
      showRetry: error.retryable,
      onRetry: error.retryable ? onRetry : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorCode != null) ...[
              const SizedBox(height: 4),
              Text(
                'Error: $errorCode',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
            if (traceId != null) ...[
              const SizedBox(height: 2),
              Text(
                'Trace: $traceId',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
