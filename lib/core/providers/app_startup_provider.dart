import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/curriculum_cache.dart';
import '../storage/learning_session.dart';
import '../storage/learning_session_storage.dart';
import '../storage/subtopic_progress_storage.dart';
import '../storage/tip_cache.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(LearningSessionAdapter().typeId)) {
    Hive.registerAdapter(LearningSessionAdapter());
  }

  if (!Hive.isBoxOpen(LearningSessionStorage.boxName)) {
    await Hive.openBox<LearningSession>(LearningSessionStorage.boxName);
  }

  if (!Hive.isBoxOpen(SubtopicProgressStorage.boxName)) {
    await Hive.openBox(SubtopicProgressStorage.boxName);
  }

  if (!Hive.isBoxOpen(CurriculumCache.boxName)) {
    await Hive.openBox<dynamic>(CurriculumCache.boxName);
  }

  if (!Hive.isBoxOpen(TipCache.boxName)) {
    await Hive.openBox<dynamic>(TipCache.boxName);
  }
});
