import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

/// Bu sınıf artık GERÇEK API yerine uydurma (mock) veriler döndürüyor.
class TestApiDataSource {
  TestApiDataSource();

  /// Uydurma test listesi
  Future<List<TestModel>> getTests() async {
    // 1 saniyelik gecikme ekleyelim (gerçek API hissi için)
    await Future.delayed(const Duration(seconds: 1));

    // Mock test listemiz
    final mockTests = [
      TestModel(
        id: '1',
        name: 'Flutter Başlangıç Testi',
        category: 'Mobil Geliştirme',
        difficulty: 'Kolay',
        estimatedTimeMins: 10,
        description:
            'Bu test, Flutter temel bilgilerini ölçmek için hazırlanmıştır.',
      ),
      TestModel(
        id: '2',
        name: 'Veri Yapıları ve Algoritmalar',
        category: 'Bilgisayar Bilimi',
        difficulty: 'Orta',
        estimatedTimeMins: 20,
        description:
            'Bu test, algoritma mantığı ve veri yapısı kavramlarını ölçer.',
      ),
      TestModel(
        id: '3',
        name: 'Yapay Zeka Temelleri',
        category: 'AI & ML',
        difficulty: 'Zor',
        estimatedTimeMins: 25,
        description:
            'Bu test, yapay zeka temelleri ve makine öğrenmesi prensiplerini kapsar.',
      ),
    ];

    return mockTests;
  }
}

/// --- Riverpod Provider ---
/// Bu provider, "mock" veri kaynağını Riverpod'a tanıtır.
final testApiDataSourceProvider = Provider<TestApiDataSource>((ref) {
  return TestApiDataSource();
});
