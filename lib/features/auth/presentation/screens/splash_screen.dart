import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Scaffold: Ekranın temelini (genellikle beyaz sayfa) sağlar.
    return const Scaffold(
      // 2. Center: İçindeki her şeyi (hem yatay hem dikey)
      //    ekranın tam ortasına hizalar.
      body: Center(
        // 3. Column: İçindeki widget'ları alt alta (dikey) dizer.
        child: Column(
          // 4. Bu, Column'ın içindekileri dikey eksende
          //    ortalamasını sağlar (Center ile birlikte tam ortalama yapar).
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // 5. BU SİZİN GÖREVİNİZDİR:
            // Flutter'ın standart 'yükleniyor' animasyonunu ekler.
            // Plandaki "kısa animasyon" budur.
            CircularProgressIndicator(),

            // 6. Animasyon ile yazı arasına 20 piksellik
            //    görünmez bir boşluk (kutu) koyar.
            SizedBox(height: 20),

            // 7. Kullanıcıya bilgi veren metin.
            Text('Yükleniyor...'),

            // 8. Arkadaşınız (Kişi 2) logo dosyasını eklediğinde,
            //    o da bu dosyayı açıp, logonuzu buraya
            //    (muhtemelen CircularProgressIndicator'ın üstüne) ekleyecek.
          ],
        ),
      ),
    );
  }
}
