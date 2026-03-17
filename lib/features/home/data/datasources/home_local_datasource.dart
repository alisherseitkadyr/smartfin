// smartfin/lib/features/home/data/datasources/home_local_datasource.dart
import '../models/home_models.dart';

abstract class HomeLocalDataSource {
  Future<HomeDataModel> getHomeData();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<HomeDataModel> getHomeData() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const HomeDataModel(
      user: UserSummaryModel(
        name: 'Alex',
        totalXp: 2150,
        level: 5,
        streakDays: 12,
        completedTopics: 3,
        totalTopics: 7,
      ),
      currentTopic: FeaturedTopicModel(
        topicId: 'saving',
        title: 'Smart Saving',
        emoji: '💾',
        level: 'Beginner',
        xp: 50,
        duration: '5 min',
        isInProgress: true,
        progressPercent: 0.33,
      ),
      recommendedTopics: [
        FeaturedTopicModel(
          topicId: 'credit',
          title: 'Credit Score',
          emoji: '📊',
          level: 'Intermediate',
          xp: 75,
          duration: '7 min',
          isInProgress: false,
          progressPercent: 0,
        ),
        FeaturedTopicModel(
          topicId: 'investing',
          title: 'Investing Basics',
          emoji: '📈',
          level: 'Advanced',
          xp: 100,
          duration: '10 min',
          isInProgress: false,
          progressPercent: 0,
        ),
        FeaturedTopicModel(
          topicId: 'emergency',
          title: 'Emergency Fund',
          emoji: '🛡️',
          level: 'Beginner',
          xp: 50,
          duration: '5 min',
          isInProgress: false,
          progressPercent: 0,
        ),
      ],
      snapshot: MonthlySnapshotModel(
        totalSpent: 284500,
        totalSaved: 45800,
        currency: '₸',
        monthLabel: 'February 2026',
        spentChangePercent: 12.0,
        savedChangePercent: -8.0,
      ),
      quickActions: [
        QuickActionModel(id: 'learn', label: 'Continue\nLearning', emoji: '📚', route: '/learn'),
        QuickActionModel(id: 'expenses', label: 'Track\nExpenses', emoji: '💳', route: '/expenses'),
        QuickActionModel(id: 'explore', label: 'Explore\nTopics', emoji: '🔭', route: '/explore'),
        QuickActionModel(id: 'quiz', label: 'Daily\nQuiz', emoji: '🎯', route: '/quiz'),
      ],
    );
  }
}