import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/features/places/data/mappers/place_mapper.dart';
import 'package:places_explorer/features/places/data/models/place_dto.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';

void main() {
  group('PlaceCategory.fromApiValues', () {
    test('classifies by prefix, deepest nesting still resolves to the bucket',
        () {
      expect(
        PlaceCategory.fromApiValues(
          ['catering', 'catering.cafe', 'catering.cafe.coffee_shop'],
        ),
        PlaceCategory.cafe,
      );
    });

    test('falls back to other when nothing matches', () {
      expect(
        PlaceCategory.fromApiValues(['healthcare', 'healthcare.pharmacy']),
        PlaceCategory.other,
      );
    });

    test('ignores condition tags like wheelchair / no_access', () {
      expect(
        PlaceCategory.fromApiValues(
          ['tourism', 'tourism.sights', 'wheelchair.limited'],
        ),
        PlaceCategory.sight,
      );
    });
  });

  group('PlacesResponseDto.toEntities', () {
    late List<Place> entities;

    setUpAll(() {
      final raw = File('test/fixtures/geoapify_places.json').readAsStringSync();
      final dto = PlacesResponseDto.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      entities = dto.toEntities();
    });

    test('maps every feature', () {
      expect(entities, hasLength(3));
    });

    test('uses name when present', () {
      final trex = entities.firstWhere((p) => p.id.contains('5374616e'));
      expect(trex.name, 'Stan The T-Rex');
      expect(trex.category, PlaceCategory.sight);
      expect(trex.distanceMeters, 71);
      expect(trex.description, contains('go extinct'));
    });

    test('falls back to address_line1 when name is missing', () {
      final unnamedPark = entities[1];
      expect(unnamedPark.name, 'Mountain View, California');
      expect(unnamedPark.category, PlaceCategory.park);
    });

    test('carries opening hours and address through', () {
      final costa = entities.last;
      expect(costa.openingHours, startsWith('Mo-Fr'));
      expect(costa.address, contains('Huff Avenue'));
    });
  });
}
