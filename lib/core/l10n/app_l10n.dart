import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/language_provider.dart';
import '../../features/explore/domain/entities/topic_item.dart';

// ── Provider ──────────────────────────────────────────────────
final appL10nProvider = Provider<AppL10n>((ref) {
  final lang = ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
  return AppL10n.of(lang);
});

// ── Abstract base ─────────────────────────────────────────────
abstract class AppL10n {
  factory AppL10n.of(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return AppL10nRu();
      case 'kk':
        return AppL10nKk();
      default:
        return AppL10nEn();
    }
  }

  // ── Navigation ──────────────────────────────────────────────
  String get navHome;
  String get navExplore;
  String get navLearn;
  String get navExpenses;
  String get navProfile;

  // ── Profile ─────────────────────────────────────────────────
  String get profileTitle;
  String get settingsTitle;
  String get sectionAccount;
  String get editProfile;
  String get notifications;
  String get changePassword;
  String get sectionAbout;
  String get privacyPolicy;
  String get termsOfService;
  String get appVersion;
  String get deleteAccount;
  String get signOut;
  String get sectionPreferences;
  String get darkTheme;
  String get language;
  String get currency;
  String get account;
  String get appearance;
  String get enableLessonReminders;
  String get remindersSubtitle;
  String get reminderDelay;
  String minutesLabel(int minutes);
  String get close;
  String lastUpdated(String date);
  String monthName(int month);
  String get comingSoon;
  String get signOutTitle;
  String get signOutBody;
  String get signOutConfirm;
  String get deleteAccountTitle;
  String get deleteAccountBody;
  String get deleteAccountConfirm;

  // ── Home ────────────────────────────────────────────────────
  String get recommendedForYou;
  String get repeatForYou;
  String get newForYou;
  String get seeAll;
  String get somethingWentWrong;
  String get retry;
  String get moneyTip;
  String get tapForNext;
  String get showNextMoneyTip;
  String get continueLearning;

  // ── Explore ─────────────────────────────────────────────────
  String get exploreTopics;
  String get all;
  String get searchTopics;
  String get done;
  String noTopicsMatch(String query);
  String get clearSearch;

  // ── Topic levels ─────────────────────────────────────────────
  String levelLabel(TopicLevel level);

  // ── Learn ───────────────────────────────────────────────────
  String get lessonSteps;
  String get upNext;

  // ── Lesson flow ──────────────────────────────────────────────
  String stepOf(int current, int total);
  String get back;
  String get next;
  String get quiz;
  String get example;
  String get rememberThis;
  String get couldntLoadLesson;
  String get goBack;
  String xpLabel(int xp);

  // ── Quiz ─────────────────────────────────────────────────────
  String get knowledgeCheck;
  String qOf(int q, int total);
  String get correct;
  String get incorrect;
  String get notQuite;
  String correctAnswer(String answer);
  String get seeResults;
  String get continueQuiz;
  String get check;
  String get preparingQuiz;
  String get calculatingResults;

  // ── Lesson complete ──────────────────────────────────────────
  String get lessonComplete;
  String correctScore(int count, int total);
  String get nextLesson;
  String get completeTopic;
  String get backToExplore;
  String dayStreak(int days);

  // ── Greetings ─────────────────────────────────────────────────
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;

  // ── Home stats ─────────────────────────────────────────────────
  String xpToLevelLabel(int xp, int level);
  String get topicsDoneLabel;
  String get currentRankLabel;
  String streakChip(int days);

  // ── Profile stats ──────────────────────────────────────────────
  String get statistics;
  String get dayStreakStatLabel;
  String get totalXpLabel;
  String get totalTopicsLabel;
  String xpToNextLabel(int xp);

  // ── Account page ───────────────────────────────────────────────
  String get nameLabel;
  String get save;
  String get yourNameHint;
  String get currentPasswordLabel;
  String get newPasswordLabel;
  String get confirmNewPasswordLabel;
  String get nameChanged;
  String get passwordChanged;
  String get failedToUpdateName;
  String get failedToChangePassword;

  // ── Up next / nearby cards ─────────────────────────────────────
  String get subtopicDoneLabel;
  String get subtopicLockedLabel;
  String completedXpLabel(int xp);

  // ── Lesson hero banner ─────────────────────────────────────────
  String stepsCount(int n);
  String stepsProgress(int completed, int total);

  // ── Topic/lesson CTA labels ───────────────────────────────────
  String get startLesson;
  String get reviewLesson;
  String continueLesson(int step);
  String get startTopic;
  String get continueTopic;
  String get takeFinalQuiz;
  String get startLearning;

  // ── Lesson step badges ────────────────────────────────────────
  String get stepDone;
  String get stepInProgress;
  String get quizPassed;
  String get takeTheQuiz;
  String get quizLabel;

  // ── Auth ─────────────────────────────────────────────────────
  String get welcomeBack;
  String get signInSubtitle;
  String get email;
  String get emailHint;
  String get enterEmail;
  String get enterValidEmail;
  String get password;
  String get passwordHint;
  String get enterPassword;
  String get signInButton;
  String get noAccount;
  String get signUpLink;
  String get createAccountTitle;
  String get createAccountSubtitle;
  String get fullName;
  String get fullNameHint;
  String get enterName;
  String get passwordHint2;
  String get enterAPassword;
  String get atLeast5Chars;
  String get useAtLeastOneDigit;
  String get noSpacesOrCommas;
  String get confirmPassword;
  String get passwordsDoNotMatch;
  String get createAccountButton;
  String get alreadyHaveAccount;
  String get signInLink;

  // ── Legal content (localized sections) ─────────────────────────
  List<L10nLegalSection> get privacyPolicySections;
  List<L10nLegalSection> get termsOfServiceSections;
}

// Lightweight container for localized legal sections.
class L10nLegalSection {
  final String title;
  final String body;
  const L10nLegalSection({required this.title, required this.body});
}

// ── English ───────────────────────────────────────────────────
class AppL10nEn implements AppL10n {
  @override String get navHome => 'Home';
  @override String get navExplore => 'Explore';
  @override String get navLearn => 'Learn';
  @override String get navExpenses => 'Expenses';
  @override String get navProfile => 'Profile';

  @override String get profileTitle => 'Profile';
  @override String get settingsTitle => 'Settings';
  @override String get sectionAccount => 'ACCOUNT';
  @override String get editProfile => 'Edit profile';
  @override String get notifications => 'Notifications';
  @override String get changePassword => 'Change password';
  @override String get sectionAbout => 'ABOUT';
  @override String get privacyPolicy => 'Privacy policy';
  @override String get termsOfService => 'Terms of service';
  @override String get appVersion => 'App version';
  @override String get deleteAccount => 'Delete account';
  @override String get signOut => 'Sign out';
  @override String get sectionPreferences => 'PREFERENCES';
  @override String get darkTheme => 'Dark theme';
  @override String get language => 'Language';
  @override String get currency => 'Currency';
  @override String get account => 'Account';
  @override String get appearance => 'Appearance';
  @override String get enableLessonReminders => 'Enable lesson reminders';
  @override String get remindersSubtitle =>
      'Receive a notification when it is time to return.';
  @override String get reminderDelay => 'Reminder delay';
  @override String minutesLabel(int minutes) => '${minutes}m';
  @override String get close => 'Close';
  @override String lastUpdated(String date) => 'Last updated: $date';
  @override String monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }
  @override String get comingSoon => 'Coming soon';
  @override String get signOutTitle => 'Sign out?';
  @override String get signOutBody => 'You can sign back in anytime.';
  @override String get signOutConfirm => 'Sign out';
  @override String get deleteAccountTitle => 'Delete account?';
  @override String get deleteAccountBody =>
      'This will permanently delete all your data, progress, and settings. This action cannot be undone.';
  @override String get deleteAccountConfirm => 'Delete account';

  @override String get recommendedForYou => 'Recommended for you';
  @override String get repeatForYou => 'Repeat for you';
  @override String get newForYou => 'New for you';
  @override String get seeAll => 'See all';
  @override String get somethingWentWrong => 'Something went wrong';
  @override String get retry => 'Retry';
  @override String get moneyTip => 'Money tip';
  @override String get tapForNext => 'Tap for next';
  @override String get showNextMoneyTip => 'Show next money tip';
  @override String get continueLearning => 'Continue learning';

  @override String get exploreTopics => 'Explore Topics';
  @override String get all => 'All';
  @override String get searchTopics => 'Search topics…';
  @override String get done => 'done';
  @override String noTopicsMatch(String query) => 'No topics match "$query"';
  @override String get clearSearch => 'Clear search';

  @override String levelLabel(TopicLevel level) {
    switch (level) {
      case TopicLevel.beginner: return 'Beginner';
      case TopicLevel.intermediate: return 'Intermediate';
      case TopicLevel.advanced: return 'Advanced';
    }
  }

  @override String get lessonSteps => 'Lesson steps';
  @override String get upNext => 'Up next';

  @override String stepOf(int current, int total) => 'Step $current of $total';
  @override String get back => 'Back';
  @override String get next => 'Next';
  @override String get quiz => 'Quiz';
  @override String get example => '📌 Example';
  @override String get rememberThis => 'Remember this';
  @override String get couldntLoadLesson => "Couldn't load lesson";
  @override String get goBack => 'Go back';
  @override String xpLabel(int xp) => '+$xp XP';

  @override String get knowledgeCheck => 'Knowledge Check';
  @override String qOf(int q, int total) => 'Q$q / $total';
  @override String get correct => 'Correct! 🎉';
  @override String get incorrect => 'Incorrect';
  @override String get notQuite => 'Not quite';
  @override String correctAnswer(String answer) => 'Correct answer: $answer';
  @override String get seeResults => 'See results →';
  @override String get continueQuiz => 'Continue →';
  @override String get check => 'Check';
  @override String get preparingQuiz => 'Preparing quiz…';
  @override String get calculatingResults => 'Calculating results…';

  @override String get lessonComplete => 'Lesson Complete!';
  @override String correctScore(int count, int total) => '$count / $total correct';
  @override String get nextLesson => 'Next Lesson →';
  @override String get completeTopic => 'Complete Topic →';
  @override String get backToExplore => 'Back to Explore';
  @override String dayStreak(int days) => '$days day streak — keep it up!';

  @override String get goodMorning => 'Good morning';
  @override String get goodAfternoon => 'Good afternoon';
  @override String get goodEvening => 'Good evening';

  @override String xpToLevelLabel(int xp, int level) => '$xp to Level $level';
  @override String get topicsDoneLabel => 'Topics done';
  @override String get currentRankLabel => 'Current rank';
  @override String streakChip(int days) => '🔥 ${days}d';

  @override String get statistics => 'STATISTICS';
  @override String get dayStreakStatLabel => 'Day streak';
  @override String get totalXpLabel => 'Total XP';
  @override String get totalTopicsLabel => 'Total topics';
  @override String xpToNextLabel(int xp) => '$xp XP to next';

  @override String get nameLabel => 'Name';
  @override String get save => 'Save';
  @override String get yourNameHint => 'Your name';
  @override String get currentPasswordLabel => 'Current password';
  @override String get newPasswordLabel => 'New password';
  @override String get confirmNewPasswordLabel => 'Confirm new password';
  @override String get nameChanged => 'Name changed';
  @override String get passwordChanged => 'Password changed';
  @override String get failedToUpdateName => 'Failed to update name';
  @override String get failedToChangePassword => 'Failed to change password';

  @override String get subtopicDoneLabel => '✅ Done';
  @override String get subtopicLockedLabel => '🔒 Complete previous first';
  @override String completedXpLabel(int xp) => '✅ Completed • ⭐ $xp XP';
  @override String stepsCount(int n) => '$n steps';
  @override String stepsProgress(int completed, int total) => '$completed / $total steps';

  @override String get startLesson => 'Start Lesson';
  @override String get reviewLesson => 'Review Lesson';
  @override String continueLesson(int step) => 'Continue — Step $step';
  @override String get startTopic => 'Start Topic';
  @override String get continueTopic => 'Continue Topic';
  @override String get takeFinalQuiz => 'Take Final Quiz';
  @override String get startLearning => 'Start Learning';

  @override String get stepDone => '✓ Done';
  @override String get stepInProgress => '▶ In progress';
  @override String get quizPassed => '✓ Passed';
  @override String get takeTheQuiz => '▶ Take the quiz';
  @override String get quizLabel => '📝 Quiz';

  @override String get welcomeBack => 'Welcome back';
  @override String get signInSubtitle => 'Sign in to continue your learning journey.';
  @override String get email => 'Email';
  @override String get emailHint => 'you@example.com';
  @override String get enterEmail => 'Enter your email';
  @override String get enterValidEmail => 'Enter a valid email';
  @override String get password => 'Password';
  @override String get passwordHint => '••••••••';
  @override String get enterPassword => 'Enter your password';
  @override String get signInButton => 'Sign In';
  @override String get noAccount => "Don't have an account? ";
  @override String get signUpLink => 'Sign up';
  @override String get createAccountTitle => 'Create account';
  @override String get createAccountSubtitle => 'Start your journey to financial freedom.';
  @override String get fullName => 'Full name';
  @override String get fullNameHint => 'Alex Johnson';
  @override String get enterName => 'Enter your name';
  @override String get passwordHint2 => 'At least 5 characters, 1 digit';
  @override String get enterAPassword => 'Enter a password';
  @override String get atLeast5Chars => 'At least 5 characters';
  @override String get useAtLeastOneDigit => 'Use at least one digit';
  @override String get noSpacesOrCommas => 'No spaces or commas';
  @override String get confirmPassword => 'Confirm password';
  @override String get passwordsDoNotMatch => 'Passwords do not match';
  @override String get createAccountButton => 'Create Account';
  @override String get alreadyHaveAccount => 'Already have an account? ';
  @override String get signInLink => 'Sign in';

  // ── Legal content ───────────────────────────────────────────
  @override List<L10nLegalSection> get privacyPolicySections => [
        const L10nLegalSection(
          title: '1. Introduction',
          body:
              'SmartFin ("we", "our", or "us") is committed to protecting your privacy. '
              'This Privacy Policy explains how we collect, use, and safeguard your personal '
              'information when you use our financial literacy application.',
        ),
        const L10nLegalSection(
          title: '2. Information We Collect',
          body:
              'We collect the following types of information:\n\n'
              '• Account information: name and email address provided during registration.\n\n'
              '• Learning data: your quiz scores, completed topics, and progress within the app.\n\n'
              '• Usage data: session activity, feature interactions, and device identifiers used '
              'to improve the learning experience.',
        ),
        const L10nLegalSection(
          title: '3. How We Use Your Information',
          body:
              'Your information is used to:\n\n'
              '• Personalise your learning path and topic recommendations.\n\n'
              '• Track your progress and generate performance insights.\n\n'
              '• Send lesson reminders and relevant notifications (only if enabled).\n\n'
              '• Improve app features through aggregated, anonymised analytics.',
        ),
        const L10nLegalSection(
          title: '4. Data Storage and Security',
          body:
              'Your data is stored on secure servers. We apply industry-standard encryption '
              'for data in transit and at rest. Access to personal information is restricted to '
              'authorised personnel only. We retain your data for as long as your account is active '
              'or as required to provide our services.',
        ),
        const L10nLegalSection(
          title: '5. Third-Party Services',
          body:
              'We may use third-party services for authentication (Google Sign-In) and analytics. '
              'These services operate under their own privacy policies. We do not sell or share your '
              'personal information with third parties for marketing purposes.',
        ),
        const L10nLegalSection(
          title: '6. Your Rights',
          body:
              'You have the right to:\n\n'
              '• Access and review the personal data we hold about you.\n\n'
              '• Request correction of inaccurate information.\n\n'
              '• Delete your account and associated data at any time from the Account settings.\n\n'
              '• Withdraw consent for notifications at any time.',
        ),
        const L10nLegalSection(
          title: '7. Contact Us',
          body:
              'If you have questions about this Privacy Policy or how your data is handled, '
              'please contact us at support@smartfin.app.',
        ),
      ];

  @override List<L10nLegalSection> get termsOfServiceSections => [
        const L10nLegalSection(
          title: '1. Acceptance of Terms',
          body:
              'By accessing or using SmartFin, you agree to be bound by these Terms of Service. '
              'If you do not agree with any part of these terms, you may not use the application. '
              'These terms apply to all users, including visitors and registered users.',
        ),
        const L10nLegalSection(
          title: '2. Use of the Service',
          body:
              'SmartFin is a financial literacy platform designed for educational purposes only. '
              'The content provided — including lessons, quizzes, and recommendations — is intended '
              'to improve financial knowledge and does not constitute financial advice. '
              'Always consult a qualified financial professional before making financial decisions.',
        ),
        const L10nLegalSection(
          title: '3. User Accounts',
          body:
              'You are responsible for maintaining the confidentiality of your account credentials. '
              'You agree to provide accurate information during registration and to keep it up to date. '
              'We reserve the right to suspend or terminate accounts that violate these terms or '
              'engage in fraudulent activity.',
        ),
        const L10nLegalSection(
          title: '4. Intellectual Property',
          body:
              'All content within SmartFin — including course materials, illustrations, logos, '
              'and software — is the property of SmartFin or its content providers and is protected '
              'by applicable intellectual property laws. You may not reproduce, distribute, or create '
              'derivative works without express written permission.',
        ),
        const L10nLegalSection(
          title: '5. Prohibited Activities',
          body:
              'You agree not to:\n\n'
              '• Attempt to gain unauthorised access to the app or its infrastructure.\n\n'
              '• Use automated tools to scrape or extract content.\n\n'
              '• Share your account with others or create accounts on behalf of third parties.\n\n'
              '• Submit false or misleading information.',
        ),
        const L10nLegalSection(
          title: '6. Disclaimers',
          body:
              'The app is provided "as is" without warranties of any kind, either express or implied. '
              'We do not guarantee that the service will be uninterrupted, error-free, or that '
              'inaccuracies will be corrected. Educational content is reviewed regularly but may not '
              'reflect the latest regulatory or market changes.',
        ),
        const L10nLegalSection(
          title: '7. Limitation of Liability',
          body:
              'To the fullest extent permitted by law, SmartFin shall not be liable for any indirect, '
              'incidental, or consequential damages arising from your use of or inability to use the '
              'service. Our total liability for any claim shall not exceed the amount you paid, if any, '
              'for access to the service in the past twelve months.',
        ),
        const L10nLegalSection(
          title: '8. Changes to Terms',
          body:
              'We reserve the right to update these Terms of Service at any time. Changes will be '
              'communicated through an in-app notice or by updating the "Last updated" date above. '
              'Continued use of the app after changes become effective constitutes your acceptance '
              'of the revised terms.',
        ),
        const L10nLegalSection(
          title: '9. Contact',
          body:
              'If you have any questions about these Terms of Service, please reach out to us at '
              'support@smartfin.app.',
        ),
      ];
}

// ── Russian ───────────────────────────────────────────────────
class AppL10nRu implements AppL10n {
  @override String get navHome => 'Главная';
  @override String get navExplore => 'Темы';
  @override String get navLearn => 'Учиться';
  @override String get navExpenses => 'Расходы';
  @override String get navProfile => 'Профиль';

  @override String get profileTitle => 'Профиль';
  @override String get settingsTitle => 'Настройки';
  @override String get sectionAccount => 'АККАУНТ';
  @override String get editProfile => 'Редактировать профиль';
  @override String get notifications => 'Уведомления';
  @override String get changePassword => 'Изменить пароль';
  @override String get sectionAbout => 'О ПРИЛОЖЕНИИ';
  @override String get privacyPolicy => 'Политика конфиденциальности';
  @override String get termsOfService => 'Условия использования';
  @override String get appVersion => 'Версия приложения';
  @override String get deleteAccount => 'Удалить аккаунт';
  @override String get signOut => 'Выйти';
  @override String get sectionPreferences => 'НАСТРОЙКИ';
  @override String get darkTheme => 'Тёмная тема';
  @override String get language => 'Язык';
  @override String get currency => 'Валюта';
  @override String get account => 'Аккаунт';
  @override String get appearance => 'Внешний вид';
  @override String get enableLessonReminders => 'Включить напоминания уроков';
  @override String get remindersSubtitle =>
      'Получать уведомление, когда пора вернуться.';
  @override String get reminderDelay => 'Задержка напоминания';
  @override String minutesLabel(int minutes) => '$minutesм';
  @override String get close => 'Закрыть';
  @override String lastUpdated(String date) => 'Последнее обновление: $date';
  @override String get comingSoon => 'Скоро';
  @override String monthName(int month) {
    const names = [
      'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
      'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }
  @override String get signOutTitle => 'Выйти?';
  @override String get signOutBody => 'Вы можете войти снова в любое время.';
  @override String get signOutConfirm => 'Выйти';
  @override String get deleteAccountTitle => 'Удалить аккаунт?';
  @override String get deleteAccountBody =>
      'Это навсегда удалит все ваши данные, прогресс и настройки. Это действие нельзя отменить.';
  @override String get deleteAccountConfirm => 'Удалить аккаунт';

  @override String get recommendedForYou => 'Рекомендуем для вас';
  @override String get repeatForYou => 'Повторите для закрепления';
  @override String get newForYou => 'Новое для вас';
  @override String get seeAll => 'Все';
  @override String get somethingWentWrong => 'Что-то пошло не так';
  @override String get retry => 'Повторить';
  @override String get moneyTip => 'Совет по финансам';
  @override String get tapForNext => 'Нажмите для следующего';
  @override String get showNextMoneyTip => 'Показать следующий совет';
  @override String get continueLearning => 'Продолжить обучение';

  @override String get exploreTopics => 'Темы';
  @override String get all => 'Все';
  @override String get searchTopics => 'Поиск тем…';
  @override String get done => 'готово';
  @override String noTopicsMatch(String query) => 'Нет тем по запросу "$query"';
  @override String get clearSearch => 'Очистить';

  @override String levelLabel(TopicLevel level) {
    switch (level) {
      case TopicLevel.beginner: return 'Начинающий';
      case TopicLevel.intermediate: return 'Средний';
      case TopicLevel.advanced: return 'Продвинутый';
    }
  }

  @override String get lessonSteps => 'Шаги урока';
  @override String get upNext => 'Далее';

  @override String stepOf(int current, int total) => 'Шаг $current из $total';
  @override String get back => 'Назад';
  @override String get next => 'Далее';
  @override String get quiz => 'Тест';
  @override String get example => '📌 Пример';
  @override String get rememberThis => '✅ Запомни это';
  @override String get couldntLoadLesson => 'Не удалось загрузить урок';
  @override String get goBack => 'Назад';
  @override String xpLabel(int xp) => '+$xp XP';

  @override String get knowledgeCheck => 'Проверка знаний';
  @override String qOf(int q, int total) => 'В$q / $total';
  @override String get correct => 'Правильно! 🎉';
  @override String get incorrect => 'Неправильно';
  @override String get notQuite => 'Не совсем';
  @override String correctAnswer(String answer) => 'Правильный ответ: $answer';
  @override String get seeResults => 'Результаты →';
  @override String get continueQuiz => 'Продолжить →';
  @override String get check => 'Проверить';
  @override String get preparingQuiz => 'Подготовка теста…';
  @override String get calculatingResults => 'Подсчёт результатов…';

  @override String get lessonComplete => 'Урок завершён!';
  @override String correctScore(int count, int total) => '$count / $total правильно';
  @override String get nextLesson => 'Следующий урок →';
  @override String get completeTopic => 'Завершить тему →';
  @override String get backToExplore => 'К темам';
  @override String dayStreak(int days) => 'Серия $days дней — продолжай!';

  @override String get goodMorning => 'Доброе утро';
  @override String get goodAfternoon => 'Добрый день';
  @override String get goodEvening => 'Добрый вечер';

  @override String xpToLevelLabel(int xp, int level) => '$xp до уровня $level';
  @override String get topicsDoneLabel => 'Тем пройдено';
  @override String get currentRankLabel => 'Текущий ранг';
  @override String streakChip(int days) => '🔥 $daysд';

  @override String get statistics => 'СТАТИСТИКА';
  @override String get dayStreakStatLabel => 'Дней подряд';
  @override String get totalXpLabel => 'Всего XP';
  @override String get totalTopicsLabel => 'Всего тем';
  @override String xpToNextLabel(int xp) => '$xp XP до следующего';

  @override String get nameLabel => 'Имя';
  @override String get save => 'Сохранить';
  @override String get yourNameHint => 'Ваше имя';
  @override String get currentPasswordLabel => 'Текущий пароль';
  @override String get newPasswordLabel => 'Новый пароль';
  @override String get confirmNewPasswordLabel => 'Подтвердите новый пароль';
  @override String get nameChanged => 'Имя изменено';
  @override String get passwordChanged => 'Пароль изменён';
  @override String get failedToUpdateName => 'Не удалось изменить имя';
  @override String get failedToChangePassword => 'Не удалось изменить пароль';

  @override String get subtopicDoneLabel => '✅ Готово';
  @override String get subtopicLockedLabel => '🔒 Сначала завершите предыдущее';
  @override String completedXpLabel(int xp) => '✅ Пройдено • ⭐ $xp XP';
  @override String stepsCount(int n) => '$n шагов';
  @override String stepsProgress(int completed, int total) => '$completed / $total шагов';

  @override String get startLesson => 'Начать урок';
  @override String get reviewLesson => 'Повторить урок';
  @override String continueLesson(int step) => 'Продолжить — Шаг $step';
  @override String get startTopic => 'Начать тему';
  @override String get continueTopic => 'Продолжить тему';
  @override String get takeFinalQuiz => 'Пройти финальный тест';
  @override String get startLearning => 'Начать обучение';

  @override String get stepDone => '✓ Готово';
  @override String get stepInProgress => '▶ В процессе';
  @override String get quizPassed => '✓ Пройдено';
  @override String get takeTheQuiz => '▶ Пройти тест';
  @override String get quizLabel => '📝 Тест';

  @override String get welcomeBack => 'С возвращением 👋';
  @override String get signInSubtitle => 'Войдите, чтобы продолжить обучение.';
  @override String get email => 'Эл. почта';
  @override String get emailHint => 'you@example.com';
  @override String get enterEmail => 'Введите эл. почту';
  @override String get enterValidEmail => 'Введите корректный адрес';
  @override String get password => 'Пароль';
  @override String get passwordHint => '••••••••';
  @override String get enterPassword => 'Введите пароль';
  @override String get signInButton => 'Войти';
  @override String get noAccount => 'Нет аккаунта? ';
  @override String get signUpLink => 'Зарегистрироваться';
  @override String get createAccountTitle => 'Создать аккаунт 🌱';
  @override String get createAccountSubtitle => 'Начните путь к финансовой свободе.';
  @override String get fullName => 'Полное имя';
  @override String get fullNameHint => 'Иван Иванов';
  @override String get enterName => 'Введите имя';
  @override String get passwordHint2 => 'Минимум 5 символов, 1 цифра';
  @override String get enterAPassword => 'Введите пароль';
  @override String get atLeast5Chars => 'Минимум 5 символов';
  @override String get useAtLeastOneDigit => 'Используйте хотя бы одну цифру';
  @override String get noSpacesOrCommas => 'Без пробелов и запятых';
  @override String get confirmPassword => 'Подтвердите пароль';
  @override String get passwordsDoNotMatch => 'Пароли не совпадают';
  @override String get createAccountButton => 'Создать аккаунт';
  @override String get alreadyHaveAccount => 'Уже есть аккаунт? ';
  @override String get signInLink => 'Войти';

  // ── Legal content (RU) ─────────────────────────────────────
  @override List<L10nLegalSection> get privacyPolicySections => [
        const L10nLegalSection(
          title: '1. Введение',
          body:
              'SmartFin ("мы", "наш", или "нас") стремится защищать вашу конфиденциальность. '
              'Эта Политика конфиденциальности объясняет, какие данные мы собираем, как мы их используем и защищаем при использовании приложения.',
        ),
        const L10nLegalSection(
          title: '2. Информация, которую мы собираем',
          body:
              'Мы собираем следующие типы информации:\n\n'
              '• Информация аккаунта: имя и адрес электронной почты, указанные при регистрации.\n\n'
              '• Данные обучения: ваши результаты тестов, пройденные темы и прогресс в приложении.\n\n'
              '• Данные использования: активность сессий, взаимодействие с функциями и идентификаторы устройств, используемые для улучшения опыта.',
        ),
        const L10nLegalSection(
          title: '3. Как мы используем вашу информацию',
          body:
              'Ваша информация используется для:\n\n'
              '• Персонализации вашего учебного пути и рекомендаций.\n\n'
              '• Отслеживания прогресса и создания аналитики по результатам.\n\n'
              '• Отправки напоминаний о занятиях и релевантных уведомлений (только при включении).\n\n'
              '• Улучшения функций приложения через агрегированную и анонимизированную аналитику.',
        ),
        const L10nLegalSection(
          title: '4. Хранение данных и безопасность',
          body:
              'Ваши данные хранятся на защищённых серверах. Мы применяем шифрование отраслевого уровня для передачи и хранения данных. Доступ к личной информации ограничен уполномоченным персоналом. Мы сохраняем ваши данные пока аккаунт активен или пока это требуется для предоставления услуг.',
        ),
        const L10nLegalSection(
          title: '5. Сторонние сервисы',
          body:
              'Мы можем использовать сторонние сервисы для аутентификации (Google Sign-In) и аналитики. Эти сервисы имеют свои политики конфиденциальности. Мы не продаём и не передаём ваши персональные данные третьим лицам в маркетинговых целях.',
        ),
        const L10nLegalSection(
          title: '6. Ваши права',
          body:
              'Вы имеете право:\n\n'
              '• Получить доступ и просмотреть персональные данные, которые мы храним о вас.\n\n'
              '• Запросить исправление неверной информации.\n\n'
              '• Удалить аккаунт и связанные данные в любое время в настройках аккаунта.\n\n'
              '• Отозвать согласие на получение уведомлений в любое время.',
        ),
        const L10nLegalSection(
          title: '7. Связаться с нами',
          body:
              'Если у вас есть вопросы по этой Политике конфиденциальности или обработке данных, свяжитесь с нами по адресу support@smartfin.app.',
        ),
      ];

  @override List<L10nLegalSection> get termsOfServiceSections => [
        const L10nLegalSection(
          title: '1. Принятие условий',
          body:
              'Используя SmartFin, вы соглашаетесь с этими Условиями использования. Если вы не согласны с каким-либо условием, не используйте приложение. Эти условия применяются ко всем пользователям, включая посетителей и зарегистрированных пользователей.',
        ),
        const L10nLegalSection(
          title: '2. Использование сервиса',
          body:
              'SmartFin — платформа для повышения финансовой грамотности в образовательных целях. Контент — уроки, тесты и рекомендации — предназначен для улучшения знаний и не является финансовой консультацией. Перед принятием финансовых решений обращайтесь к профессионалу.',
        ),
        const L10nLegalSection(
          title: '3. Учетные записи пользователей',
          body:
              'Вы несёте ответственность за сохранность учётных данных. Вы соглашаетесь предоставлять точную информацию при регистрации и поддерживать её актуальной. Мы оставляем за собой право приостанавливать или удалять аккаунты, нарушающие условия или занимающиеся мошенничеством.',
        ),
        const L10nLegalSection(
          title: '4. Интеллектуальная собственность',
          body:
              'Весь контент SmartFin — учебные материалы, иллюстрации, логотипы и ПО — является собственностью SmartFin или её поставщиков и защищён законами об интеллектуальной собственности. Запрещено воспроизводить, распространять или создавать производные материалы без письменного разрешения.',
        ),
        const L10nLegalSection(
          title: '5. Запрещённые действия',
          body:
              'Вы соглашаетесь не:\n\n'
              '• Пытаться получить несанкционированный доступ к приложению или его инфраструктуре.\n\n'
              '• Использовать автоматические инструменты для парсинга или извлечения контента.\n\n'
              '• Делиться аккаунтом с другими или создавать аккаунты от имени третьих лиц.\n\n'
              '• Предоставлять ложную или вводящую в заблуждение информацию.',
        ),
        const L10nLegalSection(
          title: '6. Отказы от гарантий',
          body:
              'Приложение предоставляется "как есть" без каких-либо явных или подразумеваемых гарантий. Мы не гарантируем непрерывную или безошибочную работу сервиса или своевременное исправление ошибок. Учебный контент регулярно пересматривается, но может не отражать последние изменения в регулировании или на рынке.',
        ),
        const L10nLegalSection(
          title: '7. Ограничение ответственности',
          body:
              'В максимально допустимой законом мере SmartFin не несёт ответственности за косвенный, случайный или последующий ущерб, возникший из-за использования сервиса или невозможности его использования. Наша общая ответственность не превышает суммы, уплаченной вами (если есть) за доступ к сервису за последние 12 месяцев.',
        ),
        const L10nLegalSection(
          title: '8. Изменения условий',
          body:
              'Мы оставляем за собой право обновлять эти Условия использования в любое время. Изменения будут сообщены через внутриигровое уведомление или обновление даты "Последнее обновление" выше. Продолжение использования приложения после вступления изменений в силу означает ваше согласие с ними.',
        ),
        const L10nLegalSection(
          title: '9. Контакты',
          body:
              'Если у вас есть вопросы по Условиям использования, свяжитесь с нами по адресу support@smartfin.app.',
        ),
      ];
}

// ── Kazakh ────────────────────────────────────────────────────
class AppL10nKk implements AppL10n {
  @override String get navHome => 'Басты';
  @override String get navExplore => 'Тақырыптар';
  @override String get navLearn => 'Үйрену';
  @override String get navExpenses => 'Шығындар';
  @override String get navProfile => 'Профиль';

  @override String get profileTitle => 'Профиль';
  @override String get settingsTitle => 'Параметрлер';
  @override String get sectionAccount => 'АККАУНТ';
  @override String get editProfile => 'Профильді өзгерту';
  @override String get notifications => 'Хабарландырулар';
  @override String get changePassword => 'Құпия сөзді өзгерту';
  @override String get sectionAbout => 'ҚОЛДАНБА ТУРАЛЫ';
  @override String get privacyPolicy => 'Құпиялылық саясаты';
  @override String get termsOfService => 'Қызмет шарттары';
  @override String get appVersion => 'Қолданба нұсқасы';
  @override String get deleteAccount => 'Аккаунтты жою';
  @override String get signOut => 'Шығу';
  @override String get sectionPreferences => 'ПАРАМЕТРЛЕР';
  @override String get darkTheme => 'Күңгірт тақырып';
  @override String get language => 'Тіл';
  @override String get currency => 'Валюта';
  @override String get comingSoon => 'Жақында';
  @override String monthName(int month) {
    const names = [
      'Қаңтар', 'Ақпан', 'Наурыз', 'Сәуір', 'Мамыр', 'Маусым',
      'Шілде', 'Тамыз', 'Қыркүйек', 'Қазан', 'Қараша', 'Желтоқсан'
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }
  @override String get account => 'Аккаунт';
  @override String get appearance => 'Көрініс';
  @override String get enableLessonReminders => 'Сабақ ескертулерін қосу';
  @override String get remindersSubtitle =>
      'Қайта оралу уақыты келгенде хабарландыру алу.';
  @override String get reminderDelay => 'Ескертудің кешігуі';
  @override String minutesLabel(int minutes) => '$minutesм';
  @override String get close => 'Жабу';
  @override String lastUpdated(String date) => 'Соңғы жаңарту: $date';
  @override String get signOutTitle => 'Шығу?';
  @override String get signOutBody => 'Кез келген уақытта қайта кіре аласыз.';
  @override String get signOutConfirm => 'Шығу';
  @override String get deleteAccountTitle => 'Аккаунтты жою?';
  @override String get deleteAccountBody =>
      'Барлық деректеріңіз, жетістіктеріңіз және параметрлеріңіз жойылады. Бұл әрекетті болдырмау мүмкін емес.';
  @override String get deleteAccountConfirm => 'Аккаунтты жою';

  @override String get recommendedForYou => 'Сізге ұсынылады';
  @override String get repeatForYou => 'Қайталауға арналған';
  @override String get newForYou => 'Сіз үшін жаңа';
  @override String get seeAll => 'Барлығы';
  @override String get somethingWentWrong => 'Бірдеңе дұрыс болмады';
  @override String get retry => 'Қайталау';
  @override String get moneyTip => 'Қаржылық кеңес';
  @override String get tapForNext => 'Келесіге түртіңіз';
  @override String get showNextMoneyTip => 'Келесі кеңесті көрсету';
  @override String get continueLearning => 'Оқуды жалғастыру';

  @override String get exploreTopics => 'Тақырыптар';
  @override String get all => 'Барлығы';
  @override String get searchTopics => 'Тақырыптарды іздеу…';
  @override String get done => 'дайын';
  @override String noTopicsMatch(String query) => '"$query" бойынша тақырып жоқ';
  @override String get clearSearch => 'Тазалау';

  @override String levelLabel(TopicLevel level) {
    switch (level) {
      case TopicLevel.beginner: return 'Бастаушы';
      case TopicLevel.intermediate: return 'Орта деңгей';
      case TopicLevel.advanced: return 'Жетілдірілген';
    }
  }

  @override String get lessonSteps => 'Сабақ қадамдары';
  @override String get upNext => 'Келесі';

  @override String stepOf(int current, int total) => '$current / $total қадам';
  @override String get back => 'Артқа';
  @override String get next => 'Келесі';
  @override String get quiz => 'Тест';
  @override String get example => '📌 Мысал';
  @override String get rememberThis => '✅ Есте сақта';
  @override String get couldntLoadLesson => 'Сабақты жүктеу мүмкін болмады';
  @override String get goBack => 'Артқа';
  @override String xpLabel(int xp) => '+$xp XP';

  @override String get knowledgeCheck => 'Білімді тексеру';
  @override String qOf(int q, int total) => 'С$q / $total';
  @override String get correct => 'Дұрыс! 🎉';
  @override String get incorrect => 'Қате';
  @override String get notQuite => 'Дұрыс емес';
  @override String correctAnswer(String answer) => 'Дұрыс жауап: $answer';
  @override String get seeResults => 'Нәтижелер →';
  @override String get continueQuiz => 'Жалғастыру →';
  @override String get check => 'Тексеру';
  @override String get preparingQuiz => 'Тест дайындалуда…';
  @override String get calculatingResults => 'Нәтижелер есептелуде…';

  @override String get lessonComplete => 'Сабақ аяқталды!';
  @override String correctScore(int count, int total) => '$count / $total дұрыс';
  @override String get nextLesson => 'Келесі сабақ →';
  @override String get completeTopic => 'Тақырыпты аяқтау →';
  @override String get backToExplore => 'Тақырыптарға оралу';
  @override String dayStreak(int days) => '$days күндік серия — жалғастыр!';

  @override String get goodMorning => 'Қайырлы таң';
  @override String get goodAfternoon => 'Қайырлы күн';
  @override String get goodEvening => 'Қайырлы кеш';

  @override String xpToLevelLabel(int xp, int level) => '$level-деңгейге $xp';
  @override String get topicsDoneLabel => 'Аяқталған тақырыптар';
  @override String get currentRankLabel => 'Ағымдағы дәреже';
  @override String streakChip(int days) => '🔥 $daysк';

  @override String get statistics => 'СТАТИСТИКА';
  @override String get dayStreakStatLabel => 'Күндік серия';
  @override String get totalXpLabel => 'Жалпы XP';
  @override String get totalTopicsLabel => 'Барлық тақырыптар';
  @override String xpToNextLabel(int xp) => 'Келесіге $xp XP';

  @override String get nameLabel => 'Аты';
  @override String get save => 'Сақтау';
  @override String get yourNameHint => 'Атыңыз';
  @override String get currentPasswordLabel => 'Ағымдағы құпия сөз';
  @override String get newPasswordLabel => 'Жаңа құпия сөз';
  @override String get confirmNewPasswordLabel => 'Жаңа құпия сөзді растаңыз';
  @override String get nameChanged => 'Аты өзгертілді';
  @override String get passwordChanged => 'Құпия сөз өзгертілді';
  @override String get failedToUpdateName => 'Атты өзгерту сәтсіз болды';
  @override String get failedToChangePassword => 'Құпия сөзді өзгерту сәтсіз болды';

  @override String get subtopicDoneLabel => '✅ Дайын';
  @override String get subtopicLockedLabel => '🔒 Алдыңғысын аяқтаңыз';
  @override String completedXpLabel(int xp) => '✅ Аяқталды • ⭐ $xp XP';
  @override String stepsCount(int n) => '$n қадам';
  @override String stepsProgress(int completed, int total) => '$completed / $total қадам';

  @override String get startLesson => 'Сабақты бастау';
  @override String get reviewLesson => 'Сабақты қайталау';
  @override String continueLesson(int step) => 'Жалғастыру — $step-қадам';
  @override String get startTopic => 'Тақырыпты бастау';
  @override String get continueTopic => 'Тақырыпты жалғастыру';
  @override String get takeFinalQuiz => 'Қорытынды тест тапсыру';
  @override String get startLearning => 'Оқуды бастау';

  @override String get stepDone => '✓ Дайын';
  @override String get stepInProgress => '▶ Үстінде';
  @override String get quizPassed => '✓ Өтілді';
  @override String get takeTheQuiz => '▶ Тест тапсыру';
  @override String get quizLabel => '📝 Тест';

  @override String get welcomeBack => 'Қайта оралдыңыз 👋';
  @override String get signInSubtitle => 'Оқуды жалғастыру үшін кіріңіз.';
  @override String get email => 'Эл. пошта';
  @override String get emailHint => 'you@example.com';
  @override String get enterEmail => 'Эл. поштаны енгізіңіз';
  @override String get enterValidEmail => 'Дұрыс адресті енгізіңіз';
  @override String get password => 'Құпия сөз';
  @override String get passwordHint => '••••••••';
  @override String get enterPassword => 'Құпия сөзді енгізіңіз';
  @override String get signInButton => 'Кіру';
  @override String get noAccount => 'Аккаунт жоқ па? ';
  @override String get signUpLink => 'Тіркелу';
  @override String get createAccountTitle => 'Аккаунт жасау 🌱';
  @override String get createAccountSubtitle => 'Қаржылық еркіндікке жолыңызды бастаңыз.';
  @override String get fullName => 'Толық аты';
  @override String get fullNameHint => 'Алексей Иванов';
  @override String get enterName => 'Атыңызды енгізіңіз';
  @override String get passwordHint2 => 'Кем дегенде 5 таңба, 1 сан';
  @override String get enterAPassword => 'Құпия сөзді енгізіңіз';
  @override String get atLeast5Chars => 'Кем дегенде 5 таңба';
  @override String get useAtLeastOneDigit => 'Кем дегенде бір санды пайдаланыңыз';
  @override String get noSpacesOrCommas => 'Бос орын мен үтірсіз';
  @override String get confirmPassword => 'Құпия сөзді растаңыз';
  @override String get passwordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';
  @override String get createAccountButton => 'Аккаунт жасау';
  @override String get alreadyHaveAccount => 'Аккаунт бар ма? ';
  @override String get signInLink => 'Кіру';

  // ── Legal content (KK) ─────────────────────────────────────
  @override List<L10nLegalSection> get privacyPolicySections => [
        const L10nLegalSection(
          title: '1. Кіріспе',
          body:
              'SmartFin ("біз", "біздің", немесе "бізді") сіздің құпиялылығыңызды қорғауға міндеттенеді. '
              'Бұл Құпиялылық саясаты біз қандай деректерді жинаймыз, қалай пайдаланамыз және қорғаймыз туралы түсінік береді.',
        ),
        const L10nLegalSection(
          title: '2. Біз жинайтын ақпарат',
          body:
              'Біз келесі ақпарат түрлерін жинаймыз:\n\n'
              '• Аккаунт туралы ақпарат: тіркеу кезінде берілген аты және электрондық пошта мекенжайы.\n\n'
              '• Оқу деректері: тест нәтижелері, аяқталған тақырыптар және қосымшадағы прогресс.\n\n'
              '• Қолдану деректері: сессия белсенділігі, функциялармен өзара әрекет және құрылғы идентификаторлары тәжірибені жақсарту үшін.',
        ),
        const L10nLegalSection(
          title: '3. Ақпаратыңызды қалай пайдаланамыз',
          body:
              'Сіздің ақпарат мына мақсатта пайдаланылады:\n\n'
              '• Оқу жолын және ұсыныстарды жекелендіру.\n\n'
              '• Прогресті қадағалау және нәтижелер бойынша түсініктеме беру.\n\n'
              '• Сабақ ескертулерін және тиісті хабарламаларды жіберу (тек қосылған болса).\n\n'
              '• Қолданба функцияларын жинақталған, анонимді талдау арқылы жақсарту.',
        ),
        const L10nLegalSection(
          title: '4. Деректерді сақтау және қауіпсіздік',
          body:
              'Сіздің деректеріңіз қауіпсіз серверлерде сақталады. Біз тасымалдау және сақталу кезінде стандартты шифрлауды қолданамыз. Жеке ақпаратқа қол жеткізу тек өкілетті қызметкерлерге шектеледі. Біз деректерді аккаунт белсенді болғанша немесе қызмет көрсету үшін қажетті мерзімге дейін сақтаймыз.',
        ),
        const L10nLegalSection(
          title: '5. Үшінші тарап қызметтері',
          body:
              'Біз аутентификация (Google Sign-In) және аналитика үшін үшінші тарап қызметтерін пайдалануымыз мүмкін. Бұл қызметтер өздерінің құпиялылық саясатына бағынады. Біз сіздің жеке деректеріңізді маркетинг мақсатында сатпаймыз немесе бөліспейміз.',
        ),
        const L10nLegalSection(
          title: '6. Сіздің құқықтарыңыз',
          body:
              'Сізде құқықтар бар:\n\n'
              '• Бізде сақталған жеке деректерге қол жеткізу және оларды қарау.\n\n'
              '• Дұрыс емес ақпаратты түзетуді сұрау.\n\n'
              '• Аккаунтты және байланысты деректерді кез келген уақытта аккаунт параметрлерінен жою.\n\n'
              '• Хабарламаларға рұқсатты кез келген уақытта қайтарып алу.',
        ),
        const L10nLegalSection(
          title: '7. Байланысу',
          body:
              'Құпиялылық саясаты немесе деректерді өңдеу туралы сұрақтарыңыз болса, бізге support@smartfin.app арқылы хабарласыңыз.',
        ),
      ];

  @override List<L10nLegalSection> get termsOfServiceSections => [
        const L10nLegalSection(
          title: '1. Шарттарды қабылдау',
          body:
              'SmartFin-ді пайдалану арқылы сіз осы Қызмет көрсету шарттарына келісесіз. Егер сіз шарттармен келіспесеңіз, қолданбаны пайдаланбаңыз. Бұл шарттар барлық пайдаланушыларға, соның ішінде қонақтар мен тіркелген пайдаланушыларға қолданылады.',
        ),
        const L10nLegalSection(
          title: '2. Қызметті пайдалану',
          body:
              'SmartFin — оқу мақсатындағы қаржылық сауаттылық платформасы. Құрамдастырылған контент — сабақтар, тесттер және ұсыныстар — қаржылық кеңес бермейді. Қаржылық шешім қабылдамас бұрын білікті маманға жүгініңіз.',
        ),
        const L10nLegalSection(
          title: '3. Пайдаланушы аккаунттары',
          body:
              'Сіз есептік жазба ақпаратын құпия сақтауға жауаптысыз. Тіркеу кезінде дәл ақпарат беруіңізге және оны жаңартып тұруыңызға келісесіз. Біз шарттарды бұзған немесе алдаушылық жасаған аккаунттарды тоқтата немесе жоя аламыз.',
        ),
        const L10nLegalSection(
          title: '4. Зияткерлік меншік',
          body:
              'SmartFin-дегі барлық контент — оқу материалдары, иллюстрациялар, логотиптер және бағдарламалық қамтамасыз ету — SmartFin немесе оның жеткізушілерінің меншігі болып табылады және зияткерлік меншік заңдарымен қорғалған. Төмендейінсіз көшіруге, таратуға немесе туынды жұмыстар жасауға тыйым салынады.',
        ),
        const L10nLegalSection(
          title: '5. Тыйым салынған әрекеттер',
          body:
              'Сіз келесі әрекеттерді жасамауға келісесіз:\n\n'
              '• Қол жетімсіз рұқсатсыз қосымшаға кіруге тырысу.\n\n'
              '• Контентті парсинг немесе алу үшін автоматтандырылған құралдарды қолдану.\n\n'
              '• Есептік жазбаны басқалармен бөлісу немесе үшінші тұлғалар атынан есептік жазбалар жасау.\n\n'
              '• Қате немесе адастырушы ақпарат беру.',
        ),
        const L10nLegalSection(
          title: '6. Кепілдіктерден бас тарту',
          body:
              'Қолданба "сол күйінде" ұсынылады, ешқандай көрнекті не жасырын кепілдіктерсіз. Біз қызметтің үзіліссіз немесе қателіксіз болуын немесе қателердің түзетілуін қамтамасыз етпейміз. Оқу мазмұны үнемі қарап шығады, бірақ соңғы нормативтік немесе нарықтық өзгерістерді ескермей қалуы мүмкін.',
        ),
        const L10nLegalSection(
          title: '7. Құқықтық жауап шегі',
          body:
              'Заңмен рұқсат етілген ең толық дәрежеде SmartFin қолданудың немесе қолдана алмаудың салдарынан туындаған жанама, кездейсоқ немесе салдарлы зиян үшін жауап бермейді. Біздің жалпы жауапкершілігіміз соңғы он екі айда қызметке қол жеткізу үшін сіз төлеген сомадан аспайды.',
        ),
        const L10nLegalSection(
          title: '8. Шарттарға өзгерістер енгізу',
          body:
              'Біз осы Қызмет көрсету шарттарына кез келген уақытта өзгерістер енгізу құқығын өзімізде қалдырамыз. Өзгерістер қосымшада хабарланатын немесе "Соңғы жаңарту" күнін жаңарту арқылы жарияланады. Өзгерістер күшіне енгеннен кейін қосымшаны пайдалану — олардың қабылданғанын білдіреді.',
        ),
        const L10nLegalSection(
          title: '9. Байланыс',
          body:
              'Егер Қызмет көрсету шарттары туралы сұрақтарыңыз болса, support@smartfin.app арқылы хабарласыңыз.',
        ),
      ];
}
