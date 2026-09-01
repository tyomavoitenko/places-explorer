import 'package:go_router/go_router.dart';

import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/places/presentation/pages/places_map_page.dart';

/// Route path constants. Referencing these instead of string literals keeps
/// navigation call-sites refactor-safe.
abstract final class AppRoute {
  static const map = '/';
  static const favorites = '/favorites';

  /// Deep-linkable place details. Primary details UX is a bottom sheet on the
  /// map page; this route exists for deep links and is added in the details phase.
  static const placeDetails = '/place/:id';
}

abstract final class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: AppRoute.map,
      routes: [
        GoRoute(
          path: AppRoute.map,
          name: 'map',
          builder: (context, state) => const PlacesMapPage(),
        ),
        GoRoute(
          path: AppRoute.favorites,
          name: 'favorites',
          builder: (context, state) => const FavoritesPage(),
        ),
      ],
    );
  }
}
