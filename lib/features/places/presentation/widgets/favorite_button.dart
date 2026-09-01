import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/place.dart';

/// Heart toggle backed by [FavoritesCubit]. Rebuilds only when this place's
/// favourite status changes (`context.select`).
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.place, super.key});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.contains(place.id),
    );

    return IconButton(
      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
      color: isFavorite ? Theme.of(context).colorScheme.primary : null,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      onPressed: () => context.read<FavoritesCubit>().toggle(place),
    );
  }
}
