import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/places_bloc.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/places_body.dart';
import '../widgets/places_search_field.dart';

class PlacesMapPage extends StatelessWidget {
  const PlacesMapPage({super.key});

  /// TODO(phase-7): replace with the device location from geolocator. Until then
  /// this is the Android emulator's default position (Googleplex), so the demo
  /// shows real Geoapify data.
  static final LatLng _fallbackLocation = LatLng(37.4220, -122.0841);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlacesBloc>()
        ..add(PlacesEvent.locationChanged(_fallbackLocation)),
      child: Scaffold(
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
        body: const Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: PlacesSearchField(),
            ),
            CategoryFilterBar(),
            SizedBox(height: 8),
            Expanded(child: PlacesBody()),
          ],
        ),
      ),
    );
  }
}
