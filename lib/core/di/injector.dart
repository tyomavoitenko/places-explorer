import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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

  // Feature dependencies (Dio, API service, repositories, BLoCs) are registered
  // in their own phases to keep this file readable.
}
