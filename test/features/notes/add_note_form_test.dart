import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:places_explorer/features/notes/presentation/widgets/add_note_form.dart';
import 'package:places_explorer/features/places/domain/entities/place.dart';
import 'package:places_explorer/features/places/domain/entities/place_category.dart';

import '../../support/in_memory_hydrated_storage.dart';

void main() {
  useInMemoryHydratedStorage();

  late NotesCubit cubit;

  final place = Place(
    id: 'p1',
    name: 'Blue Bottle',
    latitude: 1,
    longitude: 2,
    category: PlaceCategory.cafe,
  );

  setUp(() => cubit = NotesCubit());

  Future<void> openForm(WidgetTester tester, {PlaceNote? existing}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NotesCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      showAddNoteSheet(context, place, existing: existing),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows a validation error and does not save when text is empty',
      (tester) async {
    await openForm(tester);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Write something first.'), findsOneWidget);
    expect(cubit.state.noteFor('p1'), isNull);
  });

  testWidgets('saves text + rating and closes the sheet', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextFormField), 'Excellent espresso');
    await tester.tap(find.byIcon(Icons.star_border).at(3)); // 4th star
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget); // sheet dismissed
    expect(
      cubit.state.noteFor('p1'),
      const PlaceNote(text: 'Excellent espresso', rating: 4),
    );
  });

  testWidgets('pre-fills when editing and can delete', (tester) async {
    cubit.save('p1', const PlaceNote(text: 'old note', rating: 2));

    await openForm(tester, existing: cubit.state.noteFor('p1'));

    expect(find.text('old note'), findsOneWidget);
    expect(find.text('Edit note'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(cubit.state.noteFor('p1'), isNull);
  });
}
