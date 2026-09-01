/// The closed set of error cases the UI knows how to render.
///
/// This is a hand-written `sealed` hierarchy, not a Freezed union, on purpose:
/// the variants carry almost no data and never need `copyWith`. Freezed earns
/// its keep on data-rich immutable models; here it would only add generated
/// code. Exhaustive `switch` on the sealed type gives us the same safety.
sealed class AppFailure {
  const AppFailure();

  /// Text safe to display directly to the user.
  String get message;
}

/// No connectivity, DNS failure, TLS problem, or a timeout. Retrying may help.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();

  @override
  String get message =>
      'Can’t reach the network. Check your connection and try again.';
}

/// The API responded with a non-2xx status.
final class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  String get message => switch (statusCode) {
        401 || 403 => 'The places service rejected the request. Check the API key.',
        429 => 'Too many requests. Wait a moment and try again.',
        _ => 'The places service is unavailable right now. Try again later.',
      };
}

/// Anything unanticipated — treat as a bug to investigate.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure();

  @override
  String get message => 'Something went wrong. Please try again.';
}
