import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/place.dart';
import 'place_category_ui.dart';

class PlaceListTile extends StatelessWidget {
  const PlaceListTile({required this.place, this.onTap, super.key});

  final Place place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final distance = formatDistance(place.distanceMeters);

    return ListTile(
      leading: CircleAvatar(child: Icon(place.category.icon)),
      title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: place.address == null
          ? null
          : Text(
              place.address!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: distance == null ? null : Text(distance),
      onTap: onTap,
    );
  }
}
