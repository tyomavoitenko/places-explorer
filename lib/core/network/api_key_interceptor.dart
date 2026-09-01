import 'package:dio/dio.dart';

/// Appends the Geoapify `apiKey` query parameter to every request.
///
/// Keeping this in an interceptor means the Retrofit service definition and
/// every call site stay free of credentials — they describe *what* to fetch,
/// not *how* to authenticate.
class ApiKeyInterceptor extends Interceptor {
  const ApiKeyInterceptor(this._apiKey);

  final String _apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_apiKey.isNotEmpty) {
      options.queryParameters = {
        ...options.queryParameters,
        'apiKey': _apiKey,
      };
    }
    handler.next(options);
  }
}
