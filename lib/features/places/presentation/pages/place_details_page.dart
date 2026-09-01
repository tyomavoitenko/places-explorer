import 'package:flutter/material.dart';

import '../../domain/entities/place.dart';
import '../widgets/place_details_view.dart';

/// Full-page view for the `/place/:id` deep link. Renders the same content as
/// the bottom sheet, or a fallback when the place isn't in memory (cold link).
class PlaceDetailsPage extends StatelessWidget {
  const PlaceDetailsPage({required this.placeId, this.place, super.key});

  final String placeId;
  final Place? place;

  @override
  Widget build(BuildContext context) {
    final place = this.place;

    return Scaffold(
      appBar: AppBar(title: Text(place?.name ?? 'Place')),
      body: place == null
          ? const _NotLoaded()
          : PlaceDetailsView(place: place),
    );
  }
}

class _NotLoaded extends StatelessWidget {
  const _NotLoaded();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'Open this place from the map to see its details.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
