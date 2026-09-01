import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';
import '../../domain/repositories/places_repository.dart';
import '../api/places_api_service.dart';
import '../mappers/place_mapper.dart';

/// Geoapify-backed [PlacesRepository].
///
/// Responsibilities that belong here and nowhere else:
/// * composing Geoapify's `circle:` / `proximity:` parameter syntax (note:
///   longitude first, GeoJSON order);
/// * deciding what "all categories" means;
/// * turning transport errors into [AppFailure] via [mapDioException].
class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._api);

  final PlacesApiService _api;

  static const int _defaultRadiusMeters = 1500;
  static const int _resultLimit = 40;

  /// The set queried when no specific category is selected.
  static const List<String> _allCategories = [
    'catering.restaurant',
    'catering.cafe',
    'commercial.supermarket',
    'tourism.sights',
    'leisure.park',
  ];

  @override
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    PlaceCategory? category,
    int radiusMeters = _defaultRadiusMeters,
  }) async {
    final categories =
        (category == null || category == PlaceCategory.other)
            ? _allCategories.join(',')
            : category.apiValue;

    try {
      final response = await _api.getNearbyPlaces(
        categories: categories,
        filter: 'circle:$longitude,$latitude,$radiusMeters',
        bias: 'proximity:$longitude,$latitude',
        limit: _resultLimit,
      );
      return response.toEntities();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
