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
  @override String get rememberThis => '✅ Remember this';
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
  @override String get comingSoon => 'Скоро';
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
}
