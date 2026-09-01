import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:places_explorer/core/error/app_failure.dart';
import 'package:places_explorer/core/location/location_service.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';
import 'package:places_explorer/features/places/domain/repositories/places_repository.dart';
import 'package:places_explorer/features/places/presentation/bloc/places_bloc.dart';

class _MockPlacesRepository extends Mock implements PlacesRepository {}

class _MockLocationService extends Mock implements LocationService {}

void main() {
  late PlacesRepository repository;
  late LocationService locationService;

  final location = LatLng(37.4220, -122.0841);

  Place place(String id, String name) => Place(
        id: id,
        name: name,
        latitude: 37.42,
        longitude: -122.08,
        category: PlaceCategory.cafe,
      );

  final results = [place('1', 'Blue Bottle'), place('2', 'Red Rock')];

  void stubNearby(List<Place> value) {
    when(
      () => repository.getNearbyPlaces(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        category: any(named: 'category'),
      ),
    ).thenAnswer((_) async => value);
  }

  setUp(() {
    repository = _MockPlacesRepository();
    locationService = _MockLocationService();
    when(() => locationService.currentLocation()).thenAnswer((_) async => location);
  });

  group('started', () {
    blocTest<PlacesBloc, PlacesState>(
      'acquires the device location then fetches',
      setUp: () => stubNearby(results),
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) => bloc.add(const PlacesEvent.started()),
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.loading),
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.success)
            .having((s) => s.location, 'location', location),
      ],
      verify: (_) => verify(() => locationService.currentLocation()).called(1),
    );

    blocTest<PlacesBloc, PlacesState>(
      'emits [loading, failure] when location permission is denied',
      setUp: () {
        when(() => locationService.currentLocation()).thenThrow(
          const LocationFailure(LocationFailureReason.permissionDeniedForever),
        );
      },
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) => bloc.add(const PlacesEvent.started()),
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.loading),
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.failure)
            .having(
              (s) => s.failure,
              'failure',
              isA<LocationFailure>().having(
                (f) => f.reason,
                'reason',
                LocationFailureReason.permissionDeniedForever,
              ),
            ),
      ],
      verify: (_) => verifyNever(
        () => repository.getNearbyPlaces(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          category: any(named: 'category'),
        ),
      ),
    );
  });

  group('locationSettingsRequested', () {
    blocTest<PlacesBloc, PlacesState>(
      'opens app settings for a permanent denial, emits nothing',
      setUp: () {
        when(() => locationService.openSettings(
              permanentlyDenied: any(named: 'permanentlyDenied'),
            )).thenAnswer((_) async {});
      },
      build: () => PlacesBloc(repository, locationService),
      seed: () => const PlacesState(
        status: PlacesStatus.failure,
        failure: LocationFailure(
          LocationFailureReason.permissionDeniedForever,
        ),
      ),
      act: (bloc) => bloc.add(const PlacesEvent.locationSettingsRequested()),
      expect: () => const <PlacesState>[],
      verify: (_) => verify(
        () => locationService.openSettings(permanentlyDenied: true),
      ).called(1),
    );
  });

  group('locationChanged', () {
    blocTest<PlacesBloc, PlacesState>(
      'emits [loading, success] with the results',
      setUp: () => stubNearby(results),
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) => bloc.add(PlacesEvent.locationChanged(location)),
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.loading),
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.success)
            .having((s) => s.places, 'places', results)
            .having((s) => s.location, 'location', location),
      ],
    );

    blocTest<PlacesBloc, PlacesState>(
      'emits [loading, empty] when the API returns nothing',
      setUp: () => stubNearby(const []),
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) => bloc.add(PlacesEvent.locationChanged(location)),
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.loading),
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.empty),
      ],
    );

    blocTest<PlacesBloc, PlacesState>(
      'emits [loading, failure] carrying the AppFailure',
      setUp: () {
        when(
          () => repository.getNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            category: any(named: 'category'),
          ),
        ).thenThrow(const NetworkFailure());
      },
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) => bloc.add(PlacesEvent.locationChanged(location)),
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.loading),
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.failure)
            .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
      ],
    );
  });

  group('categorySelected', () {
    blocTest<PlacesBloc, PlacesState>(
      're-fetches with the chosen category once a location is known',
      setUp: () => stubNearby(results),
      build: () => PlacesBloc(repository, locationService),
      seed: () => PlacesState(location: location),
      act: (bloc) =>
          bloc.add(const PlacesEvent.categorySelected(PlaceCategory.park)),
      verify: (_) {
        verify(
          () => repository.getNearbyPlaces(
            latitude: location.latitude,
            longitude: location.longitude,
            category: PlaceCategory.park,
          ),
        ).called(1);
      },
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.loading),
        isA<PlacesState>()
            .having((s) => s.status, 'status', PlacesStatus.success)
            .having((s) => s.selectedCategory, 'category', PlaceCategory.park),
      ],
    );

    blocTest<PlacesBloc, PlacesState>(
      'only remembers the choice while no location is known (no API call)',
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) =>
          bloc.add(const PlacesEvent.categorySelected(PlaceCategory.cafe)),
      expect: () => [
        isA<PlacesState>()
            .having((s) => s.selectedCategory, 'category', PlaceCategory.cafe)
            .having((s) => s.status, 'status', PlacesStatus.initial),
      ],
      verify: (_) => verifyNever(
        () => repository.getNearbyPlaces(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          category: any(named: 'category'),
        ),
      ),
    );
  });

  group('searchQueryChanged', () {
    blocTest<PlacesBloc, PlacesState>(
      'debounces a burst into a single state with the last query',
      build: () => PlacesBloc(repository, locationService),
      seed: () => PlacesState(places: results),
      act: (bloc) => bloc
        ..add(const PlacesEvent.searchQueryChanged('bl'))
        ..add(const PlacesEvent.searchQueryChanged('blue')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<PlacesState>().having((s) => s.searchQuery, 'query', 'blue'),
      ],
      verify: (bloc) {
        expect(bloc.state.visiblePlaces, [results.first]);
      },
    );

    blocTest<PlacesBloc, PlacesState>(
      'does not call the API — search is an in-memory filter',
      build: () => PlacesBloc(repository, locationService),
      seed: () => PlacesState(places: results),
      act: (bloc) => bloc.add(const PlacesEvent.searchQueryChanged('red')),
      wait: const Duration(milliseconds: 400),
      verify: (_) => verifyNever(
        () => repository.getNearbyPlaces(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          category: any(named: 'category'),
        ),
      ),
    );
  });

  group('refreshRequested', () {
    blocTest<PlacesBloc, PlacesState>(
      're-runs the last fetch with the current location and category',
      setUp: () => stubNearby(results),
      build: () => PlacesBloc(repository, locationService),
      seed: () => PlacesState(
        location: location,
        selectedCategory: PlaceCategory.cafe,
      ),
      act: (bloc) => bloc.add(const PlacesEvent.refreshRequested()),
      verify: (_) {
        verify(
          () => repository.getNearbyPlaces(
            latitude: location.latitude,
            longitude: location.longitude,
            category: PlaceCategory.cafe,
          ),
        ).called(1);
      },
    );

    blocTest<PlacesBloc, PlacesState>(
      'is a no-op before a location is known',
      build: () => PlacesBloc(repository, locationService),
      act: (bloc) => bloc.add(const PlacesEvent.refreshRequested()),
      expect: () => const <PlacesState>[],
    );
  });
}
