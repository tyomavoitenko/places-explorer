import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_dto.freezed.dart';
part 'place_dto.g.dart';

/// Wire model for `GET /v2/places`. Mirrors the GeoJSON response 1:1 — no
/// interpretation happens here, that is the mapper's job. Unknown JSON keys
/// (and there are many) are ignored by `json_serializable`.
@freezed
abstract class PlacesResponseDto with _$PlacesResponseDto {
  const factory PlacesResponseDto({
    @Default(<PlaceFeatureDto>[]) List<PlaceFeatureDto> features,
  }) = _PlacesResponseDto;

  factory PlacesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PlacesResponseDtoFromJson(json);
}

@freezed
abstract class PlaceFeatureDto with _$PlaceFeatureDto {
  const factory PlaceFeatureDto({
    required PlacePropertiesDto properties,
  }) = _PlaceFeatureDto;

  factory PlaceFeatureDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceFeatureDtoFromJson(json);
}

/// The `properties` object of a feature. Only the fields the app actually uses
/// are declared.
@freezed
abstract class PlacePropertiesDto with _$PlacePropertiesDto {
  const factory PlacePropertiesDto({
    @JsonKey(name: 'place_id') required String placeId,
    required double lat,
    required double lon,
    String? name,
    @Default(<String>[]) List<String> categories,
    String? formatted,
    @JsonKey(name: 'address_line1') String? addressLine1,
    @JsonKey(name: 'address_line2') String? addressLine2,
    // Integer metres in practice; typed loosely so a `71.0` never crashes us.
    num? distance,
    String? description,
    @JsonKey(name: 'opening_hours') String? openingHours,
    String? website,
  }) = _PlacePropertiesDto;

  factory PlacePropertiesDto.fromJson(Map<String, dynamic> json) =>
      _$PlacePropertiesDtoFromJson(json);
}
