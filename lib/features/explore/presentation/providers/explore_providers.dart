import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../data/datasources/explore_remote_datasource.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../../domain/usecases/explore_usecases.dart';
import '../../domain/entities/category.dart';

// ── HTTP Client ───────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  return ApiClient.createDio();
});

final exploreRemoteDataSourceProvider = Provider<ExploreRemoteDataSource>((
  ref,
) {
  return ExploreRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// ── Repository ────────────────────────────────────────────────
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepositoryImpl(
    remoteDataSource: ref.watch(exploreRemoteDataSourceProvider),
  );
});

// ── Use cases ─────────────────────────────────────────────────
final getTopicsWithStatusProvider = Provider<GetTopicsWithStatus>((ref) {
  return GetTopicsWithStatus(ref.watch(exploreRepositoryProvider));
});

final searchTopicsProvider = Provider<SearchTopics>((ref) {
  return SearchTopics(ref.watch(exploreRepositoryProvider));
});

// ── Filter state ─────────────────────────────────────────────
class ExploreFilter {
  final String query;
  final TopicLevel? level;

  const ExploreFilter({this.query = '', this.level});

  ExploreFilter copyWith({String? query, Object? level = _sentinel}) {
    return ExploreFilter(
      query: query ?? this.query,
      level: level == _sentinel ? this.level : level as TopicLevel?,
    );
  }
}

const _sentinel = Object();

final exploreFilterProvider = StateProvider<ExploreFilter>(
  (_) => const ExploreFilter(),
);

// ── Async topics list ─────────────────────────────────────────
final exploreTopicsProvider = FutureProvider<List<TopicWithStatus>>((
  ref,
) async {
  final filter = ref.watch(exploreFilterProvider);
  final search = ref.watch(searchTopicsProvider);
  try {
    return await search(query: filter.query, level: filter.level);
  } catch (e, st) {
    // Log error and return empty list so the UI shows content instead of error.
    // The repository already prints API errors; include stacktrace for debugging.
    // ignore: avoid_print
    print('Explore topics load failed: $e');
    // ignore: avoid_print
    print(st);
    return <TopicWithStatus>[];
  }
});

// ── Grouped by level ──────────────────────────────────────────
final groupedTopicsProvider = Provider<Map<TopicLevel, List<TopicWithStatus>>>((
  ref,
) {
  final asyncTopics = ref.watch(exploreTopicsProvider);
  return asyncTopics.when(
    data: (topics) {
      final Map<TopicLevel, List<TopicWithStatus>> grouped = {};
      for (final level in TopicLevel.values) {
        final group = topics.where((t) => t.topic.level == level).toList();
        if (group.isNotEmpty) grouped[level] = group;
      }
      return grouped;
    },
    loading: () => <TopicLevel, List<TopicWithStatus>>{},
    error: (_, __) => <TopicLevel, List<TopicWithStatus>>{},
  );
});

final getCategoriesWithTopicsProvider = Provider<GetCategoriesWithTopics>((
  ref,
) {
  return GetCategoriesWithTopics(ref.watch(exploreRepositoryProvider));
});

final exploreCategoriesProvider = FutureProvider<List<CategoryWithTopics>>((
  ref,
) {
  return ref.watch(getCategoriesWithTopicsProvider)();
});

/// Get a single topic with its current status by ID.
final singleTopicProvider = FutureProvider.family<TopicWithStatus?, String>((
  ref,
  topicId,
) async {
  final topics = await ref.watch(exploreTopicsProvider.future);
  return topics.where((t) => t.topic.id == topicId).firstOrNull;
});
