import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../../../notes/presentation/widgets/add_note_form.dart';
import '../../../notes/presentation/widgets/place_note_card.dart';
import '../../domain/entities/place.dart';
import 'favorite_button.dart';
import 'place_category_ui.dart';

/// The details content for a place, shared by the bottom sheet and the
/// `/place/:id` page. Sections render only when their data is present.
class PlaceDetailsView extends StatelessWidget {
  const PlaceDetailsView({required this.place, this.scrollController, super.key});

  final Place place;

  /// Supplied by the draggable sheet so the content scrolls with the drag.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = formatDistance(place.distanceMeters);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      shrinkWrap: true,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Icon(place.category.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(place.name, style: theme.textTheme.headlineSmall),
            ),
            FavoriteButton(place: place),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [place.category.label, ?distance].join('  ·  '),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Divider(height: 32),
        if (place.address != null)
          _DetailRow(icon: Icons.place_outlined, text: place.address!),
        if (place.openingHours != null)
          _DetailRow(icon: Icons.schedule, text: place.openingHours!),
        if (place.website != null)
          _DetailRow(icon: Icons.language, text: place.website!),
        if (place.description != null) ...[
          const SizedBox(height: 8),
          Text(place.description!, style: theme.textTheme.bodyLarge),
        ],
        if (place.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in place.tags.take(8))
                Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        _NoteSection(place: place),
      ],
    );
  }
}

/// Shows the saved note or an "add note" prompt, driven by [NotesCubit].
class _NoteSection extends StatelessWidget {
  const _NoteSection({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final note = context.select<NotesCubit, PlaceNote?>(
      (cubit) => cubit.state.noteFor(place.id),
    );

    if (note == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => showAddNoteSheet(context, place),
          icon: const Icon(Icons.edit_note),
          label: const Text('Add note'),
        ),
      );
    }

    return PlaceNoteCard(
      note: note,
      onEdit: () => showAddNoteSheet(context, place, existing: note),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
