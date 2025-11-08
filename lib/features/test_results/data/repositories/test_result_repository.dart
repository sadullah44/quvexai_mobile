import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/mock_test_result_data_source.dart';
import '../datasources/test_result_local_data_source.dart'; // <-- YENİ
import '../models/test_result_model.dart';

class TestResultRepository {
  final MockTestResultDataSource _apiDataSource;
  final TestResultLocalDataSource _localDataSource; // <-- YENİ BAĞIMLILIK

  TestResultRepository(this._apiDataSource, this._localDataSource);

  Future<TestResultModel> getResult(String sessionId) async {
    try {
      // 1. Önce API'den (şimdilik Mock) taze veriyi çek
      final result = await _apiDataSource.getResult(sessionId);

      // 2. Gelen taze veriyi hemen yerel hafızaya (Hive) yedekle
      await _localDataSource.saveTestResult(result);

      return result;
    } catch (e) {
      // İleride burada: "API hata verirse local'den dön" mantığı eklenecek (Madde 5)
      rethrow;
    }
  }

  // Geçmiş sonuçları listelemek için yeni fonksiyon
  List<TestResultModel> getLocalResults() {
    return _localDataSource.getAllTestResults();
  }
}

// --- Güncellenmiş Provider ---
final testResultRepositoryProvider = Provider<TestResultRepository>((ref) {
  // İki kaynağı da alıyoruz
  final api = ref.read(mockTestResultDataSourceProvider);
  final local = ref.read(testResultLocalDataSourceProvider);

  // İkisini de Aracı'ya veriyoruz
  return TestResultRepository(api, local);
});
