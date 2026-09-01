import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/place_category.dart';
import '../bloc/places_bloc.dart';
import 'place_category_ui.dart';

/// Horizontal row of category chips: "All" + one per [PlaceCategory.selectable].
/// Selecting a chip triggers a server-side re-fetch via [PlacesBloc].
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  static const double _height = 48;

  void _select(BuildContext context, PlaceCategory? category) =>
      context.read<PlacesBloc>().add(PlacesEvent.categorySelected(category));

  @override
  Widget build(BuildContext context) {
    final selected =
        context.select((PlacesBloc bloc) => bloc.state.selectedCategory);

    return SizedBox(
      height: _height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _CategoryChip(
            label: 'All',
            selected: selected == null,
            onSelected: () => _select(context, null),
          ),
          for (final category in PlaceCategory.selectable)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _CategoryChip(
                label: category.label,
                icon: category.icon,
                selected: selected == category,
                onSelected: () => _select(context, category),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChoiceChip(
        label: Text(label),
        avatar: icon == null ? null : Icon(icon, size: 18),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
