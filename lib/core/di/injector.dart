import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../config/app_env.dart';
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

  // API services, repositories and BLoCs are registered in their own phases
  // to keep this file readable.
}
