import 'package:flutter/material.dart';

import '../../domain/entities/place_category.dart';

/// Presentation-only metadata for [PlaceCategory]. Kept out of the domain enum
/// so the domain layer never imports Flutter.
extension PlaceCategoryUi on PlaceCategory {
  IconData get icon => switch (this) {
        PlaceCategory.restaurant => Icons.restaurant,
        PlaceCategory.cafe => Icons.local_cafe,
        PlaceCategory.supermarket => Icons.local_grocery_store,
        PlaceCategory.sight => Icons.attractions,
        PlaceCategory.park => Icons.park,
        PlaceCategory.other => Icons.place,
      };
}
