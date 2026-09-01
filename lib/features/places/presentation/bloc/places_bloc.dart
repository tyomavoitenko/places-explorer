import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/place_category.dart';
import '../../domain/repositories/places_repository.dart';
import 'places_event.dart';
import 'places_state.dart';

export 'places_event.dart';
export 'places_state.dart';

/// Sits between the map UI and [PlacesRepository].
///
/// Concurrency strategy per event (via `bloc_concurrency` transformers):
/// * location / category changes -> `restartable`: a newer request cancels the
///   in-flight one, so the UI never shows a stale category's results.
/// * search -> `restartable` + a debounce delay: only the last keystroke in a
///   burst does work, and it's an in-memory filter, not a network call.
/// * refresh -> `droppable`: taps while a refresh is running are ignored.
class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc(this._repository) : super(const PlacesState()) {
    on<PlacesLocationChanged>(_onLocationChanged, transformer: restartable());
    on<PlacesCategorySelected>(_onCategorySelected, transformer: restartable());
    on<PlacesSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: restartable(),
    );
    on<PlacesRefreshRequested>(_onRefreshRequested, transformer: droppable());
  }

  final PlacesRepository _repository;

  static const Duration _searchDebounce = Duration(milliseconds: 300);

  Future<void> _onLocationChanged(
    PlacesLocationChanged event,
    Emitter<PlacesState> emit,
  ) {
    return _fetch(emit, location: event.location, category: state.selectedCategory);
  }

  Future<void> _onCategorySelected(
    PlacesCategorySelected event,
    Emitter<PlacesState> emit,
  ) async {
    final location = state.location;
    if (location == null) {
      // No location yet: remember the choice, fetch once we have coordinates.
      emit(state.copyWith(selectedCategory: event.category));
      return;
    }
    await _fetch(emit, location: location, category: event.category);
  }

  Future<void> _onRefreshRequested(
    PlacesRefreshRequested event,
    Emitter<PlacesState> emit,
  ) async {
    final location = state.location;
    if (location == null) return;
    await _fetch(emit, location: location, category: state.selectedCategory);
  }

  Future<void> _onSearchQueryChanged(
    PlacesSearchQueryChanged event,
    Emitter<PlacesState> emit,
  ) async {
    await Future<void>.delayed(_searchDebounce);
    // `restartable()` cancels this handler if another search event arrived
    // during the delay; guard against emitting on a closed sink.
    if (emit.isDone) return;
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _fetch(
    Emitter<PlacesState> emit, {
    required LatLng location,
    required PlaceCategory? category,
  }) async {
    emit(state.copyWith(status: PlacesStatus.loading, failure: null));
    try {
      final places = await _repository.getNearbyPlaces(
        latitude: location.latitude,
        longitude: location.longitude,
        category: category,
      );
      emit(
        state.copyWith(
          status: places.isEmpty ? PlacesStatus.empty : PlacesStatus.success,
          places: places,
          location: location,
          selectedCategory: category,
        ),
      );
    } on AppFailure catch (failure) {
      emit(state.copyWith(status: PlacesStatus.failure, failure: failure));
    }
  }
}
