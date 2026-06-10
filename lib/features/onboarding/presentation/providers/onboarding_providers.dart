import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/safe_storage.dart';
import '../../data/datasources/onboarding_datasource.dart';
import '../../domain/entities/onboarding_draft.dart';

final _onboardingStorageProvider = Provider<SafeStorage>(
  (_) => const SafeStorage(),
);

final _onboardingDioProvider = Provider<Dio>(
  (ref) => ApiClient.createDio(storage: ref.watch(_onboardingStorageProvider)),
);

final onboardingDataSourceProvider = Provider<OnboardingDataSource>((ref) {
  return OnboardingDataSourceImpl(
    dio: ref.watch(_onboardingDioProvider),
    storage: ref.watch(_onboardingStorageProvider),
  );
});

// autoDispose so it re-fetches on every use (not cached across navigations).
final onboardingStatusProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(onboardingDataSourceProvider).isOnboardingComplete();
});

// In-progress draft held in memory during the wizard.
final onboardingDraftProvider =
    StateNotifierProvider<OnboardingDraftNotifier, OnboardingDraft>(
  (_) => OnboardingDraftNotifier(),
);

class OnboardingDraftNotifier extends StateNotifier<OnboardingDraft> {
  OnboardingDraftNotifier() : super(const OnboardingDraft());

  void toggleInterest(String interest) {
    final list = List<String>.from(state.interests);
    if (list.contains(interest)) {
      list.remove(interest);
    } else {
      list.add(interest);
    }
    state = state.copyWith(interests: list);
  }

  void setQ1(String v) => state = state.copyWith(q1: v);
  void setQ2(String v) => state = state.copyWith(q2: v);
  void setQ3(String v) => state = state.copyWith(q3: v);

  void reset() => state = const OnboardingDraft();
}

class OnboardingSubmitNotifier
    extends AsyncNotifier<StartHereRecommendation?> {
  @override
  Future<StartHereRecommendation?> build() async => null;

  Future<StartHereRecommendation?> submit(OnboardingDraft draft) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard<StartHereRecommendation?>(() {
      return ref.read(onboardingDataSourceProvider).submitOnboarding(
            interests: draft.interests,
            compoundInterest: draft.compoundInterestKnowledge!,
            inflation: draft.inflationKnowledge!,
            diversification: draft.diversificationKnowledge!,
          );
    });
    state = result;
    if (result.hasError) return null;
    return result.value;
  }
}

final onboardingSubmitProvider = AsyncNotifierProvider<OnboardingSubmitNotifier,
    StartHereRecommendation?>(
  OnboardingSubmitNotifier.new,
);
