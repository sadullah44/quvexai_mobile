import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// G3'te yazdığımız "Motor Beyni"ni import ediyoruz
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

// 1. Ekranı 'Stateless'tan 'ConsumerWidget'a dönüştürdük
//    (Çünkü 'ref' aracına ihtiyacımız var)
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Çıkış yaptığımızda (token=null) Login'e geri dönmek
    //    için 'ref.listen' kullanıyoruz
    // --- GÜNCELLEME BAŞLANGICI ---
    // 'logout' olayının *anını* yakalamak için daha sağlam bir kontrol ekliyoruz.
    ref.listen(authProvider, (previous, next) {
      // 'previous' (önceki durum) null değilse ve bir token'ı varsa
      // (yani 'giriş yapmış' durumdayken)
      final wasLoggedIn = previous != null && previous.token != null;

      // 'next' (yeni durum) token'ı null ise
      // (yani 'çıkış yapmış' duruma geçtiyse)
      final isLoggedOut = next.token == null;

      // Eğer "giriş yapmış" durumdan "çıkış yapmış" duruma bir *GEÇİŞ* olduysa:
      if (wasLoggedIn && isLoggedOut) {
        // Token ışığı söndü! Login'e git.
        context.go('/login');
      }
    });
    // --- GÜNCELLEME SONU ---

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ana Ekran - Başarıyla Giriş Yaptınız!'),
            const SizedBox(height: 40),

            // 3. GEÇİCİ ÇIKIŞ YAP BUTONU
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Çıkış Yap (TEST)'),
              onPressed: () {
                // 4. G3'te yazdığımız 'logout' mantığını çağırıyoruz
                //    Bu, token'ı hafızadan siler ve state'i sıfırlar.
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
