import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_key_interceptor.dart';

/// Builds the single configured [Dio] instance used by the whole app.
///
/// Kept as a pure factory (no side effects, no globals) so it is trivial to
/// construct a throwaway instance in tests with a mock adapter.
abstract final class DioFactory {
  static Dio create({required String baseUrl, required String apiKey}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Order matters: the key is attached first so the debug log shows the
    // final request. Interceptors run in insertion order for `onRequest`.
    dio.interceptors.add(ApiKeyInterceptor(apiKey));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (line) => debugPrint(line.toString()),
        ),
      );
    }

    return dio;
  }
}
