import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 1. Gerekli Importlar
// Modeller ve Router
import 'features/test_results/data/models/test_result_model.dart';
import 'core/router/app_router.dart';
// Tema Dosyası
import 'core/theme/app_theme.dart';

void main() async {
  // 1. Flutter motorunu hazırla (Bu EN BAŞTA olmalı)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive'ı (Local DB) başlat
  await Hive.initFlutter();

  // 3. Tercümanı (Adapter) tanıt
  // (Test sonuçlarını kaydedebilmek için generated adapter'ı bağlıyoruz)
  // Eğer 'TestResultModelAdapter' bulunamıyor hatası alırsanız:
  // 'dart run build_runner build' komutunu çalıştırdığınızdan emin olun.
  Hive.registerAdapter(TestResultModelAdapter());

  // 4. Kutuyu aç (Veritabanı dosyası)
  // Uygulama boyunca kullanılacak test sonuçları kutusunu açıyoruz.
  await Hive.openBox<TestResultModel>('test_results_box');

  // 5. Uygulamayı başlat
  runApp(
    // Tüm uygulamayı Riverpod "Ana Şalteri" ile sarmalıyoruz
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // 6. Router Yapılandırması (GoRouter)
      routerConfig: AppRouter.router,

      // Debug yazısını kaldır
      debugShowCheckedModeBanner: false,
      title: 'QuvexAI',

      // 7. Tema Yapılandırması
      // (Oluşturduğumuz modern temayı buraya bağlıyoruz)
      theme: AppTheme.lightTheme,

      // (Karanlık mod için ileride darkTheme de eklenebilir)
      // Şimdilik sadece light tema kullanıyoruz.
      themeMode: ThemeMode.light,
    );
  }
}
