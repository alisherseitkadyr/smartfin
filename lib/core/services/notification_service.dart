import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';
import 'safe_storage.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final SafeStorage _storage = const SafeStorage();

  Future<void>? _initFuture;
  bool _timeZonesInitialized = false;
  bool _initialized = false;
  bool _notificationsEnabled = true;
  int _reminderDelayMinutes = 1;

  static const _kNotificationEnabled = 'notification_enabled';
  static const _kNotificationDelayMinutes = 'notification_delay_minutes';
  static const _continueTopicId = 1001;
  static const _takeQuizId = 1002;
  static const _debugId = 9999;
  static const _settingsTimeout = Duration(seconds: 2);
  static const _pluginTimeout = Duration(seconds: 4);

  bool get enabled => _notificationsEnabled;
  int get reminderDelayMinutes => _reminderDelayMinutes;

  Future<void> init() {
    if (_initialized) return Future.value();
    final existing = _initFuture;
    if (existing != null) return existing;

    final future = _init();
    _initFuture = future;
    return future;
  }

  Future<void> _init() async {
    try {
      await _loadSettings().timeout(_settingsTimeout);
      if (kIsWeb) {
        _initialized = true;
        return;
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initialized = await _plugin
          .initialize(
            InitializationSettings(android: androidSettings, iOS: iosSettings),
            onDidReceiveNotificationResponse: _onNotificationResponse,
            onDidReceiveBackgroundNotificationResponse:
                notificationTapBackground,
          )
          .timeout(_pluginTimeout);

      _initialized = initialized != false;
      if (!_initialized) return;

      _initializeTimeZones();

      final launchDetails = await _plugin
          .getNotificationAppLaunchDetails()
          .timeout(_pluginTimeout, onTimeout: () => null);
      final launchResponse = launchDetails?.notificationResponse;
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchResponse != null) {
        Future<void>.delayed(
          Duration.zero,
          () => _onNotificationResponse(launchResponse),
        );
      }
    } catch (error) {
      _report('initialize', error);
    } finally {
      if (!_initialized) _initFuture = null;
    }
  }

  Future<void> _loadSettings() async {
    final enabled = await _storage.read(key: _kNotificationEnabled);
    _notificationsEnabled = enabled != 'false';

    final delayText = await _storage.read(key: _kNotificationDelayMinutes);
    _reminderDelayMinutes = int.tryParse(delayText ?? '') ?? 1;
  }

  @pragma('vm:entry-point')
  void handleBackgroundNotificationResponse(NotificationResponse response) {
    _onNotificationResponse(response);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    await init();
    if (!_initialized) return false;
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidImpl?.requestPermission() ?? true;
    debugPrint('NotificationService: POST_NOTIFICATIONS granted=$granted');
    return granted;
  }

  Future<void> setEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storage.write(
      key: _kNotificationEnabled,
      value: enabled ? 'true' : 'false',
    );
    if (enabled) {
      await requestPermissions();
    } else {
      await cancelAll();
    }
  }

  Future<void> setDelayMinutes(int minutes) async {
    _reminderDelayMinutes = minutes;
    await _storage.write(
      key: _kNotificationDelayMinutes,
      value: minutes.toString(),
    );
  }

  Future<void> scheduleContinueTopic({
    required String topicId,
    String? subtopicId,
    String title = 'Continue your lesson',
    String body = 'Come back and finish your topic when you are ready.',
  }) async {
    await _scheduleReminder(
      id: _continueTopicId,
      action: 'continue_topic',
      topicId: topicId,
      subtopicId: subtopicId,
      title: title,
      body: body,
    );
  }

  Future<void> scheduleTakeQuiz({
    required String topicId,
    String? subtopicId,
    String title = 'Ready for a quiz?',
    String body = 'Take your quiz now to keep your progress moving.',
  }) async {
    await _scheduleReminder(
      id: _takeQuizId,
      action: 'take_quiz',
      topicId: topicId,
      subtopicId: subtopicId,
      title: title,
      body: body,
    );
  }

  // ── Debug helpers (only meaningful in debug builds) ────────────────

  Future<void> debugShowNow() async {
    if (kIsWeb) return;
    try {
      await init();
      if (!_initialized) {
        debugPrint('NotificationService: not initialized — cannot show');
        return;
      }
      await _plugin.show(
        _debugId,
        'Finish your lesson',
        'Come back and complete your topic.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'afine_reminder_channel',
            'Lesson reminders',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      debugPrint('NotificationService: show() fired');
    } catch (error) {
      debugPrint('NotificationService debugShowNow failed: $error');
    }
  }

  Future<void> debugStartMinuteRepeating() async {
    if (kIsWeb) return;
    try {
      await init();
      if (!_initialized) {
        debugPrint('NotificationService: not initialized — cannot schedule');
        return;
      }
      await _plugin.periodicallyShow(
        _debugId,
        'Finish your lesson',
        'Come back and complete your topic.',
        RepeatInterval.everyMinute,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'afine_reminder_channel',
            'Lesson reminders',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('NotificationService: repeating every minute, id=$_debugId');
    } catch (error) {
      debugPrint('NotificationService debugStartMinuteRepeating failed: $error');
    }
  }

  Future<void> debugStop() async {
    if (kIsWeb) return;
    await _plugin.cancel(_debugId);
    debugPrint('NotificationService: debug notification cancelled');
  }

  Future<Map<String, String>> debugStatus() async {
    if (kIsWeb) return {'platform': 'web'};
    await init();
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await androidImpl?.canScheduleExactNotifications();
    final permGranted = await androidImpl?.areNotificationsEnabled();
    final pending = await _plugin.pendingNotificationRequests();
    return {
      'initialized': '$_initialized',
      'permission': '${permGranted ?? "n/a"}',
      'canExact': '${canExact ?? "n/a"}',
      'pending': '${pending.length}',
    };
  }

  // ────────────────────────────────────────────────────────────────────

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await init();
      if (!_initialized) return;
      await _plugin.cancelAll().timeout(_pluginTimeout);
    } catch (error) {
      _report('cancelAll', error);
    }
  }

  Future<void> cancelTopicReminders() async {
    if (kIsWeb) return;
    try {
      await init();
      if (!_initialized) return;
      await _plugin.cancel(_continueTopicId).timeout(_pluginTimeout);
      await _plugin.cancel(_takeQuizId).timeout(_pluginTimeout);
    } catch (error) {
      _report('cancelTopicReminders', error);
    }
  }

  String _encodePayload(String action, String topicId, String? subtopicId) {
    return [
      Uri.encodeComponent(action),
      Uri.encodeComponent(topicId),
      Uri.encodeComponent(subtopicId ?? ''),
    ].join('|');
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split('|');
    if (parts.length < 2) return;

    final topicId = Uri.decodeComponent(parts[1]);
    final subtopicId = parts.length > 2 && parts[2].isNotEmpty
        ? Uri.decodeComponent(parts[2])
        : null;
    final route = subtopicId == null
        ? '/learn/lesson/$topicId'
        : '/learn/lesson/$topicId/$subtopicId';

    appRouter.go(route);
  }

  Future<void> _scheduleReminder({
    required int id,
    required String action,
    required String topicId,
    String? subtopicId,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!_notificationsEnabled) {
      debugPrint('NotificationService: skipped — notifications disabled');
      return;
    }

    try {
      await init();
      if (!_initialized) {
        debugPrint('NotificationService: skipped — not initialized');
        return;
      }

      final payload = _encodePayload(action, topicId, subtopicId);
      debugPrint('NotificationService: scheduling id=$id in ${_reminderDelayMinutes}m');
      await _scheduleNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        delay: Duration(minutes: _reminderDelayMinutes),
      );
      debugPrint('NotificationService: scheduled id=$id ✓');
    } catch (error) {
      debugPrint('NotificationService scheduleReminder failed: $error');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required Duration delay,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime.now().add(delay),
      tz.local,
    );
    final androidDetails = AndroidNotificationDetails(
      'afine_reminder_channel',
      'Lesson reminders',
      channelDescription: 'Reminders to continue lessons or take quizzes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    final iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void _initializeTimeZones() {
    if (_timeZonesInitialized) return;
    tz_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  void _report(String operation, Object error) {
    if (!kDebugMode) return;
    debugPrint('NotificationService $operation failed: $error');
  }
}
