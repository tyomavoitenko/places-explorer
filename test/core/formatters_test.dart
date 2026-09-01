import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/core/utils/formatters.dart';

void main() {
  group('formatDistance', () {
    test('returns null when the distance is unknown', () {
      expect(formatDistance(null), isNull);
    });

    test('shows metres below 1 km', () {
      expect(formatDistance(0), '0 m');
      expect(formatDistance(240), '240 m');
      expect(formatDistance(999), '999 m');
    });

    test('shows one decimal between 1 and 10 km', () {
      expect(formatDistance(1000), '1.0 km');
      expect(formatDistance(1400), '1.4 km');
    });

    test('rounds to whole km at 10 km and above', () {
      expect(formatDistance(12300), '12 km');
    });
  });
}
