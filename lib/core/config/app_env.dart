/// Compile-time configuration.
///
/// The Geoapify API key is supplied at build/run time with
/// `--dart-define=GEOAPIFY_API_KEY=...` so it never lands in source control.
/// `String.fromEnvironment` is a `const` lookup resolved by the compiler.
abstract final class AppEnv {
  static const String geoapifyBaseUrl = 'https://api.geoapify.com';

  static const String geoapifyApiKey =
      String.fromEnvironment('GEOAPIFY_API_KEY');

  /// Lets the UI show a helpful "configure your key" hint instead of failing
  /// with an opaque 401 during local setup.
  static bool get hasGeoapifyKey => geoapifyApiKey.isNotEmpty;
}
