import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/places_bloc.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/places_body.dart';
import '../widgets/places_list_sheet.dart';
import '../widgets/places_search_field.dart';

class PlacesMapPage extends StatelessWidget {
  const PlacesMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlacesBloc>()..add(const PlacesEvent.started()),
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
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            tooltip: 'Show list',
            onPressed: () => PlacesListSheet.show(context),
            child: const Icon(Icons.format_list_bulleted),
          ),
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
