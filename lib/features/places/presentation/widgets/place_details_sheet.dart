import 'package:flutter/material.dart';

import '../../domain/entities/place.dart';
import 'place_details_view.dart';

/// Opens the place details as a draggable bottom sheet. This is the primary
/// details UX; the `/place/:id` route shows the same content as a full page.
Future<void> showPlaceDetailsSheet(BuildContext context, Place place) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (context, scrollController) => PlaceDetailsView(
        place: place,
        scrollController: scrollController,
      ),
    ),
  );
}
