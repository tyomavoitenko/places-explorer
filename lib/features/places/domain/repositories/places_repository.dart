import '../entities/place.dart';
import '../entities/place_category.dart';

/// Contract the presentation layer depends on. The concrete implementation
/// (Retrofit + Geoapify) lives in `data/` and is bound in the injector, so the
/// BLoC and its tests never touch `dio`.
///
/// Throws [AppFailure] on any error — callers `try/catch` rather than unwrap a
/// result type.
abstract interface class PlacesRepository {
  /// Nearby places within [radiusMeters], nearest first.
  ///
  /// [category] `null` (or [PlaceCategory.other]) means "all supported
  /// categories".
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    PlaceCategory? category,
    int radiusMeters,
  });
}
