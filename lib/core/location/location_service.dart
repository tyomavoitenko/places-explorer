import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../error/app_failure.dart';

/// Approximate location used when the user declines location access, so the app
/// still shows something useful. Googleplex, Mountain View — also the Android
/// emulator's default position.
final LatLng kFallbackLocation = LatLng(37.4220, -122.0841);

/// Abstracts device location so the BLoC depends on an interface, not on the
/// `geolocator` plugin (which can't run in unit tests).
abstract interface class LocationService {
  /// The device's current position.
  ///
  /// Throws [LocationFailure] for every "can't get location" case:
  /// services off, permission denied, permission denied forever.
  Future<LatLng> currentLocation();

  /// Opens the OS settings screen where the user can re-grant permission or
  /// switch location services back on. No-op result — we can't know what they do.
  Future<void> openSettings({required bool permanentlyDenied});
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LatLng> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(LocationFailureReason.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        throw const LocationFailure(LocationFailureReason.permissionDenied);
      case LocationPermission.deniedForever:
        throw const LocationFailure(
          LocationFailureReason.permissionDeniedForever,
        );
      case LocationPermission.whileInUse:
      case LocationPermission.always:
      case LocationPermission.unableToDetermine:
        break;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Future<void> openSettings({required bool permanentlyDenied}) {
    return permanentlyDenied
        ? Geolocator.openAppSettings()
        : Geolocator.openLocationSettings();
  }
}
