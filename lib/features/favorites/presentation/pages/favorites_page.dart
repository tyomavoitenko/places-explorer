import 'package:flutter/material.dart';

/// Placeholder for the favorites list. Real HydratedCubit wiring arrives later.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('No favorites yet')),
    );
  }
}
