import 'package:flutter/material.dart';

import '../../domain/entities/place.dart';
import 'place_category_ui.dart';

/// The pin drawn on the map for a place. Grows and switches to the primary
/// colour when selected.
class PlaceMarker extends StatelessWidget {
  const PlaceMarker({
    required this.place,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Place place;
  final bool selected;
  final VoidCallback onTap;

  static const double size = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: selected ? size : size * 0.8,
        height: selected ? size : size * 0.8,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.primary, width: 2),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Icon(
          place.category.icon,
          size: selected ? 20 : 16,
          color: selected ? scheme.onPrimary : scheme.primary,
        ),
      ),
    );
  }
}
