import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';

part 'places_state.freezed.dart';

enum PlacesStatus { initial, loading, success, empty, failure }

/// One immutable state class (not a union) with a [status] enum.
///
/// A union (`loading` / `loaded` / ... as separate types) reads nicely until the
/// map needs to keep showing the previous markers *while* a refresh runs. With
/// one class we just flip `status` to `loading` and leave `places` in place.
@freezed
abstract class PlacesState with _$PlacesState {
  const factory PlacesState({
    @Default(PlacesStatus.initial) PlacesStatus status,

    /// Full result of the last successful fetch.
    @Default(<Place>[]) List<Place> places,
    @Default('') String searchQuery,
    PlaceCategory? selectedCategory,
    LatLng? location,

    /// `id` of the place whose marker is currently tapped, if any.
    String? selectedPlaceId,

    /// Set only when [status] is [PlacesStatus.failure].
    AppFailure? failure,
  }) = _PlacesState;

  const PlacesState._();

  /// The tapped place, resolved against the full [places] list.
  Place? get selectedPlace {
    if (selectedPlaceId == null) return null;
    for (final place in places) {
      if (place.id == selectedPlaceId) return place;
    }
    return null;
  }

  /// [places] after the in-memory search filter. Derived, never stored, so it
  /// can't drift out of sync with [places] / [searchQuery].
  List<Place> get visiblePlaces {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return places;
    return places
        .where(
          (place) =>
              place.name.toLowerCase().contains(query) ||
              (place.address?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  bool get hasLocation => location != null;
}
