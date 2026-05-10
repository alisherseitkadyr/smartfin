class OnboardingDraft {
  final String? preferredLanguage;
  final String? financialLiteracyLevel;
  final String? practicalExperience;
  final String? learningGoal;
  final String? timeCommitment;
  final List<String> preferredTopics;

  const OnboardingDraft({
    this.preferredLanguage,
    this.financialLiteracyLevel,
    this.practicalExperience,
    this.learningGoal,
    this.timeCommitment,
    this.preferredTopics = const [],
  });

  bool get isReady =>
      preferredLanguage != null &&
      financialLiteracyLevel != null &&
      practicalExperience != null &&
      learningGoal != null &&
      timeCommitment != null &&
      preferredTopics.isNotEmpty;

  OnboardingDraft copyWith({
    String? preferredLanguage,
    String? financialLiteracyLevel,
    String? practicalExperience,
    String? learningGoal,
    String? timeCommitment,
    List<String>? preferredTopics,
  }) =>
      OnboardingDraft(
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        financialLiteracyLevel:
            financialLiteracyLevel ?? this.financialLiteracyLevel,
        practicalExperience: practicalExperience ?? this.practicalExperience,
        learningGoal: learningGoal ?? this.learningGoal,
        timeCommitment: timeCommitment ?? this.timeCommitment,
        preferredTopics: preferredTopics ?? this.preferredTopics,
      );
}
