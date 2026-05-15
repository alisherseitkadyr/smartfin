import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/learning_session_storage.dart';

final sessionStorageProvider = Provider<LearningSessionStorage>((ref) {
  return LearningSessionStorage();
});
