import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/storage/subtopic_progress_storage.dart';
import '../../data/datasources/explore_remote_datasource.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/entities/explore_section.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';

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
    subtopicStorage: ref.watch(subtopicProgressStorageProvider),
  );
});

final curriculumProvider = FutureProvider<List<ExploreSection>>((ref) async {
  ref.watch(languageNotifierProvider);
  final repo = ref.watch(exploreRepositoryProvider);
  return repo.getSections();
});

final exploreSectionsProvider = FutureProvider<List<ExploreSection>>((ref) async {
  return ref.watch(curriculumProvider.future);
});

/// Selected topic ID on the Explore page (null = nothing selected).
final selectedTopicIdProvider = StateProvider<String?>((ref) => null);

/// Topic data pre-filled from the explore list tap so TopicPreviewPage
/// can render immediately without waiting for a network round-trip.
final selectedTopicDataProvider = StateProvider<TopicWithStatus?>((ref) => null);

/// All subtopics for a given topic ID.
final topicSubtopicsProvider =
    FutureProvider.family<List<SubtopicItem>, String>((ref, topicId) {
  return ref.watch(exploreRepositoryProvider).getSubtopics(topicId);
});

/// Single topic with current progress status.
/// Derives from curriculumProvider (zero network on hot path).
final singleTopicProvider = FutureProvider.family<TopicWithStatus?, String>((
  ref,
  topicId,
) async {
  final sections = await ref.watch(curriculumProvider.future);
  for (final section in sections) {
    final match = section.topics.where((t) => t.topic.id == topicId).firstOrNull;
    if (match != null) return match;
  }
  return null;
});
