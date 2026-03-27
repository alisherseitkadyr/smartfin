import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/explore_local_datasource.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../../domain/usecases/explore_usecases.dart';
import '../../domain/entities/category.dart';
// ── Datasource ────────────────────────────────────────────────
final exploreLocalDataSourceProvider = Provider<ExploreLocalDataSource>(
  (_) => ExploreLocalDataSourceImpl(),
);

// ── Repository ────────────────────────────────────────────────
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepositoryImpl(ref.watch(exploreLocalDataSourceProvider));
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
final exploreTopicsProvider = FutureProvider<List<TopicWithStatus>>((ref) async {
  final filter = ref.watch(exploreFilterProvider);
  final search = ref.watch(searchTopicsProvider);
  return search(query: filter.query, level: filter.level);
});

// ── Grouped by level ──────────────────────────────────────────
final groupedTopicsProvider = Provider<Map<TopicLevel, List<TopicWithStatus>>>((ref) {
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


final getCategoriesWithTopicsProvider = Provider<GetCategoriesWithTopics>((ref) {
  return GetCategoriesWithTopics(ref.watch(exploreRepositoryProvider));
});

final exploreCategoriesProvider = FutureProvider<List<CategoryWithTopics>>((ref) {
  return ref.watch(getCategoriesWithTopicsProvider)();
});