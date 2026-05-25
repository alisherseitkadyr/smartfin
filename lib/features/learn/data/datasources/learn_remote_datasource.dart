import 'package:dio/dio.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../models/lesson_step_model.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/entities/quiz.dart';

abstract class LearnRemoteDataSource {
  Future<List<TopicWithStatus>> getTopicsWithStatus();
  Future<List<LessonStepModel>> getStepsForTopic(String topicId);

  /// Fetch lesson steps for a specific subtopic code (e.g. "basic_budgeting").
  /// Used when the user taps a specific topic in the curriculum.
  Future<List<LessonStepModel>> getStepsForSubtopic(String subtopicCode);

  Future<List<LessonOutcome>> getOutcomesForTopic(String topicId);
  Future<Map<String, int>> getTopicProgress();
  Future<QuizStartData> startQuizByTopicCode(String topicCode);

  /// Returns the first subtopic code for [topicId] if it was already fetched.
  String? firstSubtopicCode(String topicId);

  /// Start a subtopic quiz (2-3 questions). [topicCode] is used to fetch
  /// the quiz ID if it is not already cached from a previous subtopics call.
  Future<QuizStartData> startQuizBySubtopicCode(
    String subtopicCode,
    String topicCode,
  );

  Future<QuizResult> submitQuiz(
    int attemptId,
    List<QuizAnswerInput> answers,
    int durationSeconds,
  );
  Future<List<QuizAnswerResult>> getAttemptDetails(int attemptId);

  /// Mark a subtopic as read/completed on the backend.
  Future<void> completeSubtopic(String subtopicCode);
}

class LearnRemoteDataSourceImpl implements LearnRemoteDataSource {
  final Dio _dio;
  final String _languageCode;
  final Map<String, Map<String, dynamic>> _lessonCache = {};

  final Map<String, int> _finalQuizIdCache = {};
  final Map<String, int> _subtopicQuizIdCache = {};
  final Map<String, String> _topicFirstSubtopicCode = {};

  LearnRemoteDataSourceImpl({required Dio dio, required String languageCode})
    : _dio = dio,
      _languageCode = languageCode;

  @override
  String? firstSubtopicCode(String topicId) => _topicFirstSubtopicCode[topicId];

  @override
  Future<List<TopicWithStatus>> getTopicsWithStatus() async {
    final topicsResponse = await _dio.get(
      '/content/topics',
      queryParameters: {'lang': _languageCode},
    );

    if (topicsResponse.statusCode != 200) {
      throw Exception('Failed to load topics');
    }

    final learningMap = await _fetchLearningMap();
    final rawTopics = _readList(
      topicsResponse.data,
    ).whereType<Map<String, dynamic>>().toList();

    final topics = await Future.wait(
      rawTopics.map((topic) => _topicWithBackendStatus(topic, learningMap)),
    );

    return _applySequentialStatuses(topics);
  }

  Future<Map<String, dynamic>?> _fetchLessonData(String topicId) async {
    final cached = _lessonCache[topicId];
    if (cached != null) return cached;

    final subtopicsResponse = await _dio.get(
      '/content/topics/$topicId/subtopics',
      queryParameters: {'lang': _languageCode},
    );
    if (subtopicsResponse.statusCode != 200) return null;

    final rawData = subtopicsResponse.data;
    if (rawData is Map<String, dynamic>) {
      final finalQuiz = rawData['finalQuiz'] as Map<String, dynamic>?;
      final qId = (finalQuiz?['quizId'] as num?)?.toInt();
      if (qId != null) _finalQuizIdCache[topicId] = qId;
    }

    final subtopics = _readList(subtopicsResponse.data);
    if (subtopics.isEmpty) return null;

    for (final s in subtopics.whereType<Map<String, dynamic>>()) {
      final code = s['code'] as String?;
      final qId = (s['quizId'] as num?)?.toInt();
      if (code != null && qId != null) _subtopicQuizIdCache[code] = qId;
    }

    final firstSubtopic = subtopics.first as Map<String, dynamic>;
    final subtopicCode = firstSubtopic['code'] as String?;
    if (subtopicCode == null || subtopicCode.isEmpty) return null;

    _topicFirstSubtopicCode[topicId] = subtopicCode;

    final lessonResponse = await _dio.get(
      '/content/subtopics/$subtopicCode/lesson',
      queryParameters: {'lang': _languageCode},
    );
    if (lessonResponse.statusCode != 200) return null;

    final lesson = lessonResponse.data as Map<String, dynamic>?;
    if (lesson != null) _lessonCache[topicId] = lesson;
    return lesson;
  }

  @override
  Future<List<LessonStepModel>> getStepsForTopic(String topicId) async {
    final lessonData = await _fetchLessonData(topicId);
    if (lessonData == null) {
      throw Exception('Lesson not found for topic: $topicId');
    }

    final stepsList = lessonData['steps'] as List?;
    if (stepsList == null) return [];
    return stepsList
        .map((step) => LessonStepModel.fromJson(step as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LessonStepModel>> getStepsForSubtopic(
    String subtopicCode,
  ) async {
    final response = await _dio.get(
      '/content/subtopics/$subtopicCode/lesson',
      queryParameters: {'lang': _languageCode},
    );
    if (response.statusCode != 200) {
      throw Exception('Lesson not found for subtopic: $subtopicCode');
    }
    final data = response.data as Map<String, dynamic>?;
    final stepsList = data?['steps'] as List?;
    if (stepsList == null) return [];
    return stepsList
        .map((step) => LessonStepModel.fromJson(step as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LessonOutcome>> getOutcomesForTopic(String topicId) async {
    final response = await _dio.get(
      '/content/topics/$topicId/subtopics',
      queryParameters: {'lang': _languageCode},
    );
    if (response.statusCode != 200) return [];

    return _readList(response.data)
        .whereType<Map<String, dynamic>>()
        .map((subtopic) => subtopic['title'] as String? ?? '')
        .where((title) => title.isNotEmpty)
        .map((title) => LessonOutcome(text: title))
        .toList();
  }

  @override
  Future<Map<String, int>> getTopicProgress() async {
    try {
      final response = await _dio.get('/progress/me');
      if (response.statusCode == 200) {
        return _topicProgressFromOverview(response.data);
      }
    } on DioException {
      return {};
    }
    return {};
  }

  @override
  Future<QuizStartData> startQuizByTopicCode(String topicCode) async {
    int? quizId = _finalQuizIdCache[topicCode];
    if (quizId == null) {
      final subtopicsResponse = await _dio.get(
        '/content/topics/$topicCode/subtopics',
        queryParameters: {'lang': _languageCode},
      );
      final rawData = subtopicsResponse.data as Map<String, dynamic>?;
      final finalQuiz = rawData?['finalQuiz'] as Map<String, dynamic>?;
      quizId = (finalQuiz?['quizId'] as num?)?.toInt();
      if (quizId != null) _finalQuizIdCache[topicCode] = quizId;
    }
    if (quizId == null) throw Exception('No quiz found for topic: $topicCode');
    return _startQuiz(quizId);
  }

  @override
  Future<QuizStartData> startQuizBySubtopicCode(
    String subtopicCode,
    String topicCode,
  ) async {
    int? quizId = _subtopicQuizIdCache[subtopicCode];
    if (quizId == null) {
      await _fetchSubtopics(topicCode);
      quizId = _subtopicQuizIdCache[subtopicCode];
    }
    if (quizId == null) {
      throw Exception('No quiz found for subtopic: $subtopicCode');
    }
    return _startQuiz(quizId);
  }

  Future<QuizStartData> _startQuiz(int quizId) async {
    final response = await _dio.post(
      '/assessment/quizzes/$quizId/start',
      queryParameters: {'lang': _languageCode},
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw Exception('Unexpected quiz response format: $raw');
    }
    final quizData = raw['quiz'] is Map<String, dynamic>
        ? raw['quiz'] as Map<String, dynamic>
        : raw;
    final questions = _parseQuestions(quizData['questions']);
    final resolvedQuizId =
        (quizData['quiz_id'] as num?)?.toInt() ??
        (quizData['id'] as num?)?.toInt() ??
        quizId;
    return QuizStartData(
      attemptId: (raw['attempt_id'] as num).toInt(),
      quizId: resolvedQuizId,
      quizType: quizData['quiz_type'] as String? ?? '',
      title: quizData['title'] as String? ?? '',
      totalQuestions: questions.length,
      questions: questions,
    );
  }

  @override
  Future<QuizResult> submitQuiz(
    int attemptId,
    List<QuizAnswerInput> answers,
    int durationSeconds,
  ) async {
    final body = {
      'duration_seconds': durationSeconds,
      'answers': answers
          .map(
            (a) => {
              'question_id': a.questionId,
              'selected_option_ids': a.selectedOptionIds,
            },
          )
          .toList(),
    };

    final response = await _dio.post(
      '/assessment/attempts/$attemptId/submit',
      data: body,
    );

    final data = response.data as Map<String, dynamic>;
    final totalQuestions = (data['total_questions'] as num).toInt();
    final correctAnswers = (data['correct_answers'] as num).toInt();
    return QuizResult(
      attemptId: (data['attempt_id'] as num).toInt(),
      quizId: (data['quiz_id'] as num).toInt(),
      scorePercent: (data['score_percent'] as num).toInt(),
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: totalQuestions - correctAnswers,
      passed: data['passed'] as bool? ?? false,
      xpForScore:
          (data['xp_for_score'] as num? ?? data['xp_earned'] as num? ?? 0)
              .toInt(),
    );
  }

  @override
  Future<void> completeSubtopic(String subtopicCode) async {
    await _dio.post('/content/subtopics/$subtopicCode/complete');
  }

  @override
  Future<List<QuizAnswerResult>> getAttemptDetails(int attemptId) async {
    final response = await _dio.get(
      '/assessment/attempts/$attemptId',
      queryParameters: {'lang': _languageCode},
    );
    final data = response.data as Map<String, dynamic>;
    final answers = data['answers'] as List? ?? [];
    return answers.whereType<Map<String, dynamic>>().map((a) {
      final selectedIds = (a['selected_options'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((option) => (option['option_id'] as num).toInt())
          .toList();
      final correctIds = (a['correct_options'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((option) => (option['option_id'] as num).toInt())
          .toList();
      return QuizAnswerResult(
        questionId: (a['question_id'] as num).toInt(),
        isCorrect: a['is_question_correct'] as bool? ?? false,
        selectedAnswerIds: selectedIds,
        correctAnswerIds: correctIds,
      );
    }).toList();
  }

  List<QuizQuestion> _parseQuestions(dynamic raw) {
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((q) {
      // Accept both field name conventions the backend might use:
      //   spec format:  answers[].answer_text
      //   alt format:   options[].text
      final rawList = (q['answers'] as List?) ?? (q['options'] as List?) ?? [];
      final options = rawList
          .whereType<Map<String, dynamic>>()
          .map(
            (o) => QuizOption(
              id: (o['id'] as num).toInt(),
              orderIndex: (o['order_index'] as num? ?? 0).toInt(),
              text: o['answer_text'] as String? ?? o['text'] as String? ?? '',
              isCorrect:
                  o['is_correct'] as bool? ??
                  o['isCorrect'] as bool? ??
                  o['correct'] as bool?,
            ),
          )
          .toList();
      return QuizQuestion(
        id: (q['id'] as num).toInt(),
        questionType: q['question_type'] as String? ?? 'single_choice',
        orderIndex: (q['order_index'] as num? ?? 0).toInt(),
        questionText: q['question_text'] as String? ?? '',
        options: options,
      );
    }).toList();
  }

  List<dynamic> _readList(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['subtopics'] is List) return data['subtopics'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return const [];
  }

  Future<Map<String, Map<String, dynamic>>> _fetchLearningMap() async {
    try {
      final response = await _dio.get(
        '/adaptation/learning-map',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode != 200) return {};

      final topics =
          (response.data?['topics'] as List?)
              ?.whereType<Map<String, dynamic>>() ??
          const Iterable<Map<String, dynamic>>.empty();

      return {
        for (final topic in topics)
          if (topic['code'] != null) topic['code'].toString(): topic,
      };
    } on DioException {
      return {};
    }
  }

  Future<TopicWithStatus> _topicWithBackendStatus(
    Map<String, dynamic> rawTopic,
    Map<String, Map<String, dynamic>> learningMap,
  ) async {
    final topicCode = (rawTopic['code'] ?? rawTopic['id'] ?? '').toString();
    final subtopics = await _fetchSubtopics(topicCode);
    final learning = learningMap[topicCode];
    final completedSubtopics =
        (learning?['completedSubtopics'] as num?)?.toInt() ?? 0;
    final backendStatus = learning?['status']?.toString();
    final isCompleted =
        backendStatus == 'COMPLETED' ||
        (subtopics.isNotEmpty && completedSubtopics >= subtopics.length);

    return TopicWithStatus(
      topic: TopicItem(
        id: topicCode,
        title: rawTopic['title'] as String? ?? '',
        description: rawTopic['description'] as String? ?? '',
        level: _parseLevel(rawTopic['level'] as String?),
        duration: _durationForSubtopics(subtopics),
        xp: _xpForLevel(rawTopic['level'] as String?),
        stepCount: subtopics.length,
        prerequisiteId: rawTopic['prerequisite_id'] as String?,
        icon: _iconForTopic(topicCode),
      ),
      status: isCompleted
          ? TopicStatus.completed
          : completedSubtopics > 0
          ? TopicStatus.inProgress
          : TopicStatus.available,
      // Learn flow doesn't populate subtopic IDs — remoteProgress handles resume.
    );
  }

  List<TopicWithStatus> _applySequentialStatuses(List<TopicWithStatus> topics) {
    var firstOpenTopicSeen = false;

    return topics.map((topic) {
      if (topic.isCompleted) return topic;

      if (!firstOpenTopicSeen) {
        firstOpenTopicSeen = true;
        return TopicWithStatus(
          topic: topic.topic,
          status: topic.completedSubtopicIds.isNotEmpty
              ? TopicStatus.inProgress
              : TopicStatus.available,
          completedSubtopicIds: topic.completedSubtopicIds,
        );
      }

      return TopicWithStatus(
        topic: topic.topic,
        status: TopicStatus.locked,
        completedSubtopicIds: topic.completedSubtopicIds,
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchSubtopics(String topicCode) async {
    try {
      final response = await _dio.get(
        '/content/topics/$topicCode/subtopics',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode != 200) return const [];
      final subtopics = _readList(
        response.data,
      ).whereType<Map<String, dynamic>>().toList();
      for (final s in subtopics) {
        final code = s['code'] as String?;
        final qId = (s['quizId'] as num?)?.toInt();
        if (code != null && qId != null) _subtopicQuizIdCache[code] = qId;
      }
      return subtopics;
    } on DioException {
      return const [];
    }
  }

  TopicLevel _parseLevel(String? raw) {
    switch (raw) {
      case 'intermediate':
        return TopicLevel.intermediate;
      case 'advanced':
        return TopicLevel.advanced;
      default:
        return TopicLevel.beginner;
    }
  }

  String _durationForSubtopics(List<Map<String, dynamic>> subtopics) {
    final minutes = subtopics.fold<int>(
      0,
      (sum, subtopic) =>
          sum + ((subtopic['estimatedMinutes'] as num?)?.toInt() ?? 0),
    );
    return minutes == 0 ? '5 min' : '$minutes min';
  }

  int _xpForLevel(String? level) {
    switch (level) {
      case 'advanced':
        return 100;
      case 'intermediate':
        return 75;
      default:
        return 50;
    }
  }

  String _iconForTopic(String code) {
    switch (code) {
      case 'budgeting':
        return '💰';
      case 'savings':
        return '💾';
      case 'credit_and_debt':
        return '🏦';
      case 'financial_planning':
        return '🧭';
      case 'investments':
        return '📈';
      default:
        return '📚';
    }
  }

  Map<String, int> _topicProgressFromOverview(Object? data) {
    if (data is! Map<String, dynamic>) return {};

    final progress = data['progress'];
    if (progress is Map<String, dynamic>) {
      final topics = progress['topics'];
      if (topics is Map<String, dynamic>) {
        return topics.map((key, value) => MapEntry(key, _toInt(value)));
      }
    }

    final completedTopics = data['completed_topics'];
    if (completedTopics is List) {
      return {for (final topicId in completedTopics) topicId.toString(): 1};
    }

    return {};
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map<String, dynamic>) {
      return (value['subtopics_read'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }
}
