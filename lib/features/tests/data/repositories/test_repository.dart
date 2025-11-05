// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:quvexai_mobile/features/tests/data/datasources/test_api_data_source.dart'; // "Veri Kaynağımız"
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart'; // "JSON Tercümanımız"

/// Bu, "Testler Beyni"nin ('TestNotifier') konuşacağı "Aracı"dır (Repository).
/// Görevi, "Beyin"den gelen talebi "Veri Kaynağı"na iletmektir.
class TestRepository {
  // 2. BAĞIMLILIK:
  // Bu 'Aracı', çalışmak için bir 'Veri Kaynağı'na (DataSource) ihtiyaç duyar.
  final TestApiDataSource _apiDataSource;

  // 3. BAĞIMLILIK ENJEKSİYONU (Constructor):
  // Bu bağımlılığı (DataSource) dışarıdan alır.
  TestRepository(this._apiDataSource);

  /// [getTests] - Tüm testleri getirir.
  /// "Beyin" (Notifier) bu fonksiyonu çağırır.
  Future<List<TestModel>> getTests() async {
    // 4. İŞİ DELEGE ETME:
    // 'Repository' mantık çalıştırmaz, sadece talebi 'DataSource'a iletir.
    try {
      // Git, Veri Kaynağı'ndan ('_apiDataSource') 'getTests' yap
      // ve cevabı (List<TestModel>) bekle.
      final tests = await _apiDataSource.getTests();

      // Cevabı "Beyin"e (Notifier) geri ilet.
      return tests;
    } catch (e) {
      // Eğer 'DataSource' hata fırlatırsa ('throw Exception'),
      // bu hatayı yakala ve "Beyin"e geri fırlat.
      rethrow;
    }
  }

  // (Buraya gelecekte getTestDetail(String id) fonksiyonu eklenecek - Madde 2)
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a TestRepository sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final testRepositoryProvider = Provider<TestRepository>((ref) {
  // 1. ADIM: Bağımlılığı (Veri Kaynağını) al
  // Riverpod'a "Bana 'testApiDataSourceProvider' fabrikasının
  // ürettiği nesneyi (DataSource) ver" diyoruz.
  final apiDataSource = ref.read(testApiDataSourceProvider);

  // 2. ADIM: Aracı'yı (Repository) inşa et
  // Aldığımız 'apiDataSource' nesnesini, 'TestRepository'nin
  // kurucusuna (constructor) "enjekte ediyoruz".
  return TestRepository(apiDataSource);
});
