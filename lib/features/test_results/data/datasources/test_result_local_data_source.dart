import 'package:hive/hive.dart';
import '../models/test_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestResultLocalDataSource {
  // Kutumuzun adı sabit olsun, hata yapmayalım.
  static const String _boxName = 'test_results_box';

  /// [saveTestResult] - Yeni bir test sonucunu yerel kutuya kaydeder.
  Future<void> saveTestResult(TestResultModel result) async {
    final box = Hive.box<TestResultModel>(_boxName);

    // 'put' kullanırsak bir anahtar (key) vermemiz gerekir.
    // 'add' kullanırsak Hive otomatik bir numara verir.
    // Biz sessionId'yi anahtar olarak kullanalım ki aynı testi
    // tekrar kaydedersek üzerine yazsın (güncellesin).
    await box.put(result.sessionId, result);

    print("✅ Hive: Test sonucu kaydedildi -> ${result.sessionId}");
  }

  /// [getAllTestResults] - Geçmiş tüm test sonuçlarını getirir.
  List<TestResultModel> getAllTestResults() {
    final box = Hive.box<TestResultModel>(_boxName);
    // Kutudaki tüm değerleri bir liste olarak döndür.
    return box.values.toList();
  }
}

// --- Riverpod Provider ---
final testResultLocalDataSourceProvider = Provider<TestResultLocalDataSource>((
  ref,
) {
  return TestResultLocalDataSource();
});
