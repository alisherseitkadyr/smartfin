import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../data/datasources/onboarding_datasource.dart';
import '../../domain/entities/onboarding_draft.dart';

final _onboardingDioProvider = Provider<Dio>(
  (_) => ApiClient.createDio(),
);

final onboardingDataSourceProvider = Provider<OnboardingDataSource>((ref) {
  return OnboardingDataSourceImpl(dio: ref.watch(_onboardingDioProvider));
});

// Fetches profile to determine if user has completed onboarding.
// autoDispose so it re-fetches on every use (not cached across navigations).
final onboardingStatusProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(onboardingDataSourceProvider).isOnboardingComplete();
});

// In-progress draft for the onboarding wizard.
final onboardingDraftProvider =
    StateNotifierProvider<OnboardingDraftNotifier, OnboardingDraft>(
  (_) => OnboardingDraftNotifier(),
);

class OnboardingDraftNotifier extends StateNotifier<OnboardingDraft> {
  OnboardingDraftNotifier() : super(const OnboardingDraft());

  void setLanguage(String v) => state = state.copyWith(preferredLanguage: v);
  void setLevel(String v) => state = state.copyWith(financialLiteracyLevel: v);
  void setExperience(String v) => state = state.copyWith(practicalExperience: v);
  void setGoal(String v) => state = state.copyWith(learningGoal: v);
  void setTimeCommitment(String v) => state = state.copyWith(timeCommitment: v);

  void toggleTopic(String topic) {
    final topics = List<String>.from(state.preferredTopics);
    if (topics.contains(topic)) {
      topics.remove(topic);
    } else {
      topics.add(topic);
    }
    state = state.copyWith(preferredTopics: topics);
  }

  void reset() => state = const OnboardingDraft();
}

// Manages the async submit call.
class OnboardingSubmitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit(OnboardingDraft draft) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() {
      return ref.read(onboardingDataSourceProvider).submitOnboarding(
            financialLiteracyLevel: draft.financialLiteracyLevel!,
            practicalExperience: draft.practicalExperience!,
            learningGoal: draft.learningGoal!,
            preferredLanguage: draft.preferredLanguage!,
            timeCommitment: draft.timeCommitment!,
            preferredTopics: draft.preferredTopics,
          );
    });
    state = result;
    return !result.hasError;
  }
}

final onboardingSubmitProvider =
    AsyncNotifierProvider<OnboardingSubmitNotifier, void>(
  OnboardingSubmitNotifier.new,
);
