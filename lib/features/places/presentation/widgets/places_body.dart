import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../bloc/places_bloc.dart';
import 'place_status_views.dart';
import 'places_map.dart';
import 'selected_place_card.dart';

/// The map plus every [PlacesStatus] overlay stacked on top of it. The list is
/// a separate bottom sheet (see [PlacesListSheet]).
class PlacesBody extends StatelessWidget {
  const PlacesBody({super.key});

  void _refresh(BuildContext context) =>
      context.read<PlacesBloc>().add(const PlacesEvent.refreshRequested());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        return Stack(
          children: [
            const Positioned.fill(child: PlacesMap()),

            // First-load spinner — only when there's nothing to show yet.
            if (state.status == PlacesStatus.loading && state.places.isEmpty)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x11000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Refresh over existing markers: thin bar, map stays interactive.
            if (state.status == PlacesStatus.loading && state.places.isNotEmpty)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),

            if (state.status == PlacesStatus.failure)
              Positioned.fill(
                child: state.failure is LocationFailure
                    ? LocationFailureView(
                        failure: state.failure! as LocationFailure,
                      )
                    : CenteredMessage(
                        icon: Icons.cloud_off,
                        text: state.failure?.message ?? 'Something went wrong.',
                        onRetry: () => _refresh(context),
                      ),
              ),

            if (state.status == PlacesStatus.empty)
              Positioned.fill(
                child: CenteredMessage(
                  icon: Icons.wrong_location_outlined,
                  text: 'No places found within range.',
                  onRetry: () => _refresh(context),
                ),
              ),

            // Search filtered everything out — non-blocking hint, keep the map.
            if (state.status == PlacesStatus.success &&
                state.visiblePlaces.isEmpty &&
                state.searchQuery.trim().isNotEmpty)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Chip(
                    avatar: const Icon(Icons.search_off, size: 18),
                    label: Text('Nothing matches "${state.searchQuery}"'),
                  ),
                ),
              ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(child: SelectedPlaceCard()),
            ),
          ],
        );
      },
    );
  }
}
