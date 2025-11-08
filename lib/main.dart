import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Kendi proje yoluna göre bu import'u kontrol et:
import 'features/test_results/data/models/test_result_model.dart';
import 'core/router/app_router.dart'; // Router'ın burada olduğunu varsayıyorum

void main() async {
  // 1. Flutter motorunu hazırla (Bu EN BAŞTA olmalı)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive'ı uyandır (BAŞLAT) - Bu satır EKSİK veya YANLIŞ YERDE olabilir
  await Hive.initFlutter();

  // 3. Tercümanı (Adapter) tanıt
  Hive.registerAdapter(TestResultModelAdapter());

  // 4. Kutuyu aç (Hive uyandıktan SONRA yapılmalı)
  await Hive.openBox<TestResultModel>('test_results_box');

  // 5. Uygulamayı başlat
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Router yapılandırmanızı buraya bağlayın
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'QuvexAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
