import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../places/domain/entities/place.dart';
import '../cubit/notes_cubit.dart';
import 'rating_stars.dart';

/// Opens the note editor as a modal bottom sheet. A modal route builds under the
/// root navigator, so the caller's [NotesCubit] is re-provided into it.
Future<void> showAddNoteSheet(
  BuildContext context,
  Place place, {
  PlaceNote? existing,
}) {
  final notesCubit = context.read<NotesCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<NotesCubit>.value(
      value: notesCubit,
      child: AddNoteForm(place: place, existing: existing),
    ),
  );
}

/// Plain `Form` + `TextFormField` — no `formz`. With two fields and no
/// cross-field rules, a form key and a validator callback are all this needs;
/// `formz` would be scaffolding without a payoff here.
class AddNoteForm extends StatefulWidget {
  const AddNoteForm({required this.place, this.existing, super.key});

  final Place place;
  final PlaceNote? existing;

  @override
  State<AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController =
      TextEditingController(text: widget.existing?.text ?? '');
  int? _rating;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<NotesCubit>().save(
          widget.place.id,
          PlaceNote(text: _textController.text.trim(), rating: _rating),
        );
    Navigator.of(context).pop();
  }

  void _delete() {
    context.read<NotesCubit>().delete(widget.place.id);
    Navigator.of(context).pop();
  }

  String? _validateText(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Write something first.';
    if (text.length < 3) return 'A little more detail?';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit note' : 'Add note',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              widget.place.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: 280,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Why does this place matter to you?',
                border: OutlineInputBorder(),
              ),
              validator: _validateText,
            ),
            Row(
              children: [
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                RatingInput(
                  value: _rating,
                  onChanged: (value) => setState(() => _rating = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_isEditing)
                  TextButton(
                    onPressed: _delete,
                    child: const Text('Delete'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
