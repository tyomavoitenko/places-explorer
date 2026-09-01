import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Backing store for every HydratedCubit (favorites, notes). Must be ready
  // before any cubit is constructed.
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  configureDependencies();
  runApp(const PlacesExplorerApp());
}
