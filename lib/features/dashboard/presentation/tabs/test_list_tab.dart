import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. "Testler Beyni"ni (Kişi 1'in yaptığı) import et
import 'package:quvexai_mobile/features/tests/presentation/providers/test_provider.dart';
// 2. "Test Kartı" arayüzünü (Kişi 2'nin yaptığı) import et
import 'package:quvexai_mobile/features/tests/presentation/widgets/test_card.dart';

// 3. 'ConsumerStatefulWidget'a dönüştürdük.
//    - 'Consumer': 'ref' (Riverpod) aracını kullanmak için.
//    - 'Stateful': 'initState' (ekran ilk açıldığında) metodunu
//                  kullanarak veriyi BİR KEZ çekme komutu vermek için.
class TestlerTab extends ConsumerStatefulWidget {
  const TestlerTab({super.key});

  @override
  ConsumerState<TestlerTab> createState() => _TestlerTabState();
}

class _TestlerTabState extends ConsumerState<TestlerTab> {
  @override
  void initState() {
    super.initState();
    // 4. EKRAN İLK AÇILDIĞINDA (BİR KEZ) TETİKLEME:
    // 'initState' içinde 'ref.read' kullanmanın güvenli yolu:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // "Testler Beyni"ne ('testProvider') ulaş ve
      // 'fetchTests' (testleri çek) fonksiyonunu tetikle.
      ref.read(testProvider.notifier).fetchTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 5. "TESTLER GÖSTERGE PANELİNİ" İZLE ('watch'):
    // 'testProvider'daki 'TestState'i (isLoading, tests, errorMessage)
    // sürekli izle. State değiştikçe bu 'build' metodu yeniden çalışır.
    final state = ref.watch(testProvider);

    // 6. DURUMA (STATE) GÖRE ARAYÜZÜ (UI) ÇİZ:

    // DURUM A: Yükleniyor mu? (Plan: Skeleton loader)
    if (state.isLoading) {
      // (Basit bir 'skeleton' yerine şimdilik standart 'spinner' kullanalım)
      return const Center(child: CircularProgressIndicator());
    }

    // DURUM B: Hata var mı? (Plan: error state)
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Testler yüklenemedi: ${state.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              onPressed: () {
                // Hata durumunda, "Beyin"deki 'fetchTests'
                // fonksiyonunu tekrar tetikle.
                ref.read(testProvider.notifier).fetchTests();
              },
            ),
          ],
        ),
      );
    }

    // DURUM C: Veri boş mu? (API'den boş liste gelirse)
    if (state.tests.isEmpty) {
      return const Center(
        child: Text(
          'Gösterilecek test bulunamadı.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // DURUM D: Başarılı (Veri geldi)
    // (Plan: Test kart tasarımı)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.tests.length, // "Beyin"deki listedeki ürün sayısı kadar
      itemBuilder: (context, index) {
        final test = state.tests[index]; // O anki testi al

        // 7. Arkadaşınızın (Kişi 2) yaptığı 'TestCard' widget'ını kullan
        return TestCard(test: test);
      },
    );
  }
}
