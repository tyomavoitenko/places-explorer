import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/features/notes/presentation/cubit/notes_cubit.dart';

import '../../support/in_memory_hydrated_storage.dart';

void main() {
  final storage = useInMemoryHydratedStorage();

  blocTest<NotesCubit, NotesState>(
    'save then overwrite the note for a place',
    build: NotesCubit.new,
    act: (cubit) => cubit
      ..save('p1', const PlaceNote(text: 'first', rating: 3))
      ..save('p1', const PlaceNote(text: 'second')),
    expect: () => [
      isA<NotesState>().having(
        (s) => s.noteFor('p1'),
        'note',
        const PlaceNote(text: 'first', rating: 3),
      ),
      isA<NotesState>().having(
        (s) => s.noteFor('p1'),
        'note',
        const PlaceNote(text: 'second'),
      ),
    ],
  );

  blocTest<NotesCubit, NotesState>(
    'delete removes the note; unknown id is a no-op',
    build: NotesCubit.new,
    seed: () => const NotesState(byPlaceId: {'p1': PlaceNote(text: 'keep me')}),
    act: (cubit) => cubit
      ..delete('unknown')
      ..delete('p1'),
    expect: () => [
      isA<NotesState>().having((s) => s.noteFor('p1'), 'note', isNull),
    ],
  );

  test('a note survives a restart via hydrated storage', () {
    NotesCubit().save('p1', const PlaceNote(text: 'great coffee', rating: 5));

    final restored = NotesCubit();

    expect(
      restored.state.noteFor('p1'),
      const PlaceNote(text: 'great coffee', rating: 5),
    );
    expect(storage.read('NotesCubit'), isNotNull);
  });
}
