import 'package:flutter/material.dart';

/// Read-only 1–5 star display.
class RatingStars extends StatelessWidget {
  const RatingStars({required this.rating, this.size = 18, super.key});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star : Icons.star_border,
            size: size,
            color: color,
          ),
      ],
    );
  }
}

/// Tappable 1–5 star input. Tapping the current value clears it (`null`).
class RatingInput extends StatelessWidget {
  const RatingInput({required this.value, required this.onChanged, super.key});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = value ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(i <= current ? Icons.star : Icons.star_border),
            onPressed: () => onChanged(value == i ? null : i),
          ),
      ],
    );
  }
}
