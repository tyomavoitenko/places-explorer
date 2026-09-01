import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// Placeholder for the main screen. Real map + BLoC wiring arrives in later phases.
class PlacesMapPage extends StatelessWidget {
  const PlacesMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favorites',
            onPressed: () => context.push(AppRoute.favorites),
          ),
        ],
      ),
      body: const Center(child: Text('Map goes here')),
    );
  }
}
