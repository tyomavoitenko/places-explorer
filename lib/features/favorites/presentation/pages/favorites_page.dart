import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../places/presentation/widgets/place_details_sheet.dart';
import '../../../places/presentation/widgets/place_list_tile.dart';
import '../cubit/favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final places = state.places;

          if (places.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            itemCount: places.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final place = places[index];
              return Dismissible(
                key: ValueKey(place.id),
                direction: DismissDirection.endToStart,
                background: ColoredBox(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete_outline),
                    ),
                  ),
                ),
                onDismissed: (_) =>
                    context.read<FavoritesCubit>().remove(place.id),
                child: PlaceListTile(
                  place: place,
                  onTap: () => showPlaceDetailsSheet(context, place),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'No favorites yet.\nTap the heart on a place to save it.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
