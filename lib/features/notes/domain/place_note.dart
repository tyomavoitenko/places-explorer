import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_note.freezed.dart';
part 'place_note.g.dart';

/// A user's private note about a place: some text and an optional 1–5 rating.
@freezed
abstract class PlaceNote with _$PlaceNote {
  const factory PlaceNote({
    required String text,
    int? rating,
  }) = _PlaceNote;

  const PlaceNote._();

  factory PlaceNote.fromJson(Map<String, dynamic> json) =>
      _$PlaceNoteFromJson(json);

  bool get hasRating => rating != null;
}
