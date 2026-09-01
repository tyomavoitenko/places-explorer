import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/notes/presentation/cubit/notes_cubit.dart';

class PlacesExplorerApp extends StatelessWidget {
  const PlacesExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Favourites and notes are global (map card, details sheet, favorites page),
    // so their cubits are provided above the router.
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>.value(value: getIt<FavoritesCubit>()),
        BlocProvider<NotesCubit>.value(value: getIt<NotesCubit>()),
      ],
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
