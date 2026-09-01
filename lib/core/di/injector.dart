import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/places/data/api/places_api_service.dart';
import '../../features/places/data/repositories/places_repository_impl.dart';
import '../../features/places/domain/repositories/places_repository.dart';
import '../../features/places/presentation/bloc/places_bloc.dart';
import '../config/app_env.dart';
import '../location/location_service.dart';
import '../network/dio_factory.dart';
import '../router/app_router.dart';

/// Single service-locator instance for the app.
///
/// We use plain `get_it` (no `injectable` code-gen): for a project this size the
/// generator's ceremony outweighs its benefit, and an explicit registration list
/// makes dependency lifetimes obvious to a reviewer.
final GetIt getIt = GetIt.instance;

/// Wires up every dependency. Called once from `main` before `runApp`.
///
/// Lifetime guide used throughout:
/// * `registerSingleton`        – created now, one instance forever (eager).
/// * `registerLazySingleton`    – created on first use, one instance forever.
/// * `registerFactory`          – new instance on every `getIt<T>()` call.
void configureDependencies() {
  _registerCore();
  _registerPlaces();
  _registerFavorites();
}

void _registerCore() {
  // Router holds navigation state for the whole app lifetime -> lazy singleton.
  getIt.registerLazySingleton<GoRouter>(AppRouter.create);

  // One configured HTTP client, shared by every API service. Lazy: only built
  // if the app actually makes a network call in this session.
  getIt.registerLazySingleton<Dio>(
    () => DioFactory.create(
      baseUrl: AppEnv.geoapifyBaseUrl,
      apiKey: AppEnv.geoapifyApiKey,
    ),
  );

  // Stateless wrapper over the geolocator plugin.
  getIt.registerLazySingleton<LocationService>(GeolocatorLocationService.new);
}

void _registerPlaces() {
  // Stateless HTTP wrapper -> one instance is enough.
  getIt.registerLazySingleton<PlacesApiService>(
    () => PlacesApiService(getIt<Dio>()),
  );

  // Repository is stateless too; the BLoC depends on this interface, never on
  // the implementation.
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(getIt<PlacesApiService>()),
  );

  // Factory: each map screen gets its own BLoC instance with its own lifecycle,
  // disposed with the screen. Never a singleton — that would leak state between
  // navigations.
  getIt.registerFactory<PlacesBloc>(
    () => PlacesBloc(getIt<PlacesRepository>(), getIt<LocationService>()),
  );
}

void _registerFavorites() {
  // App-wide, persisted state -> a single instance for the whole session,
  // provided above the router in `app.dart`.
  getIt.registerLazySingleton<FavoritesCubit>(FavoritesCubit.new);
}
