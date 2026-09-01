import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';
import 'package:places_explorer/features/places/presentation/widgets/place_details_view.dart';

import '../../support/in_memory_hydrated_storage.dart';

void main() {
  useInMemoryHydratedStorage();

  Place buildPlace({
    String? address,
    String? openingHours,
    String? description,
    String? website,
    List<String> tags = const [],
  }) {
    return Place(
      id: 'p1',
      name: 'Blue Bottle Coffee',
      latitude: 37.42,
      longitude: -122.08,
      category: PlaceCategory.cafe,
      address: address,
      openingHours: openingHours,
      description: description,
      website: website,
      tags: tags,
      distanceMeters: 240,
    );
  }

  Widget wrap(Place place) => MaterialApp(
        home: BlocProvider(
          create: (_) => FavoritesCubit(),
          child: Scaffold(body: PlaceDetailsView(place: place)),
        ),
      );

  testWidgets('renders name, category and distance', (tester) async {
    await tester.pumpWidget(wrap(buildPlace()));

    expect(find.text('Blue Bottle Coffee'), findsOneWidget);
    expect(find.textContaining('Cafés'), findsOneWidget);
    expect(find.textContaining('240 m'), findsOneWidget);
  });

  testWidgets('shows optional sections only when present', (tester) async {
    await tester.pumpWidget(
      wrap(
        buildPlace(
          address: '1 Castro St',
          openingHours: 'Mo-Fr 07:00-15:00',
          description: 'Third-wave coffee bar.',
          tags: const ['catering', 'catering.cafe'],
        ),
      ),
    );

    expect(find.text('1 Castro St'), findsOneWidget);
    expect(find.text('Mo-Fr 07:00-15:00'), findsOneWidget);
    expect(find.text('Third-wave coffee bar.'), findsOneWidget);
    expect(find.text('catering.cafe'), findsOneWidget);
  });

  testWidgets('omits sections when data is missing', (tester) async {
    await tester.pumpWidget(wrap(buildPlace()));

    expect(find.byIcon(Icons.place_outlined), findsNothing);
    expect(find.byIcon(Icons.schedule), findsNothing);
    expect(find.byIcon(Icons.language), findsNothing);
  });
}
