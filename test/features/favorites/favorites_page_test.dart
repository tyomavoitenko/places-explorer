import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:places_explorer/features/favorites/presentation/pages/favorites_page.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';

import '../../support/in_memory_hydrated_storage.dart';

void main() {
  useInMemoryHydratedStorage();

  late FavoritesCubit cubit;

  Place place(String id) => Place(
        id: id,
        name: 'Place $id',
        latitude: 1,
        longitude: 2,
        category: PlaceCategory.park,
      );

  setUp(() => cubit = FavoritesCubit());

  Widget wrap() => MaterialApp(
        home: BlocProvider<FavoritesCubit>.value(
          value: cubit,
          child: const FavoritesPage(),
        ),
      );

  testWidgets('shows the empty state with no favorites', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.textContaining('No favorites yet'), findsOneWidget);
  });

  testWidgets('lists favorites and removes one on swipe', (tester) async {
    cubit
      ..toggle(place('a'))
      ..toggle(place('b'));

    await tester.pumpWidget(wrap());

    expect(find.text('Place a'), findsOneWidget);
    expect(find.text('Place b'), findsOneWidget);

    await tester.drag(find.text('Place b'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Place b'), findsNothing);
    expect(cubit.state.contains('b'), isFalse);
    expect(cubit.state.contains('a'), isTrue);
  });
}
