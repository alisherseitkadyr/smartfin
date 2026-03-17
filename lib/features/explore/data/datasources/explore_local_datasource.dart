import '../models/topic_item_model.dart';

abstract class ExploreLocalDataSource {
  Future<List<TopicItemModel>> getTopics();
  Future<List<String>> getCompletedTopicIds();
  Future<Map<String, int>> getTopicProgress(); // topicId -> completedSteps
}

class ExploreLocalDataSourceImpl implements ExploreLocalDataSource {
  static const _topics = [
    {
      'id': 'budgeting',
      'title': 'Budgeting Basics',
      'description': 'Learn to track where your money goes each month.',
      'level': 'beginner',
      'duration': '6 min',
      'xp': 50,
      'step_count': 3,
      'prerequisite_id': null,
      'icon': '💰',
    },
    {
      'id': 'saving',
      'title': 'Smart Saving',
      'description': 'Build saving habits that actually stick.',
      'level': 'beginner',
      'duration': '5 min',
      'xp': 50,
      'step_count': 3,
      'prerequisite_id': 'budgeting',
      'icon': '💾',
    },
    {
      'id': 'emergency',
      'title': 'Emergency Fund',
      'description': 'Create your financial safety net.',
      'level': 'beginner',
      'duration': '5 min',
      'xp': 50,
      'step_count': 3,
      'prerequisite_id': 'saving',
      'icon': '🛡️',
    },
    {
      'id': 'credit',
      'title': 'Credit Score',
      'description': 'Understand and improve your credit health.',
      'level': 'intermediate',
      'duration': '7 min',
      'xp': 75,
      'step_count': 3,
      'prerequisite_id': 'budgeting',
      'icon': '📊',
    },
    {
      'id': 'debt',
      'title': 'Debt Management',
      'description': 'Smart strategies to pay off debt faster.',
      'level': 'intermediate',
      'duration': '8 min',
      'xp': 75,
      'step_count': 3,
      'prerequisite_id': 'credit',
      'icon': '🏦',
    },
    {
      'id': 'investing',
      'title': 'Investing Basics',
      'description': 'Make your money work for you.',
      'level': 'advanced',
      'duration': '10 min',
      'xp': 100,
      'step_count': 3,
      'prerequisite_id': 'saving',
      'icon': '📈',
    },
    {
      'id': 'retirement',
      'title': 'Retirement Planning',
      'description': 'Plan for a financially secure future.',
      'level': 'advanced',
      'duration': '9 min',
      'xp': 100,
      'step_count': 3,
      'prerequisite_id': 'investing',
      'icon': '🏖️',
    },
  ];

  @override
  Future<List<TopicItemModel>> getTopics() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _topics.map((j) => TopicItemModel.fromJson(Map<String, dynamic>.from(j))).toList();
  }

  @override
  Future<List<String>> getCompletedTopicIds() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    // Mock: budgeting is completed
    return ['budgeting'];
  }

  @override
  Future<Map<String, int>> getTopicProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    // Mock: saving is in progress at step 1
    return {'saving': 1};
  }
}