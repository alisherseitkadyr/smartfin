import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../explore/presentation/providers/explore_providers.dart';
import '../../data/datasources/learn_local_datasource.dart';
import '../../data/repositories/learn_repository_impl.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/repositories/learn_repository.dart';
import '../../domain/usecases/learn_usecases.dart';

// ── Datasource ────────────────────────────────────────────────
final learnLocalDataSourceProvider = Provider<LearnLocalDataSource>(
  (_) => LearnLocalDataSourceImpl(),
);

// ── Repository ────────────────────────────────────────────────
final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return LearnRepositoryImpl(
    learnDataSource: ref.watch(learnLocalDataSourceProvider),
    exploreDataSource: ref.watch(exploreLocalDataSourceProvider),
  );
});

// ── Use cases ─────────────────────────────────────────────────
final getCurrentLessonProvider = Provider<GetCurrentLesson>((ref) {
  return GetCurrentLesson(ref.watch(learnRepositoryProvider));
});

final getLessonForTopicProvider = Provider<GetLessonForTopic>((ref) {
  return GetLessonForTopic(ref.watch(learnRepositoryProvider));
});

final getNearbyTopicsProvider = Provider<GetNearbyTopics>((ref) {
  return GetNearbyTopics(ref.watch(learnRepositoryProvider));
});

final setCurrentTopicProvider = Provider<SetCurrentTopic>((ref) {
  return SetCurrentTopic(ref.watch(learnRepositoryProvider));
});

// ── Active topic state ────────────────────────────────────────
// Holds the currently previewed topic id on the Learn screen.
// null means "use the default current topic".
final activeLearnTopicIdProvider = StateProvider<String?>((ref) => null);

// ── Current lesson async ──────────────────────────────────────
final currentLessonProvider = FutureProvider<LessonTopic>((ref) async {
  final activeId = ref.watch(activeLearnTopicIdProvider);
  if (activeId != null) {
    final useCase = ref.watch(getLessonForTopicProvider);
    return useCase(activeId);
  }
  final useCase = ref.watch(getCurrentLessonProvider);
  return useCase();
});

// ── Nearby topics ─────────────────────────────────────────────
final nearbyTopicsProvider = FutureProvider<List<NearbyTopic>>((ref) async {
  final lesson = await ref.watch(currentLessonProvider.future);
  final useCase = ref.watch(getNearbyTopicsProvider);
  return useCase(lesson.topic.id);
});