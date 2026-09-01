/// The closed set of error cases the UI knows how to render.
///
/// This is a hand-written `sealed` hierarchy, not a Freezed union, on purpose:
/// the variants carry almost no data and never need `copyWith`. Freezed earns
/// its keep on data-rich immutable models; here it would only add generated
/// code. Exhaustive `switch` on the sealed type gives us the same safety.
///
/// Implements [Exception] so repositories can `throw` it directly and BLoCs can
/// `catch (e)` and match on `AppFailure` — no `Result`/`Either` wrapper needed.
sealed class AppFailure implements Exception {
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

enum LocationFailureReason {
  /// Device location services (GPS) are switched off system-wide.
  serviceDisabled,

  /// The user dismissed the permission prompt; asking again may still work.
  permissionDenied,

  /// The user chose "Don't allow" — only app settings can grant it now.
  permissionDeniedForever,
}

/// The user's location couldn't be determined. Carries a [reason] because the
/// UI reacts differently to each (retry vs. open settings), but a single class
/// with an enum stays lighter than three near-identical sibling types.
final class LocationFailure extends AppFailure {
  const LocationFailure(this.reason);

  final LocationFailureReason reason;

  bool get canOpenSettings => reason != LocationFailureReason.permissionDenied;

  @override
  String get message => switch (reason) {
        LocationFailureReason.serviceDisabled =>
          'Location services are off. Turn them on to see places near you.',
        LocationFailureReason.permissionDenied =>
          'Location permission is needed to find places near you.',
        LocationFailureReason.permissionDeniedForever =>
          'Location permission is blocked. Enable it in app settings.',
      };
}
