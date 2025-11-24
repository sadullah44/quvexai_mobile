import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Modeller ve Router
import 'features/test_results/data/models/test_result_model.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/app_start_listener.dart';

/// 🔥 ARKA PLAN MESAJ HANDLER
/// Mutlaka top-level olacak (class içinde değil, main dışında)
/// VE @pragma('vm:entry-point') ile işaretlenecek
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔥 [BACKGROUND] Bildirim alındı:");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("DATA: ${message.data}");
  await Firebase.initializeApp();
  print("🔥 Arka planda mesaj alındı: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlat
  await Firebase.initializeApp();

  // Arka plan mesaj handler kaydı
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Hive başlat
  await Hive.initFlutter();
  Hive.registerAdapter(TestResultModelAdapter());
  await Hive.openBox<TestResultModel>('test_results_box');

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
