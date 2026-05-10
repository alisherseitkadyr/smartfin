import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/language_provider.dart';
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
  final lang = ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
  return ExploreRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    languageCode: lang,
  );
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
  ref.watch(languageNotifierProvider); // re-fetch when language changes
  final filter = ref.watch(exploreFilterProvider);
  final search = ref.watch(searchTopicsProvider);
  return search(query: filter.query, level: filter.level);
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

// Derived synchronously from exploreTopicsProvider — no extra API calls.
// Groups all topics into a single synthetic category per topic ID.
final exploreCategoriesProvider = Provider<List<CategoryWithTopics>>((ref) {
  final topics = ref.watch(exploreTopicsProvider).valueOrNull ?? [];
  return topics
      .map((t) => CategoryWithTopics(
            category: Category(
              id: t.topic.id,
              title: t.topic.title,
              description: t.topic.description,
              icon: t.topic.icon,
              color: CategoryColor.green,
              topicIds: [t.topic.id],
            ),
            topics: [t],
          ))
      .toList();
});

// All topics with no filter applied — used for single-topic lookups so the
// result is never affected by whatever the user has typed in the search bar.
final _allTopicsProvider = FutureProvider<List<TopicWithStatus>>((ref) async {
  ref.watch(languageNotifierProvider);
  final search = ref.watch(searchTopicsProvider);
  return search(query: '', level: null);
});

/// Selected topic ID on the Explore page (null = nothing selected).
final selectedTopicIdProvider = StateProvider<String?>((ref) => null);

/// All subtopics for a given topic ID.
final topicSubtopicsProvider =
    FutureProvider.family<List<SubtopicItem>, String>((ref, topicId) {
  return ref.watch(exploreRepositoryProvider).getSubtopics(topicId);
});

/// Get a single topic with its current status by ID.
final singleTopicProvider = FutureProvider.family<TopicWithStatus?, String>((
  ref,
  topicId,
) async {
  final topics = await ref.watch(_allTopicsProvider.future);
  return topics.where((t) => t.topic.id == topicId).firstOrNull;
});
