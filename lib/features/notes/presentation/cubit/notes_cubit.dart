import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../domain/place_note.dart';
import 'notes_state.dart';

export '../../domain/place_note.dart';
export 'notes_state.dart';

/// App-wide place notes. `HydratedCubit` so a note survives an app restart with
/// no persistence code of our own.
class NotesCubit extends HydratedCubit<NotesState> {
  NotesCubit() : super(const NotesState());

  /// Creates or replaces the note for [placeId].
  void save(String placeId, PlaceNote note) {
    emit(
      state.copyWith(byPlaceId: {...state.byPlaceId, placeId: note}),
    );
  }

  void delete(String placeId) {
    if (!state.byPlaceId.containsKey(placeId)) return;
    emit(
      state.copyWith(
        byPlaceId: Map<String, PlaceNote>.of(state.byPlaceId)..remove(placeId),
      ),
    );
  }

  @override
  NotesState fromJson(Map<String, dynamic> json) => NotesState.fromJson(json);

  @override
  Map<String, dynamic> toJson(NotesState state) => state.toJson();
}
