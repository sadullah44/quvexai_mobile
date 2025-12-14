import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/mock_test_result_data_source.dart';
import '../datasources/test_result_local_data_source.dart';
import '../models/test_result_model.dart';

class TestResultRepository {
  final MockTestResultDataSource _apiDataSource;
  final TestResultLocalDataSource _localDataSource;

  TestResultRepository(this._apiDataSource, this._localDataSource);

  // Tekil Sonuç Getirme (Test Bitince Çağrılır)
  Future<TestResultModel> getResult(String sessionId) async {
    try {
      // 1. API'den veriyi çek
      final result = await _apiDataSource.getResult(sessionId);

      // 2. Hive'a yedekle (Otomatik Kayıt)
      await _localDataSource.saveTestResult(result);

      return result;
    } catch (e) {
      // İleride buraya da offline okuma eklenebilir
      rethrow;
    }
  }

  // --- GEÇMİŞ GETİRME (MADDE 5 - SYNC MANTIĞI) ---
  Future<List<TestResultModel>> getTestHistory() async {
    try {
      // 1. Önce API'den güncel geçmişi çekmeyi dene
      debugPrint("🌐 API'den geçmiş çekiliyor...");
      final remoteData = await _apiDataSource.getAllTestResults();

      // 2. Başarılıysa, bu listeyi Hive'a (Local) topluca kaydet (Cache)
      // Böylece bir sonraki sefer internet yoksa bu veriyi kullanabiliriz.
      await _localDataSource.cacheTestHistory(remoteData);

      // 3. Güncel veriyi döndür
      return remoteData;
    } catch (e) {
      // 4. Hata olursa (İnternet yoksa, Sunucu çöktüyse),
      // Hive'daki (Local) eski veriyi döndür (Offline Mod).
      debugPrint(
        "⚠️ API Hatası ($e). Yerel hafıza (Offline Mod) kullanılıyor.",
      );

      // Yerel kaynaktan listeyi getir
      return _localDataSource.getTestHistory();
    }
  }
}

// --- Provider (Fabrika) ---
final testResultRepositoryProvider = Provider<TestResultRepository>((ref) {
  // İki kaynağı da (API ve Local) alıyoruz
  final api = ref.read(mockTestResultDataSourceProvider);
  final local = ref.read(testResultLocalDataSourceProvider);

  // İkisini de Aracı'ya enjekte ediyoruz
  return TestResultRepository(api, local);
});
