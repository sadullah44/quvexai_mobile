// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart';
// DİKKAT: Artık 'test_api_data_source.dart' değil,
// az önce oluşturduğunuz 'mock_test_data_source.dart' import ediliyor:
import 'package:quvexai_mobile/features/tests/data/datasources/mock_test_data_source.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

/// Bu, "Testler Beyni"nin ('TestNotifier') konuşacağı "Aracı"dır (Repository).
class TestRepository {
  // 2. BAĞIMLILIK:
  // Artık 'TestApiDataSource'a değil, 'MockTestDataSource'a bağımlı.
  final MockTestDataSource _apiDataSource;

  // 3. BAĞIMLILIK ENJEKSİYONU (Constructor):
  TestRepository(this._apiDataSource);

  /// [getTests] - Tüm testleri getirir.
  Future<List<TestModel>> getTests() async {
    // 4. İŞİ DELEGE ETME:
    // Talebi 'Mock' Kaynağa iletiyoruz.
    try {
      final tests = await _apiDataSource.getTests();
      return tests;
    } catch (e) {
      rethrow;
    }
  }

  // (Buraya gelecekte getTestDetail(String id) fonksiyonu eklenecek - Madde 2)
}

// --- Riverpod Provider ---

/// "Testler Aracı Fabrikası"
final testRepositoryProvider = Provider<TestRepository>((ref) {
  // 1. ADIM: Bağımlılığı (Sahte Kaynağı) al
  // DİKKAT: Artık 'testApiDataSourceProvider' değil,
  // 'mockTestDataSourceProvider' okunuyor:
  final apiDataSource = ref.read(mockTestDataSourceProvider);

  // 2. ADIM: Aracı'yı (Repository) inşa et
  return TestRepository(apiDataSource);
});
