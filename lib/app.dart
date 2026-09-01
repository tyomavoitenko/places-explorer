import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';

class PlacesExplorerApp extends StatelessWidget {
  const PlacesExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Favourites are global (visible on the map, the details sheet and the
    // favorites page), so the cubit is provided above the router.
    return BlocProvider<FavoritesCubit>.value(
      value: getIt<FavoritesCubit>(),
      child: MaterialApp.router(
        title: 'Places Explorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
