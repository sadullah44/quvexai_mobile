import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/mock_test_result_data_source.dart';
import '../datasources/test_result_local_data_source.dart';
import '../models/test_result_model.dart';

class TestResultRepository {
  final MockTestResultDataSource _apiDataSource;
  final TestResultLocalDataSource _localDataSource;

  TestResultRepository(this._apiDataSource, this._localDataSource);

  Future<TestResultModel> getResult(String sessionId) async {
    try {
      // 1. Önce API'den (şimdilik Mock) taze veriyi çek
      final result = await _apiDataSource.getResult(sessionId);

      // 2. Gelen taze veriyi hemen yerel hafızaya (Hive) yedekle
      await _localDataSource.saveTestResult(result);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// [getTestHistory] - Geçmiş test sonuçlarını localden getirir.
  /// Asenkron (Future) yaptık ki ileride veritabanı değişirse UI etkilenmesin.
  Future<List<TestResultModel>> getTestHistory() async {
    // LocalDataSource'daki metodumuzun adı 'getTestHistory' idi.
    return _localDataSource.getTestHistory();
  }
}

// --- Provider ---
final testResultRepositoryProvider = Provider<TestResultRepository>((ref) {
  final api = ref.read(mockTestResultDataSourceProvider);
  final local = ref.read(testResultLocalDataSourceProvider);
  return TestResultRepository(api, local);
});
