class OnboardingDraft {
  final List<String> interests;
  // Raw option keys selected by the user (unique per question).
  final String? q1; // 'more' | 'exactly' | 'less' | 'not_sure'
  final String? q2; // 'more' | 'same' | 'less' | 'not_sure'
  final String? q3; // 'safer' | 'riskier' | 'same' | 'not_sure'

  const OnboardingDraft({
    this.interests = const [],
    this.q1,
    this.q2,
    this.q3,
  });

  // Maps raw selections to the knowledge signal sent to the backend.
  String? get compoundInterestKnowledge => switch (q1) {
    'more' => 'correct',
    'exactly' || 'less' => 'wrong',
    'not_sure' => 'not_sure',
    _ => null,
  };

  String? get inflationKnowledge => switch (q2) {
    'less' => 'correct',
    'more' || 'same' => 'wrong',
    'not_sure' => 'not_sure',
    _ => null,
  };

  String? get diversificationKnowledge => switch (q3) {
    'riskier' => 'correct',
    'safer' || 'same' => 'wrong',
    'not_sure' => 'not_sure',
    _ => null,
  };

  bool get isReady =>
      interests.isNotEmpty && q1 != null && q2 != null && q3 != null;

  OnboardingDraft copyWith({
    List<String>? interests,
    String? q1,
    String? q2,
    String? q3,
  }) =>
      OnboardingDraft(
        interests: interests ?? this.interests,
        q1: q1 ?? this.q1,
        q2: q2 ?? this.q2,
        q3: q3 ?? this.q3,
      );
}

class StartHereRecommendation {
  final String topicId;
  final String topicTitle;
  final String? sectionTitle;

  const StartHereRecommendation({
    required this.topicId,
    required this.topicTitle,
    this.sectionTitle,
  });

  factory StartHereRecommendation.fromJson(Map<String, dynamic> json) =>
      StartHereRecommendation(
        topicId: json['topicId'] as String? ??
            json['topic_id'] as String? ??
            '',
        topicTitle: json['topicTitle'] as String? ??
            json['topic_title'] as String? ??
            '',
        sectionTitle: json['sectionTitle'] as String? ??
            json['section_title'] as String?,
      );
}
