import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/storage/subtopic_progress_storage.dart';
import '../../data/datasources/explore_remote_datasource.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/entities/explore_section.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';

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

// ── Subtopic progress local storage ───────────────────────────
final subtopicProgressStorageProvider = Provider<SubtopicProgressStorage>(
  (_) => SubtopicProgressStorage(),
);

// ── Repository ────────────────────────────────────────────────
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  return ExploreRepositoryImpl(
    remoteDataSource: ref.watch(exploreRemoteDataSourceProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
    subtopicStorage: ref.watch(subtopicProgressStorageProvider),
  );
});

// ── Single source of truth: all topics + local session merged ─
// Invalidating this cascades to singleTopicProvider.
final allTopicsProvider = FutureProvider<List<TopicWithStatus>>((ref) async {
  ref.watch(languageNotifierProvider);
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.getTopicsWithStatus();
});

/// All sections with nested topics and per-user progress.
/// Refreshes on language change; invalidate explicitly after quiz completion.
final exploreSectionsProvider = FutureProvider<List<ExploreSection>>((ref) async {
  ref.watch(languageNotifierProvider);
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.getSections();
});

/// Selected topic ID on the Explore page (null = nothing selected).
final selectedTopicIdProvider = StateProvider<String?>((ref) => null);

/// Topic data pre-filled from the explore list tap so TopicPreviewPage
/// can render immediately without waiting for allTopicsProvider.
final selectedTopicDataProvider = StateProvider<TopicWithStatus?>((ref) => null);

/// All subtopics for a given topic ID.
final topicSubtopicsProvider =
    FutureProvider.family<List<SubtopicItem>, String>((ref, topicId) {
  return ref.watch(exploreRepositoryProvider).getSubtopics(topicId);
});

/// Get a single topic with its current status by ID.
/// Derives from allTopicsProvider so one invalidation refreshes both views.
final singleTopicProvider = FutureProvider.family<TopicWithStatus?, String>((
  ref,
  topicId,
) async {
  final topics = await ref.watch(allTopicsProvider.future);
  return topics.where((t) => t.topic.id == topicId).firstOrNull;
});
