import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';

import '../../support/in_memory_hydrated_storage.dart';

void main() {
  final storage = useInMemoryHydratedStorage();

  Place place(String id) => Place(
        id: id,
        name: 'Place $id',
        latitude: 1,
        longitude: 2,
        category: PlaceCategory.cafe,
      );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle adds then removes a place',
    build: FavoritesCubit.new,
    act: (cubit) => cubit
      ..toggle(place('a'))
      ..toggle(place('a')),
    expect: () => [
      isA<FavoritesState>().having((s) => s.contains('a'), 'contains a', true),
      isA<FavoritesState>().having((s) => s.contains('a'), 'contains a', false),
    ],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'remove is a no-op for an unknown id',
    build: FavoritesCubit.new,
    act: (cubit) => cubit.remove('missing'),
    expect: () => const <FavoritesState>[],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'places are ordered most-recently-added first',
    build: FavoritesCubit.new,
    act: (cubit) => cubit
      ..toggle(place('a'))
      ..toggle(place('b')),
    verify: (cubit) {
      expect(cubit.state.places.map((p) => p.id), ['b', 'a']);
    },
  );

  test('state survives a restart via hydrated storage', () {
    FavoritesCubit()
      ..toggle(place('x'))
      ..toggle(place('y'));

    // A fresh cubit reading the same storage restores the favourites.
    final restored = FavoritesCubit();

    expect(restored.state.contains('x'), isTrue);
    expect(restored.state.contains('y'), isTrue);
    expect(storage.read('FavoritesCubit'), isNotNull);
  });
}
