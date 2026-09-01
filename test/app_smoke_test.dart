import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/app.dart';
import 'package:places_explorer/core/di/injector.dart';

void main() {
  setUp(configureDependencies);
  tearDown(getIt.reset);

  testWidgets('app boots to the map page', (tester) async {
    await tester.pumpWidget(const PlacesExplorerApp());

    expect(find.text('Places Explorer'), findsOneWidget);
    expect(find.text('Map goes here'), findsOneWidget);
  });
}
