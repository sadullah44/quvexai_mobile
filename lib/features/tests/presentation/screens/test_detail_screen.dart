import 'package:flutter/material.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart'; // 1. "Tercümanımızı" (Kargo Tipi) import etmeliyiz

/// Bu ekran, 'TestListScreen'den "kargo" ('extra') olarak gönderilen
/// 'TestModel'i alır ve detaylarını gösterir.
class TestDetailScreen extends StatelessWidget {
  // 2. "Kargoyu" ('extra: test') almak için bir alan tanımlıyoruz.
  final TestModel test;

  // 1. 'TestModel'i constructor'da (kurucuda) zorunlu olarak istiyoruz.
  const TestDetailScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. App Bar'da testin adını gösteriyoruz
      appBar: AppBar(title: Text(test.name)),

      // 4. Gövdede (body) testin diğer detaylarını gösteriyoruz
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kategori: ${test.category}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Zorluk: ${test.difficulty}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "Tahmini Süre: ${test.estimatedTimeMins} dakika",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 40),

            // 5. 'TestModel'imizden (ve 'test_list.json'dan) gelen
            //    'description' alanını gösteriyoruz.
            Text(
              test.description ?? 'Bu test için açıklama bulunamadı.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Spacer(), // Kalan boşluğu doldurarak butonu en alta iter
            // 6. PLANIMIZDAKİ (Madde 2) "Teste Başla" Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Teste Başla',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // TODO: MADDE 3
                  // Burası, 'Test Çözme' ekranına
                  // yönlendirme yapacağımız yer.
                  // context.push('/test-session/${test.id}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
