import '../../../../core/storage/subtopic_progress_storage.dart';
import '../../domain/entities/explore_section.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';
import '../models/section_model.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _remoteDataSource;
  final SubtopicProgressStorage _subtopicStorage;

  ExploreRepositoryImpl({
    required ExploreRemoteDataSource remoteDataSource,
    required SubtopicProgressStorage subtopicStorage,
  })  : _remoteDataSource = remoteDataSource,
        _subtopicStorage = subtopicStorage;

  @override
  Future<List<SubtopicItem>> getSubtopics(String topicId) =>
      _remoteDataSource.getSubtopics(topicId);

  @override
  Future<void> markSubtopicsCompleted(
    String topicId,
    Set<String> subtopicIds,
  ) async {
    final existing = _subtopicStorage.getCompletedSubtopicIds(topicId);
    final merged = {...existing, ...subtopicIds};
    await _subtopicStorage.saveCompletedSubtopicIds(topicId, merged);
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
      iconPath: model.iconPath,
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
