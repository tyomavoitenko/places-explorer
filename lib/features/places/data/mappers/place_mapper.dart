import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';
import '../models/place_dto.dart';

/// DTO -> entity translation. Plain functions, not a class: there's no state and
/// nothing to inject, so a class would only add ceremony.
extension PlacesResponseMapper on PlacesResponseDto {
  List<Place> toEntities() =>
      features.map((feature) => feature.properties.toEntity()).toList();
}

extension PlacePropertiesMapper on PlacePropertiesDto {
  Place toEntity() {
    return Place(
      id: placeId,
      // `name` is often missing for unnamed POIs; fall back to the first
      // address line, then to a generic label.
      name: name ?? addressLine1 ?? 'Unnamed place',
      latitude: lat,
      longitude: lon,
      category: PlaceCategory.fromApiValues(categories),
      tags: categories,
      address: formatted ?? addressLine2,
      distanceMeters: distance?.round(),
      description: description,
      openingHours: openingHours,
      website: website,
    );
  }
}
