// smartfin/lib/features/home/presentation/providers/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/storage/tip_cache.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/datasources/home_tip_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/repositories/home_tip_repository_impl.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/entities/home_tip.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/repositories/home_tip_repository.dart';
import '../../domain/usecases/home_usecases.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final lang = ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
  return HomeRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    languageCode: lang,
  );
});

// ── Repository ────────────────────────────────────────────────
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    remoteDataSource: ref.watch(homeRemoteDataSourceProvider),
  );
});

// ── Use cases ─────────────────────────────────────────────────
final getHomeDataProvider = Provider<GetHomeData>((ref) {
  return GetHomeData(ref.watch(homeRepositoryProvider));
});

// ── Async home data ───────────────────────────────────────────
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  ref.watch(languageNotifierProvider); // re-fetch when language changes
  final useCase = ref.watch(getHomeDataProvider);
  return useCase();
});

// ── Tip data source ───────────────────────────────────────────
final homeTipDataSourceProvider = Provider<HomeTipDataSource>((ref) {
  return HomeTipDataSourceImpl(
    dio: ref.watch(dioProvider),
    cache: TipCache(),
  );
});

// ── Tip repository ────────────────────────────────────────────
final homeTipRepositoryProvider = Provider<HomeTipRepository>((ref) {
  return HomeTipRepositoryImpl(ref.watch(homeTipDataSourceProvider));
});

// ── Tip: autoDispose so invalidate() triggers a fresh random fetch
final homeTipProvider = FutureProvider.autoDispose<HomeTip>((ref) async {
  final lang = ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
  return ref.watch(homeTipRepositoryProvider).getTip(lang);
});
