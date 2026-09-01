import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';

class PlacesExplorerApp extends StatelessWidget {
  const PlacesExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Places Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: getIt<GoRouter>(),
    );
  }
}
