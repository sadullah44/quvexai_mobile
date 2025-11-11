import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. DOĞRU İMPORT: "Beyin"i ('testProvider') import ediyoruz
import 'package:quvexai_mobile/features/tests/presentation/providers/test_provider.dart';
// 2. MODELİ import ediyoruz (Kartta kullanmak için)

// 3. 'ConsumerStatefulWidget'a dönüştürdük.
//    - 'Consumer': 'ref' (Riverpod) aracını kullanmak için.
//    - 'Stateful': 'initState' (ekran ilk açıldığında) metodunu
//                  kullanarak veriyi BİR KEZ çekme komutu vermek için.
class TestListScreen extends ConsumerStatefulWidget {
  const TestListScreen({super.key});

  @override
  ConsumerState<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends ConsumerState<TestListScreen> {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Test Listesi')),

      // DURUM A: Yükleniyor mu?
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          // DURUM B: Hata var mı?
          : state.errorMessage != null
          ? Center(
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
            )
          // DURUM C: Veri boş mu?
          : state.tests.isEmpty
          ? const Center(
              child: Text(
                'Gösterilecek test bulunamadı.',
                style: TextStyle(fontSize: 18),
              ),
            )
          // DURUM D: Başarılı (Veri geldi)
          : ListView.builder(
              itemCount: state.tests.length,
              itemBuilder: (context, index) {
                final test = state.tests[index];
                // Arkadaşınızın (Kişi 2) yaptığı arayüz kodunun
                // (Card, ListTile, onTap) aynısını kullanıyoruz
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(test.name),
                    subtitle: Text(
                      '${test.category} • ${test.difficulty} • ${test.estimatedTimeMins} dk',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () {
                      context.push('/tests/${test.id}', extra: test);
                    },
                  ),
                );
              },
            ),
    );
  }
}
