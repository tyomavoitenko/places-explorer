import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../places/domain/entities/place.dart';
import 'favorites_state.dart';

export 'favorites_state.dart';

/// App-wide favourites. A `Cubit`, not a full BLoC: the only operation is
/// "toggle", there's no async orchestration to model with events.
///
/// `HydratedCubit` persists every state change to disk and restores it on the
/// next launch — no repository, no manual serialization plumbing.
class FavoritesCubit extends HydratedCubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  void toggle(Place place) {
    final next = Map<String, Place>.of(state.byId);
    if (next.remove(place.id) == null) {
      next[place.id] = place;
    }
    emit(state.copyWith(byId: next));
  }

  void remove(String id) {
    if (!state.contains(id)) return;
    emit(state.copyWith(byId: Map<String, Place>.of(state.byId)..remove(id)));
  }

  @override
  FavoritesState fromJson(Map<String, dynamic> json) =>
      FavoritesState.fromJson(json);

  @override
  Map<String, dynamic> toJson(FavoritesState state) => state.toJson();
}
