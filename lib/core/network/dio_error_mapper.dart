import 'dart:io';

import 'package:dio/dio.dart';

import '../error/app_failure.dart';

/// Translates transport-level errors into the app's [AppFailure] set.
///
/// Repositories call this inside their `catch` blocks, so BLoCs and the UI
/// only ever deal with domain failures — never a raw [DioException].
AppFailure mapDioException(Object error) {
  if (error is! DioException) return const UnexpectedFailure();

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate =>
      const NetworkFailure(),
    DioExceptionType.badResponse =>
      ServerFailure(statusCode: error.response?.statusCode),
    DioExceptionType.cancel => const UnexpectedFailure(),
    DioExceptionType.unknown =>
      error.error is SocketException ? const NetworkFailure() : const UnexpectedFailure(),
  };
}
