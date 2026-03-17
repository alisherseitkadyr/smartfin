// smartfin/lib/features/home/presentation/providers/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/home_local_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/home_usecases.dart';

// ── Datasource ────────────────────────────────────────────────
final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>(
  (_) => HomeLocalDataSourceImpl(),
);

// ── Repository ────────────────────────────────────────────────
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(homeLocalDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────────
final getHomeDataProvider = Provider<GetHomeData>((ref) {
  return GetHomeData(ref.watch(homeRepositoryProvider));
});

// ── Async home data ───────────────────────────────────────────
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final useCase = ref.watch(getHomeDataProvider);
  return useCase();
});