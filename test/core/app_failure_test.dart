import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/core/error/app_failure.dart';

void main() {
  group('LocationFailure.canOpenSettings', () {
    test('true for serviceDisabled and permissionDeniedForever', () {
      expect(
        const LocationFailure(LocationFailureReason.serviceDisabled)
            .canOpenSettings,
        isTrue,
      );
      expect(
        const LocationFailure(LocationFailureReason.permissionDeniedForever)
            .canOpenSettings,
        isTrue,
      );
    });

    test('false for permissionDenied and timedOut — settings won\'t help', () {
      expect(
        const LocationFailure(LocationFailureReason.permissionDenied)
            .canOpenSettings,
        isFalse,
      );
      expect(
        const LocationFailure(LocationFailureReason.timedOut).canOpenSettings,
        isFalse,
      );
    });
  });
}
