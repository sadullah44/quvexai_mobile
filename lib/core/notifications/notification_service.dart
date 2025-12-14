import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';

  /// 🔹 Notification servisini başlat
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 Notification tapped! Payload: ${response.payload}");
      },
    );

    // Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    debugPrint("✅ Local Notifications initialized");
  }

  /// 🔥 İzin durumunu kontrol et ve gerekirse iste
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// 🔥 Firebase Cloud Messaging izinlerini iste
  Future<bool> requestFirebasePermissions() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// 🔥 Tüm izinleri iste (Local + Firebase)
  Future<bool> requestAllPermissions() async {
    final localGranted = await requestPermissions();
    final firebaseGranted = await requestFirebasePermissions();
    return localGranted && firebaseGranted;
  }

  /// 🔥 Bildirim ayarını kontrol et
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  /// 🔥 Bildirimleri aç/kapa
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);

    if (!enabled) {
      await cancelAllNotifications();
      debugPrint("🔕 Bildirimler kapatıldı");
    } else {
      // Günlük hatırlatma ayarı açıksa yeniden planla
      final reminderEnabled = await isDailyReminderEnabled();
      if (reminderEnabled) {
        await scheduleDailyTestReminder();
      }
      debugPrint("🔔 Bildirimler açıldı");
    }
  }

  /// 🔥 Günlük hatırlatma ayarını kontrol et
  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderEnabledKey) ?? true;
  }

  /// 🔥 Günlük hatırlatmayı aç/kapa
  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, enabled);

    if (enabled) {
      await scheduleDailyTestReminder();
      debugPrint("✅ Günlük hatırlatma aktif");
    } else {
      await _notifications.cancel(1); // Daily reminder ID = 1
      debugPrint("🔕 Günlük hatırlatma kapatıldı");
    }
  }

  /// 🔥 Genel bildirim gösterme fonksiyonu
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    final enabled = await areNotificationsEnabled();
    if (!enabled) {
      debugPrint("🔕 Bildirimler kapalı, gösterilmedi: $title");
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// 🔥 Test sonucu hazır bildirimi
  Future<void> showTestResultReadyNotification({
    required String testName,
    String? sessionId,
  }) async {
    await showNotification(
      id: 2,
      title: "Test Sonucun Hazır! 🎉",
      body: "$testName testinin sonuçlarını görebilirsin.",
      payload: sessionId != null ? "test_result:$sessionId" : null,
    );
  }

  /// 🔥 Offline → Online sync bildirimi
  Future<void> showSyncCompletedNotification({
    required int successCount,
    required int totalCount,
  }) async {
    if (successCount == totalCount) {
      await showNotification(
        id: 3,
        title: "Senkronizasyon Tamamlandı ✅",
        body: "$successCount test başarıyla gönderildi.",
        payload: "sync_completed",
      );
    } else {
      await showNotification(
        id: 3,
        title: "Senkronizasyon Tamamlandı ⚠️",
        body:
            "$successCount/$totalCount test gönderildi. ${totalCount - successCount} test başarısız.",
        payload: "sync_completed",
      );
    }
  }

  /// 🔥 Günlük test hatırlatma bildirimi
  Future<void> scheduleDailyTestReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    final enabled = await areNotificationsEnabled();
    final reminderEnabled = await isDailyReminderEnabled();

    if (!enabled || !reminderEnabled) {
      debugPrint("🔕 Hatırlatma kapalı, planlanmadı");
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Eğer saat geçtiyse, yarına kaydır
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1, // Daily reminder ID
      "Bugün 1 test çözmeyi unutma",
      "Ruh sağlığın için bugün en az 1 test çöz.",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "daily_test_reminder",
    );

    debugPrint("✅ Günlük test hatırlatma planlandı: $scheduledDate");
  }

  /// 🔥 Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint("🗑️ Tüm bildirimler iptal edildi");
  }
}
