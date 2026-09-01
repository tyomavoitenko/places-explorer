import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/place_category.dart';

part 'places_event.freezed.dart';

/// User/system intents the [PlacesBloc] reacts to.
///
/// A `sealed` Freezed union: each event is its own type, so `on<PlacesXxx>`
/// handlers get exact payload types and the compiler enforces we handle each one.
@freezed
sealed class PlacesEvent with _$PlacesEvent {
  /// App launched: acquire the device location (permission flow included), then
  /// fetch. On a location failure the BLoC surfaces it as a failure state.
  const factory PlacesEvent.started() = PlacesStarted;

  /// The user's location became known (or changed). Triggers a fetch.
  /// Also used as the "use approximate location" fallback after a denial.
  const factory PlacesEvent.locationChanged(LatLng location) =
      PlacesLocationChanged;

  /// A category chip was selected. `null` means "all supported categories".
  /// Re-fetches from the API (category is a server-side parameter).
  const factory PlacesEvent.categorySelected(PlaceCategory? category) =
      PlacesCategorySelected;

  /// Search box text changed. Debounced, then filters the loaded list in
  /// memory — no API call.
  const factory PlacesEvent.searchQueryChanged(String query) =
      PlacesSearchQueryChanged;

  /// A marker (or list row) was tapped. `null` clears the selection.
  const factory PlacesEvent.placeSelected(String? placeId) = PlacesPlaceSelected;

  /// Pull-to-refresh / retry. Re-runs the last fetch.
  const factory PlacesEvent.refreshRequested() = PlacesRefreshRequested;

  /// Open the OS location/permission settings screen. Fire-and-forget — no
  /// state change; the user retries afterwards.
  const factory PlacesEvent.locationSettingsRequested() =
      PlacesLocationSettingsRequested;
}
