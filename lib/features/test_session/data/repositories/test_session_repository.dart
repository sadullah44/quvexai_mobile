// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart';
// "Veri Kaynağımızı" (Canvas'taki dosya) import ediyoruz
import 'package:quvexai_mobile/features/test_session/data/datasources/test_session_data_source.dart';
// "Soru Modelimizi" (Canvas'taki dosya) import ediyoruz
import 'package:quvexai_mobile/features/test_session/data/models/question_model.dart';

/// Bu, "Test Çözme Beyni"nin ('TestSessionNotifier') konuşacağı "Aracı"dır (Repository).
/// Görevi, "Beyin"den gelen talebi "Veri Kaynağı"na iletmektir.
class TestSessionRepository {
  // 2. BAĞIMLILIK:
  // Bu 'Aracı', çalışmak için bir 'Veri Kaynağı'na (DataSource) ihtiyaç duyar.
  final TestSessionDataSource _dataSource;

  // 3. BAĞIMLILIK ENJEKSİYONU (Constructor):
  // Bu bağımlılığı (DataSource) dışarıdan alır.
  TestSessionRepository(this._dataSource);

  /// [getTestQuestions] - Soru listesini getirir.
  /// "Beyin" (Notifier) bu fonksiyonu çağırır.
  Future<List<QuestionModel>> getTestQuestions(String testId) async {
    // 4. İŞİ DELEGE ETME:
    // 'Repository' mantık çalıştırmaz, sadece talebi 'DataSource'a iletir.
    try {
      // Git, Veri Kaynağı'ndan ('_dataSource') 'getTestQuestions' yap
      // ve cevabı (List<QuestionModel>) bekle.
      final questions = await _dataSource.getTestQuestions(testId);

      // Cevabı "Beyin"e (Notifier) geri ilet.
      return questions;
    } catch (e) {
      // Eğer 'DataSource' hata fırlatırsa ('throw Exception'),
      // bu hatayı yakala ve "Beyin"e geri fırlat.
      rethrow;
    }
  }

  // Burası, 'submitTest' (Cevapları Gönder) fonksiyonunun
  // ekleneceği yer olacak.
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a TestSessionRepository sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final testSessionRepositoryProvider = Provider<TestSessionRepository>((ref) {
  // 1. ADIM: Bağımlılığı (Veri Kaynağını) al
  // Riverpod'a "Bana 'testSessionDataSourceProvider' fabrikasının
  // ürettiği nesneyi (DataSource) ver" diyoruz.
  final dataSource = ref.read(
    testSessionDataSourceProvider,
  ); // (Canvas'taki dosyadan)

  // 2. ADIM: Aracı'yı (Repository) inşa et
  // Aldığımız 'dataSource' nesnesini, 'TestSessionRepository'nin
  // kurucusuna (constructor) "enjekte ediyoruz".
  return TestSessionRepository(dataSource);
});
