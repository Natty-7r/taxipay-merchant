import 'package:dio/dio.dart';

/// Any failed API call, mapped from the API's error envelope
/// `{ success: false, errorCode, message, details, traceId }`.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.status,
    this.details = const [],
    this.traceId,
  });

  /// Stable machine code from the API, e.g. MERCHANT_NOT_APPROVED, or NETWORK / TIMEOUT locally.
  final String code;
  final String message;
  final int? status;
  final List<String> details;

  /// Quote this when reporting a problem — it matches the server logs.
  final String? traceId;

  bool get isUnauthorized => status == 401;
  bool get isNetwork => code == 'NETWORK' || code == 'TIMEOUT';

  /// The message to show the user (validation details when there are any).
  String get userMessage => details.isEmpty ? message : '$message\n• ${details.join('\n• ')}';

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['errorCode'] != null) {
      return ApiException(
        code: data['errorCode'] as String,
        message: (data['message'] as String?) ?? 'Request failed',
        status: e.response?.statusCode,
        details: ((data['details'] as List?) ?? const []).map((d) => d.toString()).toList(),
        traceId: data['traceId'] as String?,
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(code: 'TIMEOUT', message: 'The server took too long to answer. Try again.');
      case DioExceptionType.connectionError:
        return ApiException(code: 'NETWORK', message: 'No connection to Taxi Pay. Check your internet.');
      default:
        return ApiException(
          code: 'HTTP_${e.response?.statusCode ?? 0}',
          message: 'Something went wrong. Try again.',
          status: e.response?.statusCode,
        );
    }
  }

  @override
  String toString() => 'ApiException($code, $status): $message${traceId == null ? '' : ' [trace $traceId]'}';
}
