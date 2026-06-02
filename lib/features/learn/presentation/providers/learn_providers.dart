import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/api_client.dart';
import '../../data/datasources/learn_remote_datasource.dart';
import '../../data/repositories/learn_repository_impl.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/repositories/learn_repository.dart';
import '../../domain/usecases/learn_usecases.dart';
import '../../data/datasources/learn_local_datasource.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../explore/presentation/providers/explore_providers.dart';

final learnDioProvider = Provider<Dio>((ref) {
  return ApiClient.createDio();
});

final learnRemoteDataSourceProvider = Provider<LearnRemoteDataSource>((ref) {
  final lang = ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
  return LearnRemoteDataSourceImpl(
    dio: ref.watch(learnDioProvider),
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

final getNearbyTopicsProvider = Provider<GetNearbyTopics>((ref) {
  return GetNearbyTopics(ref.watch(learnRepositoryProvider));
});

final setCurrentTopicProvider = Provider<SetCurrentTopic>((ref) {
  return SetCurrentTopic(ref.watch(learnRepositoryProvider));
});

final getAllTopicsProvider = Provider<GetAllTopics>((ref) {
  return GetAllTopics(ref.watch(learnRepositoryProvider));
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

  if (activeTopicId != null && activeSubtopicId != null) {
    final useCase = ref.watch(getLessonForSubtopicProvider);
    final lesson = await useCase(activeTopicId, activeSubtopicId);
    return lesson.withSubtopicTitle(activeSubtopicTitle);
  }
  if (activeTopicId != null) {
    final useCase = ref.watch(getLessonForTopicProvider);
    return useCase(activeTopicId);
  }
  final useCase = ref.watch(getCurrentLessonProvider);
  final lesson = await useCase();
  // Cold start: active providers are null so withSubtopicTitle was never
  // called. Look up the title from the subtopics list if we have a code.
  if (lesson.subtopicCode != null) {
    try {
      final subtopics = await ref.read(
        topicSubtopicsProvider(lesson.topic.id).future,
      );
      final sub = subtopics
          .where((s) => s.id == lesson.subtopicCode)
          .firstOrNull;
      return lesson.withSubtopicTitle(sub?.title);
    } catch (_) {}
  }
  return lesson;
});

// ── Nearby topics ─────────────────────────────────────────────
final nearbyTopicsProvider = FutureProvider<List<NearbyTopic>>((ref) async {
  final lesson = await ref.watch(currentLessonProvider.future);
  final useCase = ref.watch(getNearbyTopicsProvider);
  return useCase(lesson.topic.id);
});

final learnTopicsProvider = FutureProvider((ref) async {
  ref.watch(languageNotifierProvider);
  final useCase = ref.watch(getAllTopicsProvider);
  return useCase();
});
