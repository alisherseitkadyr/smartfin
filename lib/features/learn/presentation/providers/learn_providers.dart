import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../data/datasources/learn_remote_datasource.dart';
import '../../data/repositories/learn_repository_impl.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/repositories/learn_repository.dart';
import '../../domain/usecases/learn_usecases.dart';
import '../../data/datasources/learn_local_datasource.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../../../explore/presentation/providers/explore_providers.dart';

final learnRemoteDataSourceProvider = Provider<LearnRemoteDataSource>((ref) {
  final lang = ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
  return LearnRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    languageCode: lang,
  );
});

final learnLocalDataSourceProvider = Provider<LearnLocalDataSource>((ref) {
  final storage = ref.watch(sessionStorageProvider);
  return LearnLocalDataSourceImpl(storage);
});

// ── Repository ────────────────────────────────────────────────
final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return LearnRepositoryImpl(
    remoteDataSource: ref.watch(learnRemoteDataSourceProvider),
    localDataSource: ref.watch(learnLocalDataSourceProvider),
  );
});

// ── Use cases ─────────────────────────────────────────────────
final getCurrentLessonProvider = Provider<GetCurrentLesson>((ref) {
  return GetCurrentLesson(ref.watch(learnRepositoryProvider));
});

final getLessonForTopicProvider = Provider<GetLessonForTopic>((ref) {
  return GetLessonForTopic(ref.watch(learnRepositoryProvider));
});

final getLessonForSubtopicProvider = Provider<GetLessonForSubtopic>((ref) {
  return GetLessonForSubtopic(ref.watch(learnRepositoryProvider));
});

final setCurrentTopicProvider = Provider<SetCurrentTopic>((ref) {
  return SetCurrentTopic(ref.watch(learnRepositoryProvider));
});

// ── Active topic / subtopic state ─────────────────────────────
final activeLearnTopicIdProvider = StateProvider<String?>((ref) => null);
final activeLearnSubtopicIdProvider = StateProvider<String?>((ref) => null);
final activeLearnSubtopicTitleProvider = StateProvider<String?>((ref) => null);

// ── Current lesson async ──────────────────────────────────────
final currentLessonProvider = FutureProvider<LessonTopic>((ref) async {
  ref.watch(languageNotifierProvider);
  final activeTopicId = ref.watch(activeLearnTopicIdProvider);
  final activeSubtopicId = ref.watch(activeLearnSubtopicIdProvider);
  final activeSubtopicTitle = ref.watch(activeLearnSubtopicTitleProvider);
  final repo = ref.watch(learnRepositoryProvider);

  Future<LessonTopic> lessonFromCurriculum(String topicId, {String? subtopicId}) async {
    final status = await ref.watch(singleTopicProvider(topicId).future);
    if (status != null) {
      return repo.getLessonGivenStatus(status, topicId, subtopicId: subtopicId);
    }
    if (subtopicId != null) {
      return ref.watch(getLessonForSubtopicProvider)(topicId, subtopicId);
    }
    return ref.watch(getLessonForTopicProvider)(topicId);
  }

  LessonTopic offlinePreview(TopicWithStatus status, {String? subtopicCode, String? subtopicTitle}) {
    return LessonTopic(
      topic: status.topic,
      steps: const [],
      completedSteps: 0,
      status: status.status,
      subtopicCode: subtopicCode?.isNotEmpty == true ? subtopicCode : null,
      subtopicTitle: subtopicTitle,
    );
  }

  if (activeTopicId != null && activeSubtopicId != null) {
    final lesson = await lessonFromCurriculum(activeTopicId, subtopicId: activeSubtopicId);
    return lesson.withSubtopicTitle(activeSubtopicTitle);
  }
  if (activeTopicId != null) {
    return lessonFromCurriculum(activeTopicId);
  }

  final session = repo.getCurrentSession();
  if (session != null) {
    if (session.subtopicCode.isNotEmpty) {
      try {
        final lesson = await lessonFromCurriculum(session.topicId, subtopicId: session.subtopicCode);
        return lesson.subtopicTitle != null
            ? lesson
            : lesson.withSubtopicTitle(session.subtopicTitle);
      } on DioException {
        final status = await ref.watch(singleTopicProvider(session.topicId).future);
        if (status != null) {
          return offlinePreview(status,
              subtopicCode: session.subtopicCode, subtopicTitle: session.subtopicTitle);
        }
      } catch (_) {}
    }
    try {
      return await lessonFromCurriculum(session.topicId);
    } on DioException {
      final status = await ref.watch(singleTopicProvider(session.topicId).future);
      if (status != null) return offlinePreview(status);
    } catch (_) {
      await repo.clearSession();
    }
  }

  final sections = await ref.watch(curriculumProvider.future);
  final flat = sections.expand((s) => s.topics).toList();
  if (flat.isEmpty) throw Exception('No topics available');
  final first = flat.firstWhere((t) => !t.isCompleted, orElse: () => flat.last);
  try {
    return repo.getLessonGivenStatus(first, first.topic.id);
  } on DioException {
    return offlinePreview(first);
  }
});

// ── Nearby topics — pure computation over curriculum skeleton ─
// Zero network: derives ordering from curriculumProvider (already cached).
final nearbyTopicsProvider = FutureProvider<List<NearbyTopic>>((ref) async {
  final lesson = await ref.watch(currentLessonProvider.future);
  final sections = await ref.watch(curriculumProvider.future);
  final currentId = lesson.topic.id;
  final seen = <String>{};
  final result = <NearbyTopic>[];
  for (final section in sections) {
    for (final topic in section.topics) {
      if (topic.topic.id == currentId || !seen.add(topic.topic.id)) continue;
      result.add(NearbyTopic(topic: topic.topic, status: topic.status));
      if (result.length >= 5) return result;
    }
  }
  return result;
});

// ── Up next: next subtopic in current topic, or next topic ────
final upNextProvider = FutureProvider<UpNextItem?>((ref) async {
  final lesson = await ref.watch(currentLessonProvider.future);
  final topicId = lesson.topic.id;
  final currentSubtopicCode = lesson.subtopicCode;

  final subtopics = await ref.watch(learnRemoteDataSourceProvider).getSubtopics(topicId);

  if (subtopics.isNotEmpty) {
    final sorted = [...subtopics]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final topicStatus = await ref.watch(singleTopicProvider(topicId).future);
    final completedIds = topicStatus?.completedSubtopicIds ?? {};

    int currentIndex = -1;
    if (currentSubtopicCode != null) {
      currentIndex = sorted.indexWhere((s) => s.id == currentSubtopicCode);
    }

    final nextIndex = currentIndex + 1;
    if (nextIndex < sorted.length) {
      final next = sorted[nextIndex];
      final isCompleted = completedIds.contains(next.id);
      // Locked if previous subtopic (current one) is not yet completed.
      // Mirrors locking rule in topic_preview_curriculum.dart.
      final isLocked = nextIndex > 0 &&
          currentSubtopicCode != null &&
          !completedIds.contains(currentSubtopicCode);
      return UpNextSubtopic(
        subtopic: next,
        topicId: topicId,
        isCompleted: isCompleted,
        isLocked: isLocked,
      );
    }
  }

  // Fall back to the first available nearby topic.
  final nearby = await ref.watch(nearbyTopicsProvider.future);
  if (nearby.isNotEmpty) return UpNextNextTopic(nearbyTopic: nearby.first);
  return null;
});

