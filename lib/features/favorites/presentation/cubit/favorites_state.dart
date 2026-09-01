import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../places/domain/entities/place.dart';

part 'favorites_state.freezed.dart';
part 'favorites_state.g.dart';

/// Favourited places, keyed by id. Storing the whole [Place] (not just the id)
/// means the favorites screen renders with no network call — a snapshot is
/// enough for a list, and re-fetching one place by id isn't wired.
@freezed
abstract class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @Default(<String, Place>{}) Map<String, Place> byId,
  }) = _FavoritesState;

  const FavoritesState._();

  factory FavoritesState.fromJson(Map<String, dynamic> json) =>
      _$FavoritesStateFromJson(json);

  bool contains(String id) => byId.containsKey(id);

  /// Most-recently-added first.
  List<Place> get places => byId.values.toList().reversed.toList();
}
