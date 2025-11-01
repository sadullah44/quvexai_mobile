import 'package:flutter/material.dart';
import 'package:quvexai_mobile/core/theme/app_theme.dart';
import 'package:quvexai_mobile/core/router/app_router.dart'; // 1. Kendi haritamızı içe aktarıyoruz
import 'package:flutter_riverpod/flutter_riverpod.dart';

// YENİ HALİ (DOĞRU)
void main() {
  // Riverpod'ı (ana şalteri) tüm uygulamanın
  // etrafına sararak çalıştırıyoruz.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 3. MyApp, uygulamamızın kök widget'ıdır
  @override
  Widget build(BuildContext context) {
    // 4. MaterialApp.router kullanarak uygulamayı inşa ediyoruz
    return MaterialApp.router(
      title: 'QUVEXAI Envanter',

      // 5. DEBUG yazılı şeridi kaldırıyoruz
      debugShowCheckedModeBanner: false,

      // 6. EN KRİTİK ADIM:
      // Uygulamamıza "Navigasyon haritan budur" diyoruz.
      routerConfig: AppRouter.router,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
