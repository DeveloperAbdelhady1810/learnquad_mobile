import 'package:dio/dio.dart';

/// A normalized error shape for the UI layer, so widgets never need to know
/// about Dio/HTTP specifics.
class Failure {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  factory Failure.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['message'] is String) {
      return Failure(
        message: data['message'] as String,
        statusCode: statusCode,
      );
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const Failure(
        message: 'Connection timed out. Please try again.',
      ),
      DioExceptionType.connectionError => const Failure(
        message: 'No internet connection.',
      ),
      _ => Failure(
        message: 'Something went wrong. Please try again.',
        statusCode: statusCode,
      ),
    };
  }
}
