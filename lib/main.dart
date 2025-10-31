import 'package:flutter/material.dart';
import 'package:quvexai_mobile/core/router/app_router.dart'; // 1. Kendi haritamızı içe aktarıyoruz

void main() {
  // 2. Uygulamayı başlatan ana fonksiyon
  runApp(const MyApp());
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

      // 7. Tema (Görünüm) ayarları buraya gelecek
      // theme: ...,
      // darkTheme: ...,
    );
  }
}
