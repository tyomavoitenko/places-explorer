import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/location/location_service.dart';
import '../bloc/places_bloc.dart';
import 'place_marker.dart';

/// OpenStreetMap tiles + a marker per visible place. Recentres when the BLoC's
/// location changes; tapping empty map clears the selection.
class PlacesMap extends StatefulWidget {
  const PlacesMap({super.key});

  static const double _zoom = 15;

  @override
  State<PlacesMap> createState() => _PlacesMapState();
}

class _PlacesMapState extends State<PlacesMap> {
  final MapController _controller = MapController();

  void _clearSelection() =>
      context.read<PlacesBloc>().add(const PlacesEvent.placeSelected(null));

  void _select(String id) =>
      context.read<PlacesBloc>().add(PlacesEvent.placeSelected(id));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlacesBloc, PlacesState>(
      listenWhen: (prev, curr) => prev.location != curr.location,
      listener: (context, state) {
        final location = state.location;
        if (location != null) _controller.move(location, PlacesMap._zoom);
      },
      builder: (context, state) {
        return FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: state.location ?? kFallbackLocation,
            initialZoom: PlacesMap._zoom,
            onTap: (_, _) => _clearSelection(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tyomavoitenko.places_explorer',
            ),
            MarkerLayer(
              markers: [
                for (final place in state.visiblePlaces)
                  Marker(
                    key: ValueKey(place.id),
                    point: LatLng(place.latitude, place.longitude),
                    width: PlaceMarker.size,
                    height: PlaceMarker.size,
                    child: PlaceMarker(
                      place: place,
                      selected: place.id == state.selectedPlaceId,
                      onTap: () => _select(place.id),
                    ),
                  ),
              ],
            ),
            // Geoapify's free plan and OSM both require visible attribution.
            const SimpleAttributionWidget(
              source: Text('© OpenStreetMap contributors · Geoapify'),
              alignment: Alignment.bottomLeft,
            ),
          ],
        );
      },
    );
  }
}
