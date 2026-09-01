import 'package:flutter/material.dart';

import '../cubit/notes_cubit.dart';
import 'rating_stars.dart';

/// The saved note, shown in the place details view. Tap to edit.
class PlaceNoteCard extends StatelessWidget {
  const PlaceNoteCard({required this.note, required this.onEdit, super.key});

  final PlaceNote note;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Your note', style: theme.textTheme.labelLarge),
                  const Spacer(),
                  if (note.hasRating) RatingStars(rating: note.rating!),
                ],
              ),
              const SizedBox(height: 8),
              Text(note.text, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
