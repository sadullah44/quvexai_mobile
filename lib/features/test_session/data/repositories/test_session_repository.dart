import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // İNTERNET KONTROLÜ İÇİN
import 'package:quvexai_mobile/features/test_session/data/datasources/test_session_data_source.dart';
import 'package:quvexai_mobile/features/test_session/data/datasources/test_session_local_data_source.dart';
import 'package:quvexai_mobile/features/test_session/data/models/question_model.dart';
import 'package:quvexai_mobile/core/sync/sync_service.dart';

class TestSessionRepository {
  final TestSessionDataSource _dataSource;
  final TestSessionLocalDataSource _localDataSource;
  final SyncService _syncService;

  TestSessionRepository(
    this._dataSource,
    this._localDataSource,
    this._syncService,
  );

  // Soruları Getir
  Future<List<QuestionModel>> getTestQuestions(String testId) async {
    try {
      return await _dataSource.getTestQuestions(testId);
    } catch (e) {
      rethrow;
    }
  }

  // Cevabı Kaydet (Yerel)
  Future<void> saveAnswer(
    String testId,
    String questionId,
    String answerId,
  ) async {
    await _localDataSource.saveAnswer(
      testId: testId,
      questionId: questionId,
      answerId: answerId,
    );
  }

  // Kaydedilmiş Cevapları Getir
  Map<String, String> getSavedAnswers(String testId) {
    return _localDataSource.getSavedAnswers(testId);
  }

  // Oturumu Temizle
  Future<void> clearSession(String testId) async {
    await _localDataSource.clearSession(testId);
  }

  // --- GÜNCELLENMİŞ: İNTERNET KONTROLLÜ GÖNDERİM ---
  Future<void> submitTest(String testId, Map<String, String> answers) async {
    print("🚀 Repository: Test gönderimi başlatıldı...");

    try {
      // 1. ÖNCE İNTERNET VAR MI DİYE BAK
      // Simülasyon yapıyoruz ama internet kontrolünü gerçek yapalım.
      final connectivityResult = await (Connectivity().checkConnectivity());

      // Eğer internet yoksa (none), hata fırlat ki 'catch' bloğuna düşsün.
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception("İnternet bağlantısı yok (Offline Mod Testi)");
      }

      // 2. İNTERNET VARSA API SİMÜLASYONU
      await Future.delayed(const Duration(seconds: 1));

      // Başarılı
      print("✅ API: Başarıyla gönderildi.");
      await _localDataSource.clearSession(testId);
    } catch (e) {
      // 3. HATA DURUMU (İNTERNET YOKSA BURASI ÇALIŞIR)
      print("⚠️ API Hatası: $e. Kuyruğa ekleniyor...");

      // Gönderilemeyen testi KUYRUĞA EKLE
      await _syncService.addToQueue(testId, answers);

      // Yerel oturumu temizle (Kuyruğa alındığı için)
      await _localDataSource.clearSession(testId);
    }
  }
}

// --- Provider ---
final testSessionRepositoryProvider = Provider<TestSessionRepository>((ref) {
  final dataSource = ref.read(testSessionDataSourceProvider);
  final localDataSource = ref.read(testSessionLocalDataSourceProvider);
  final syncService = ref.read(syncServiceProvider);

  return TestSessionRepository(dataSource, localDataSource, syncService);
});
