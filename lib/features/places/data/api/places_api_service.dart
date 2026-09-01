import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/place_dto.dart';

part 'places_api_service.g.dart';

/// Typed Geoapify Places client. This is a literal 1:1 of the HTTP endpoint —
/// it takes the query parameters exactly as the API wants them (pre-formatted
/// `filter`/`bias` strings). Turning coordinates into those strings is the
/// repository's job, not this layer's.
///
/// The `apiKey` query parameter is added globally by `ApiKeyInterceptor`, so it
/// never appears here.
@RestApi()
abstract class PlacesApiService {
  factory PlacesApiService(Dio dio, {String? baseUrl}) = _PlacesApiService;

  /// `GET /v2/places?categories=..&filter=circle:lon,lat,r&bias=proximity:lon,lat`
  @GET('/v2/places')
  Future<PlacesResponseDto> getNearbyPlaces({
    @Query('categories') required String categories,
    @Query('filter') required String filter,
    @Query('bias') required String bias,
    @Query('limit') required int limit,
    @Query('lang') String lang = 'en',
  });
}
