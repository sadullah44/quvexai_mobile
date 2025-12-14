import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_result_model.dart';

class TestResultLocalDataSource {
  // Kutumuzun adı sabit olsun, hata yapmayalım.
  static const String _boxName = 'test_results_box';

  /// [saveTestResult] - Yeni bir test sonucunu yerel kutuya kaydeder.
  Future<void> saveTestResult(TestResultModel result) async {
    final box = Hive.box<TestResultModel>(_boxName);

    // sessionId'yi anahtar olarak kullanarak kaydediyoruz.
    // Böylece aynı session tekrar gelirse üzerine yazar (günceller).
    await box.put(result.sessionId, result);

    debugPrint("✅ Hive: Test sonucu kaydedildi -> ${result.sessionId}");
  }

  /// [cacheTestHistory] - API'den gelen listeyi alıp hepsini kutuya doldurur (Önbellekleme).
  Future<void> cacheTestHistory(List<TestResultModel> results) async {
    final box = Hive.box<TestResultModel>(_boxName);

    // Döngü ile hepsini tek tek 'put' yapıyoruz.
    for (var result in results) {
      await box.put(result.sessionId, result);
    }
    debugPrint("✅ Hive: ${results.length} adet geçmiş kayıt önbelleklendi.");
  }

  /// [getTestHistory] - Kutudaki TÜM geçmiş test sonuçlarını getirir.
  List<TestResultModel> getTestHistory() {
    final box = Hive.box<TestResultModel>(_boxName);

    // Kutudaki tüm değerleri al, listeye çevir.
    final history = box.values.toList();

    // Yeniden eskiye doğru sırala (En son çözülen en üstte görünsün)
    history.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return history;
  }
}

// --- Riverpod Provider ---
final testResultLocalDataSourceProvider = Provider<TestResultLocalDataSource>((
  ref,
) {
  return TestResultLocalDataSource();
});
