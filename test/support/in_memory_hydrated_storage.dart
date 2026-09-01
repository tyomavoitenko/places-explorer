import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Minimal in-memory [Storage] so `HydratedCubit`s work in tests (and a
/// persistence round-trip can be asserted).
class InMemoryHydratedStorage implements Storage {
  final Map<String, dynamic> _box = {};

  @override
  dynamic read(String key) => _box[key];

  @override
  Future<void> write(String key, dynamic value) async => _box[key] = value;

  @override
  Future<void> delete(String key) async => _box.remove(key);

  @override
  Future<void> clear() async => _box.clear();

  @override
  Future<void> close() async {}
}

/// Installs a fresh in-memory HydratedBloc storage around each test in scope.
/// Returns the storage so tests can inspect what was persisted.
InMemoryHydratedStorage useInMemoryHydratedStorage() {
  final storage = InMemoryHydratedStorage();
  setUp(() => HydratedBloc.storage = storage);
  tearDown(() async {
    await storage.clear();
    HydratedBloc.storage = null;
  });
  return storage;
}
