import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:places_explorer/core/error/app_failure.dart';
import 'package:places_explorer/features/places/data/api/places_api_service.dart';
import 'package:places_explorer/features/places/data/models/place_dto.dart';
import 'package:places_explorer/features/places/data/repositories/places_repository_impl.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';

class _MockApi extends Mock implements PlacesApiService {}

void main() {
  late _MockApi api;
  late PlacesRepositoryImpl repository;

  final response = PlacesResponseDto.fromJson(
    jsonDecode(File('test/fixtures/geoapify_places.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  setUp(() {
    api = _MockApi();
    repository = PlacesRepositoryImpl(api);
  });

  void stubSuccess() {
    when(
      () => api.getNearbyPlaces(
        categories: any(named: 'categories'),
        filter: any(named: 'filter'),
        bias: any(named: 'bias'),
        limit: any(named: 'limit'),
        lang: any(named: 'lang'),
      ),
    ).thenAnswer((_) async => response);
  }

  test('builds circle/proximity params (longitude first) and maps DTOs',
      () async {
    stubSuccess();

    final places = await repository.getNearbyPlaces(
      latitude: 37.42,
      longitude: -122.08,
    );

    final captured = verify(
      () => api.getNearbyPlaces(
        categories: captureAny(named: 'categories'),
        filter: captureAny(named: 'filter'),
        bias: captureAny(named: 'bias'),
        limit: captureAny(named: 'limit'),
        lang: any(named: 'lang'),
      ),
    ).captured;

    expect(captured[0], contains('catering.restaurant')); // "all" category set
    expect(captured[1], 'circle:-122.08,37.42,1500');
    expect(captured[2], 'proximity:-122.08,37.42');
    expect(captured[3], 40);

    expect(places, hasLength(3));
    expect(places.first.name, 'Stan The T-Rex');
  });

  test('sends a single category value when one is selected', () async {
    stubSuccess();

    await repository.getNearbyPlaces(
      latitude: 1,
      longitude: 2,
      category: PlaceCategory.cafe,
    );

    verify(
      () => api.getNearbyPlaces(
        categories: 'catering.cafe',
        filter: any(named: 'filter'),
        bias: any(named: 'bias'),
        limit: any(named: 'limit'),
        lang: any(named: 'lang'),
      ),
    ).called(1);
  });

  test('translates a DioException into an AppFailure', () {
    when(
      () => api.getNearbyPlaces(
        categories: any(named: 'categories'),
        filter: any(named: 'filter'),
        bias: any(named: 'bias'),
        limit: any(named: 'limit'),
        lang: any(named: 'lang'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/v2/places'),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(
      () => repository.getNearbyPlaces(latitude: 1, longitude: 2),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
