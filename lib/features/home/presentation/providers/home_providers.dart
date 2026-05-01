// smartfin/lib/features/home/presentation/providers/home_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/home_usecases.dart';

// ── HTTP Client ───────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  return ApiClient.createDio();
});

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSourceImpl(dio: ref.watch(dioProvider));
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
  final useCase = ref.watch(getHomeDataProvider);
  return useCase();
});
