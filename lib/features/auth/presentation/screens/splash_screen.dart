// 1. Yeni importlar
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 2. Gerekli olacak importları şimdiden ekleyelim:
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart'; // G3'te yazdığımız

// 3. Sınıfı 'Stateless'tan 'ConsumerStatefulWidget'a dönüştürdük
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

// 4. Bu, 'State' (Durum) sınıfıdır. Tüm mantık burada yaşar.
class _SplashScreenState extends ConsumerState<SplashScreen> {
  // 5. Ekran ilk yüklendiğinde (build'den bile önce) çalışan metot
  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz "Token kontrol" işini başlat
    // Not: initState içinde 'await' kullanamayız veya 'ref.read'
    //      güvenli olmayabilir, bu yüzden ayrı bir fonksiyona
    //      (WidgetsBinding) yönlendirmek daha güvenlidir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  // 6. ASIL MANTIK BURADA OLACAK (Şimdilik boş)
  // ASIL MANTIK: GÜN 3'te yazılan servisleri kullanma
  Future<void> _checkAuthStatus() async {
    // 1. Planda belirtildiği gibi, logo/animasyon görünsün diye
    //    kasıtlı bir gecikme ekliyoruz. Bu, UI/UX için güzel bir dokunuştur.
    await Future.delayed(const Duration(seconds: 2));

    // 2. GÜN 3 (GÖREV 4) BAĞLANTISI:
    //    Riverpod'ın 'ref' aracını kullanarak "Depolama Fabrikası"ndan
    //    'StorageService' uzmanını istiyoruz ('read') ve
    //    'readToken()' fonksiyonunu çağırıyoruz.
    //    Not: 'ref' bu sınıfta ('ConsumerState') mevcuttur.
    final token = await ref.read(storageServiceProvider).readToken();

    // 3. 'mounted' KONTROLÜ (ÇOK ÖNEMLİ):
    //    'await' (bekleme) işlemi (2 saniye + token okuma) bittiğinde,
    //    kullanıcı belki de uygulamayı çoktan kapatmıştır.
    //    Eğer widget (bu ekran) artık ekranda değilse (mounted == false)
    //    'context' üzerinden yönlendirme yapmaya çalışmak hataya neden olur.
    //    Bu kontrol, "Hala ekrandaysam yönlendir" diyerek uygulamayı korur.
    if (!mounted) return;

    // 4. YÖNLENDİRME MANTIĞI:
    if (token != null) {
      // TOKEN VAR (Kullanıcı daha önce giriş yapmış):
      // 'context.go' kullanarak '/dashboard' rotasına git.
      // 'go' (git), '/login' yolunu geçmişten siler.
      context.go('/dashboard');
    } else {
      // TOKEN YOK (İlk giriş veya 'logout' yapmış):
      // '/login' rotasına git.
      context.go('/login');
    }
  }

  // 7. Arayüz (UI) kodu - Bu G2'den bildiğiniz kodun aynısı
  @override
  Widget build(BuildContext context) {
    // Bu kod değişmedi. Sadece 'build' metodu artık
    // 'State' sınıfının içinde.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Yükleniyor...'),
          ],
        ),
      ),
    );
  }
}
