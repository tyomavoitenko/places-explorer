/// Human-readable distance, e.g. `120 m`, `1.4 km`, `12 km`. Returns `null` when
/// the distance is unknown so callers can omit the widget entirely.
String? formatDistance(int? meters) {
  if (meters == null) return null;
  if (meters < 1000) return '$meters m';
  final km = meters / 1000;
  return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
}
