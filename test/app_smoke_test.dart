import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:places_explorer/app.dart';
import 'package:places_explorer/core/di/injector.dart';
import 'package:places_explorer/core/location/location_service.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';
import 'package:places_explorer/features/places/domain/repositories/places_repository.dart';

import 'support/in_memory_hydrated_storage.dart';

/// Stubs so the smoke test never touches the network or platform channels.
class _StubPlacesRepository implements PlacesRepository {
  @override
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    PlaceCategory? category,
    int radiusMeters = 1500,
  }) async {
    return const [];
  }
}

class _StubLocationService implements LocationService {
  @override
  Future<LatLng> currentLocation() async => LatLng(37.4220, -122.0841);

  @override
  Future<void> openSettings({required bool permanentlyDenied}) async {}
}

void main() {
  useInMemoryHydratedStorage();

  setUp(() {
    configureDependencies();
    getIt
      ..unregister<PlacesRepository>()
      ..registerFactory<PlacesRepository>(_StubPlacesRepository.new)
      ..unregister<LocationService>()
      ..registerFactory<LocationService>(_StubLocationService.new);
  });
  tearDown(getIt.reset);

  testWidgets('app boots to the map page and reaches a rendered state',
      (tester) async {
    await tester.pumpWidget(const PlacesExplorerApp());
    // Let the initial locationChanged -> fetch cycle settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Places Explorer'), findsOneWidget);
    expect(find.text('No places found within range.'), findsOneWidget);
  });
}
