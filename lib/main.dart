import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // 1. IMPORT
import 'dart:ui'; // PlatformDispatcher için gerekli
// Modeller ve Router
import 'features/test_results/data/models/test_result_model.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/app_start_listener.dart';
import 'core/notifications/notification_service.dart';

/// 🔥 ARKA PLAN MESAJ HANDLER
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔥 Arka planda mesaj alındı: ${message.messageId}");
}

/// 🔔 EXACT ALARM IZIN ISTEME (Android 13+)
Future<void> requestExactAlarmPermission() async {
  const channel = MethodChannel('quvexai/exact_alarm');
  try {
    await channel.invokeMethod('requestExactAlarmPermission');
  } catch (e) {
    print("⛔ Exact alarm permission error: $e");
  }
}

void main() async {
  // 1. Motoru Hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase Başlat
  await Firebase.initializeApp();
  // --- 2. CRASHLYTICS KURULUMU ---

  // Flutter çerçevesindeki hataları (Widget hataları vb.) Crashlytics'e gönder
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Asenkron hataları (Future hataları vb.) yakalamak için PlatformDispatcher kullan
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 3. İzinler ve Bildirimler
  await requestExactAlarmPermission();
  await FirebaseMessaging.instance.requestPermission();
  await NotificationService.instance.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 4. Hive Başlat (Local DB)
  await Hive.initFlutter();

  // 5. Adaptörleri Tanıt
  Hive.registerAdapter(TestResultModelAdapter());

  // 6. KUTULARI AÇ (Burası Çok Önemli!)
  // Sonuçlar Kutusu
  await Hive.openBox<TestResultModel>('test_results_box');

  // --- EKSİK OLAN KISIM BURASIYDI ---
  // Cevaplar Kutusu (Yarım kalan testler için)
  await Hive.openBox<Map>('test_sessions_box');
  // --- YENİ (MADDE 6): SENKRONİZASYON KUYRUĞU ---
  // İnternet yokken bitirilen testleri burada saklayacağız.
  // Map olarak saklıyoruz: { 'sessionId': {cevaplar...}, ... }
  await Hive.openBox<Map>('sync_queue_box');
  // -----------------------------------

  // 7. Uygulamayı Başlat
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
