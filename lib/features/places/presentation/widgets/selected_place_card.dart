import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/place.dart';
import '../bloc/places_bloc.dart';
import 'place_category_ui.dart';
import 'place_details_sheet.dart';

/// Compact info card shown above the map when a marker is selected. The full
/// details sheet (favourite, note) is opened from here in the next phase.
class SelectedPlaceCard extends StatelessWidget {
  const SelectedPlaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlacesBloc, PlacesState, Place?>(
      selector: (state) => state.selectedPlace,
      builder: (context, place) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: place == null
              ? const SizedBox.shrink()
              : _Card(key: ValueKey(place.id), place: place),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.place, super.key});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final distance = formatDistance(place.distanceMeters);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => showPlaceDetailsSheet(context, place),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              CircleAvatar(child: Icon(place.category.icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [place.category.label, ?distance].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (place.address != null)
                      Text(
                        place.address!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Dismiss',
                onPressed: () => context
                    .read<PlacesBloc>()
                    .add(const PlacesEvent.placeSelected(null)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
