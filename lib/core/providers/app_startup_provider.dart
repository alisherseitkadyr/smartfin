import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/learning_session.dart';
import '../storage/learning_session_storage.dart';
import '../storage/subtopic_progress_storage.dart';

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
});
