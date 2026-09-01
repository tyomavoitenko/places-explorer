import 'package:freezed_annotation/freezed_annotation.dart';

import 'place_category.dart';

part 'place.freezed.dart';
part 'place.g.dart';

/// A place the app shows on the map and in lists.
///
/// This is the domain entity, distinct from `PlacePropertiesDto` (the wire
/// shape). It also carries `fromJson`/`toJson` because the favorites feature
/// persists a `Place` snapshot via `hydrated_bloc` — a dedicated `FavoritePlace`
/// model would be near-identical and not worth the duplication for this app.
@freezed
abstract class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required PlaceCategory category,

    /// Raw Geoapify category strings, kept for display chips on the details sheet.
    @Default(<String>[]) List<String> tags,
    String? address,
    int? distanceMeters,
    String? description,
    String? openingHours,
    String? website,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
