/// The handful of place categories the app understands.
///
/// Pure domain: an `apiValue` (what Geoapify calls it) and a `label` (what the
/// user sees). No `IconData` here — icons/colours live in a presentation-side
/// extension so the domain layer never imports Flutter.
enum PlaceCategory {
  restaurant('catering.restaurant', 'Restaurants'),
  cafe('catering.cafe', 'Cafés'),
  supermarket('commercial.supermarket', 'Supermarkets'),
  sight('tourism.sights', 'Sights'),
  park('leisure.park', 'Parks'),

  /// Fallback for a POI that doesn't match any bucket above.
  other('', 'Places');

  const PlaceCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// Categories the user can filter by (everything except [other]).
  static List<PlaceCategory> get selectable =>
      values.where((c) => c != PlaceCategory.other).toList();

  /// Classifies a POI from Geoapify's nested `categories` array by prefix match,
  /// e.g. `['catering', 'catering.cafe', 'catering.cafe.coffee']` -> [cafe].
  /// First bucket (in declaration order) that matches wins.
  static PlaceCategory fromApiValues(List<String> apiCategories) {
    for (final category in selectable) {
      final matched = apiCategories.any(
        (c) => c == category.apiValue || c.startsWith('${category.apiValue}.'),
      );
      if (matched) return category;
    }
    return PlaceCategory.other;
  }
}
