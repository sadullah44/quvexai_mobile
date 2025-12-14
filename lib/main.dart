import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';
import 'features/test_results/data/models/test_result_model.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/app_start_listener.dart';
import 'core/notifications/notification_service.dart';

/// 🔥 ARKA PLAN MESAJ HANDLER
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔥 Arka planda mesaj alındı: ${message.messageId}");
}

/// 🔔 EXACT ALARM IZIN ISTEME (Android 13+)
Future<void> requestExactAlarmPermission() async {
  const channel = MethodChannel('quvexai/exact_alarm');
  try {
    await channel.invokeMethod('requestExactAlarmPermission');
  } catch (e) {
    debugPrint("⛔ Exact alarm permission error: $e");
  }
}

void main() async {
  // 1. Motoru Hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase Başlat
  await Firebase.initializeApp();

  // 3. Crashlytics Kurulumu
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 4. İzinler ve Bildirimler
  await requestExactAlarmPermission();

  // 🔥 YENİ: Local notifications init (iOS izinleri dahil)
  await NotificationService.instance.init();

  // 🔥 YENİ: Bildirim izinlerini iste
  final notificationGranted = await NotificationService.instance
      .requestAllPermissions();
  if (!notificationGranted) {
    debugPrint("⚠️ Bildirim izni verilmedi. Kullanıcı ayarlardan açabilir.");
  }

  // Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 5. Hive Başlat
  await Hive.initFlutter();

  // 6. Adaptörleri Tanıt
  Hive.registerAdapter(TestResultModelAdapter());

  // 7. Kutuları Aç
  await Hive.openBox<TestResultModel>('test_results_box');
  await Hive.openBox<Map>('test_sessions_box');
  await Hive.openBox<Map>('sync_queue_box');

  debugPrint("✅ Uygulama başlatıldı");

  // 8. Uygulamayı Başlat
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStartListener(
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        title: 'QuvexAI',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
      ),
    );
  }
}
