import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/places_bloc.dart';
import 'place_list_tile.dart';

/// Bottom-sheet list of the currently visible places. Tapping a row selects it
/// on the map and closes the sheet.
///
/// Opened with [show], which re-provides the caller's [PlacesBloc] into the
/// sheet's route (a modal sheet builds under the root navigator, outside the
/// page's `BlocProvider`).
class PlacesListSheet extends StatelessWidget {
  const PlacesListSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<PlacesBloc>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const PlacesListSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return BlocBuilder<PlacesBloc, PlacesState>(
          builder: (context, state) {
            final places = state.visiblePlaces;

            if (places.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No places to show.'),
                ),
              );
            }

            return ListView.separated(
              controller: scrollController,
              itemCount: places.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final place = places[index];
                return PlaceListTile(
                  place: place,
                  onTap: () {
                    context
                        .read<PlacesBloc>()
                        .add(PlacesEvent.placeSelected(place.id));
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
