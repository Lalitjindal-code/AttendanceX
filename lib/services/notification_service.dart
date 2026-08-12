import 'package:attendify/features/notifications/models/scheduled_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class NotificationService {
  static NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  @visibleForTesting
  static void setInstanceForTesting(NotificationService testInstance) {
    _instance = testInstance;
  }

  factory NotificationService() {
    return instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimeZone =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Handle payload here if necessary
      },
    );

    _isInitialized = true;
  }

  Future<bool?> requestPermissions() async {
    if (Platform.isIOS) {
      return await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final notificationsGranted =
          await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();

      return notificationsGranted;
    }
    return false;
  }

  /// Synchronizes currently scheduled notifications with [desiredNotifications].
  /// Cancels obsolete notifications and schedules new ones.
  Future<void> syncNotifications(
      List<ScheduledNotification> desiredNotifications) async {
    if (!_isInitialized) await init();

    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    final desiredMap = {for (var n in desiredNotifications) n.id: n};
    final pendingMap = {for (var p in pendingNotifications) p.id: p};

    // 1. Cancel obsolete notifications
    for (final pendingId in pendingMap.keys) {
      if (!desiredMap.containsKey(pendingId)) {
        await _flutterLocalNotificationsPlugin.cancel(pendingId);
      }
    }

    // 2. Schedule new or modified notifications
    // We consider it "modified" if the body or title has changed.
    // However, flutter_local_notifications doesn't expose scheduled time easily in pending requests.
    // So if the ID is already there, we might assume it's correctly scheduled.
    // Wait, the user said "schedule only new or modified notifications".
    // We can cancel and reschedule if we want to update it, but we can't easily check the scheduled time of a pending notification.
    // But since our IDs are deterministic (derived from scheduleId and date), the time and content for a given ID are effectively constant!
    // If the lecture time changes, the `ScheduledNotification` ID will still be the same?
    // Yes, `_generateLectureId(schedule.id, targetDate)`. If `schedule.startTime` changes, the ID is unchanged, but we should reschedule it.
    // Without being able to compare the pending time/content, the safest approach to update an existing ID is to just check if it's in pending. If we MUST update it (e.g. settings changed), maybe it's better to cancel and reschedule.
    // Let's optimize: if an ID is in pending, we assume it's correct UNLESS we need to force an update.
    // Actually, `pendingNotifications` gives us `title`, `body`, and `payload`.
    // We can compare `title` and `body`.
    for (final desired in desiredNotifications) {
      final pending = pendingMap[desired.id];
      bool needsScheduling = false;

      if (pending == null) {
        needsScheduling = true;
      } else if (pending.title != desired.title ||
          pending.body != desired.body ||
          pending.payload != desired.payload) {
        needsScheduling = true;
      }

      if (needsScheduling) {
        final tzDate = tz.TZDateTime.from(desired.scheduledDate, tz.local);

        try {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            desired.id,
            desired.title,
            desired.body,
            tzDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'Attendify_channel',
                'Reminders',
                channelDescription: 'Lecture and attendance reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: desired.payload,
          );
        } catch (e) {
          // Fallback to inexact if exact alarm permission is denied
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            desired.id,
            desired.title,
            desired.body,
            tzDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'Attendify_channel',
                'Reminders',
                channelDescription: 'Lecture and attendance reminders',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: desired.payload,
          );
        }
      }
    }
  }

  /// Returns a list of currently pending notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await init();
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Shows an immediate test notification.
  Future<void> showTestNotification() async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Used for testing if notifications work',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification 🚀',
      'If you see this, notifications are working properly!',
      platformChannelSpecifics,
      payload: 'test_payload',
    );
  }

  /// Cancels a specific pending notification by ID.
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await init();
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancels all pending and active notifications.
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
