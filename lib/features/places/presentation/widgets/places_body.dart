import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/location/location_service.dart';
import '../bloc/places_bloc.dart';
import 'place_list_tile.dart';

/// Renders the five [PlacesStatus] cases. The map replaces the list body in a
/// later phase; the state handling stays the same.
class PlacesBody extends StatelessWidget {
  const PlacesBody({super.key});

  void _refresh(BuildContext context) =>
      context.read<PlacesBloc>().add(const PlacesEvent.refreshRequested());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        return switch (state.status) {
          // Refresh over existing data: keep the list, show a thin progress bar.
          PlacesStatus.loading when state.places.isNotEmpty =>
            _PlacesList(state: state, refreshing: true),
          PlacesStatus.initial || PlacesStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          PlacesStatus.failure when state.failure is LocationFailure =>
            _LocationFailureView(failure: state.failure! as LocationFailure),
          PlacesStatus.failure => _CenteredMessage(
              icon: Icons.cloud_off,
              text: state.failure?.message ?? 'Something went wrong.',
              onRetry: () => _refresh(context),
            ),
          PlacesStatus.empty => _CenteredMessage(
              icon: Icons.wrong_location_outlined,
              text: 'No places found within range.',
              onRetry: () => _refresh(context),
            ),
          PlacesStatus.success => _PlacesList(state: state),
        };
      },
    );
  }
}

class _PlacesList extends StatelessWidget {
  const _PlacesList({required this.state, this.refreshing = false});

  final PlacesState state;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final places = state.visiblePlaces;

    if (places.isEmpty) {
      return _CenteredMessage(
        icon: Icons.search_off,
        text: 'Nothing matches "${state.searchQuery}".',
      );
    }

    return Column(
      children: [
        if (refreshing) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => context
                .read<PlacesBloc>()
                .add(const PlacesEvent.refreshRequested()),
            child: ListView.separated(
              itemCount: places.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  PlaceListTile(place: places[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Location-permission / services-off failure. Offers: open settings, retry the
/// location flow, or fall back to an approximate location.
class _LocationFailureView extends StatelessWidget {
  const _LocationFailureView({required this.failure});

  final LocationFailure failure;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlacesBloc>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_disabled,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(failure.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (failure.canOpenSettings)
                  FilledButton.tonal(
                    onPressed: () => bloc.add(
                      const PlacesEvent.locationSettingsRequested(),
                    ),
                    child: const Text('Open settings'),
                  ),
                OutlinedButton(
                  onPressed: () => bloc.add(const PlacesEvent.started()),
                  child: const Text('Try again'),
                ),
                TextButton(
                  onPressed: () => bloc.add(
                    PlacesEvent.locationChanged(kFallbackLocation),
                  ),
                  child: const Text('Use approximate location'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
