import 'package:go_router/go_router.dart';

import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/places/domain/entities/place.dart';
import '../../features/places/presentation/pages/place_details_page.dart';
import '../../features/places/presentation/pages/places_map_page.dart';

/// Route path constants. Referencing these instead of string literals keeps
/// navigation call-sites refactor-safe.
abstract final class AppRoute {
  static const map = '/';
  static const favorites = '/favorites';
  static const placeDetails = '/place/:id';

  static String placeDetailsPath(String id) => '/place/$id';
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
        GoRoute(
          path: AppRoute.placeDetails,
          name: 'placeDetails',
          // The full [Place] is passed as `extra` for in-app navigation. On a
          // cold deep link `extra` is null and the page shows a fallback — we
          // don't have a "fetch one place by id" endpoint wired.
          builder: (context, state) => PlaceDetailsPage(
            placeId: state.pathParameters['id']!,
            place: state.extra as Place?,
          ),
        ),
      ],
    );
  }
}
