import '../../../../core/storage/learning_session_storage.dart';
import '../../../../core/storage/subtopic_progress_storage.dart';
import '../../domain/entities/explore_section.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';
import '../models/section_model.dart';
import '../models/topic_item_model.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _remoteDataSource;
  final LearningSessionStorage? _sessionStorage;
  final SubtopicProgressStorage _subtopicStorage;

  ExploreRepositoryImpl({
    required ExploreRemoteDataSource remoteDataSource,
    LearningSessionStorage? sessionStorage,
    required SubtopicProgressStorage subtopicStorage,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStorage = sessionStorage,
        _subtopicStorage = subtopicStorage;

  @override
  Future<List<TopicWithStatus>> getTopicsWithStatus() async {
    final results = await Future.wait([
      _remoteDataSource.getTopics(),
      _remoteDataSource.getCompletedTopicIds('current_user'),
      _remoteDataSource.getTopicProgress('current_user'),
    ]);
    final models = results[0] as List<TopicItemModel>;
    final completedIds = Set<String>.from(results[1] as List<String>);
    final progressMap = Map<String, int>.from(results[2] as Map<String, int>);

    final session = _sessionStorage?.getCurrentSession();

    final result = <TopicWithStatus>[];
    for (final model in models) {
      final topic = model.toEntity();
      final isCompleted = completedIds.contains(topic.id);
      final backendCount = progressMap[topic.id] ?? (isCompleted ? topic.stepCount : 0);

      final completedSubtopicIds = _resolveCompletedSubtopicIds(
        topicId: topic.id,
        isCompleted: isCompleted,
        backendCount: backendCount,
        orderedSubtopicIds: model.subtopicIds,
      );

      // Persist to local Hive so the UI can read it without a network call.
      if (completedSubtopicIds.isNotEmpty) {
        await _subtopicStorage.saveCompletedSubtopicIds(
          topic.id,
          completedSubtopicIds,
        );
      }

      var status = _resolveStatus(
        topic: topic,
        completedSet: completedIds,
        progressMap: progressMap,
        completedSubtopicIds: completedSubtopicIds,
        trackableCount: model.subtopicIds.length,
      );

      // Mark as inProgress if there is an active session for this topic.
      if (session != null &&
          session.topicId == topic.id &&
          status == TopicStatus.available) {
        status = TopicStatus.inProgress;
      }

      result.add(
        TopicWithStatus(
          topic: topic,
          status: status,
          completedSubtopicIds: completedSubtopicIds,
        ),
      );
    }

    return result;
  }

  /// Derive which subtopic IDs are completed.
  /// Backend gives only a count; we map it to the first N ordered IDs.
  /// Falls back to local Hive storage when it has more entries than the backend.
  Set<String> _resolveCompletedSubtopicIds({
    required String topicId,
    required bool isCompleted,
    required int backendCount,
    required List<String> orderedSubtopicIds,
  }) {
    final Set<String> fromBackend = isCompleted
        ? orderedSubtopicIds.toSet()
        : orderedSubtopicIds.take(backendCount).toSet();

    final fromLocal = _subtopicStorage.getCompletedSubtopicIds(topicId);

    // Use whichever source knows about more completed subtopics.
    return fromLocal.length > fromBackend.length ? fromLocal : fromBackend;
  }

  @override
  Future<List<SubtopicItem>> getSubtopics(String topicId) =>
      _remoteDataSource.getSubtopics(topicId);

  @override
  Future<void> recordTopicStarted(String topicId) async {
    // Backend updates via assessment submits; no direct progress endpoint.
  }

  @override
  Future<void> recordTopicCompleted(String topicId) async {
    // Backend updates via quiz submission. Clear local cache so the next
    // getTopicsWithStatus fetch from backend is the authority.
  }

  @override
  Future<void> markSubtopicsCompleted(
    String topicId,
    Set<String> subtopicIds,
  ) async {
    final existing = _subtopicStorage.getCompletedSubtopicIds(topicId);
    final merged = {...existing, ...subtopicIds};
    await _subtopicStorage.saveCompletedSubtopicIds(topicId, merged);
  }

  TopicStatus _resolveStatus({
    required TopicItem topic,
    required Set<String> completedSet,
    required Map<String, int> progressMap,
    required Set<String> completedSubtopicIds,
    required int trackableCount,
  }) {
    if (completedSet.contains(topic.id)) return TopicStatus.completed;
    if (trackableCount > 0 && completedSubtopicIds.length >= trackableCount) {
      return TopicStatus.completed;
    }
    if (topic.prerequisiteId != null &&
        !completedSet.contains(topic.prerequisiteId)) {
      return TopicStatus.locked;
    }
    if (progressMap.containsKey(topic.id) && (progressMap[topic.id] ?? 0) > 0) {
      return TopicStatus.inProgress;
    }
    return TopicStatus.available;
  }

  @override
  Future<List<ExploreSection>> getSections() async {
    final models = await _remoteDataSource.getExploreView();
    return models.map(_mapSection).toList();
  }

  ExploreSection _mapSection(ExploreSectionModel model) {
    final topics = model.topics.map(_mapExploreTopicToStatus).toList();
    return ExploreSection(
      id: model.id,
      code: model.code,
      orderIndex: model.orderIndex,
      icon: model.icon,
      title: model.title,
      description: model.description,
      topics: topics,
      lessonsDone: model.lessonsDone,
      lessonsTotal: model.lessonsTotal,
    );
  }

  TopicWithStatus _mapExploreTopicToStatus(ExploreTopicModel model) {
    final level = _parseLevelFrom(model.level);
    final topic = TopicItem(
      id: model.code,
      title: model.title,
      description: model.description,
      level: level,
      duration: model.estimatedMinutes == 0
          ? '5 min'
          : '${model.estimatedMinutes} min',
      xp: model.xpReward,
      stepCount: model.lessonsTotal,
      icon: _iconForTopicCode(model.code),
    );

    final completedIds = _subtopicStorage.getCompletedSubtopicIds(model.code);

    return TopicWithStatus(
      topic: topic,
      status: _statusFromProgress(model.lessonsDone, model.lessonsTotal),
      completedSubtopicIds: completedIds,
    );
  }

  TopicStatus _statusFromProgress(int done, int total) {
    if (total > 0 && done >= total) return TopicStatus.completed;
    if (done > 0) return TopicStatus.inProgress;
    return TopicStatus.available;
  }

  TopicLevel _parseLevelFrom(String level) {
    switch (level) {
      case 'intermediate':
        return TopicLevel.intermediate;
      case 'advanced':
        return TopicLevel.advanced;
      default:
        return TopicLevel.beginner;
    }
  }

  String _iconForTopicCode(String code) {
    const icons = <String, String>{
      'personal_finance_basics': '💵',
      'money_and_banking': '🏦',
      'budgeting_cash_flow': '📊',
      'debt_and_credit': '💳',
      'emergency_funds': '🛡',
      'insurance_basics': '🔒',
      'why_invest': '🌱',
      'stocks': '📈',
      'bonds': '📜',
      'funds_etf': '🗂',
      'retirement_accounts': '🏖',
      'real_estate_lite': '🏠',
      'how_markets_work': '🌐',
      'macro_for_investors': '🔭',
      'interest_rates_inflation': '📉',
      'crypto_blockchain': '⚡',
      'fintech_payments': '📱',
      'portfolio_construction': '🎯',
      'financial_statements': '📋',
      'tax_planning': '🧾',
      'estate_planning': '⚖',
      'career_income': '💼',
      'behavioral_finance': '🧠',
      'personal_financial_plan': '🗺',
    };
    return icons[code] ?? '📚';
  }
}
