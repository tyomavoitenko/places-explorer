import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/place_note.dart';

part 'notes_state.freezed.dart';
part 'notes_state.g.dart';

/// Notes keyed by place id. Persisted via [HydratedCubit], like favourites.
@freezed
abstract class NotesState with _$NotesState {
  const factory NotesState({
    @Default(<String, PlaceNote>{}) Map<String, PlaceNote> byPlaceId,
  }) = _NotesState;

  const NotesState._();

  factory NotesState.fromJson(Map<String, dynamic> json) =>
      _$NotesStateFromJson(json);

  PlaceNote? noteFor(String placeId) => byPlaceId[placeId];
}
