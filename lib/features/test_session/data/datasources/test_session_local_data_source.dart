import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bu sınıf, test çözülürken verilen cevapları anlık olarak
/// telefonun hafızasına (Hive) kaydeder ve okur.
class TestSessionLocalDataSource {
  static const String _boxName = 'test_sessions_box';

  /// [saveAnswer] - Tek bir cevabı kaydeder.
  /// Yapı: testId -> { soruId: cevapId, soruId2: cevapId2 ... }
  Future<void> saveAnswer({
    required String testId,
    required String questionId,
    required String answerId,
  }) async {
    final box = Hive.box<Map>(_boxName);

    // 1. Bu test için daha önce kaydedilmiş cevapları çek (yoksa boş harita)
    // Hive'dan gelen veri 'dynamic' olabilir, onu 'Map<String, String>'e cast ediyoruz.
    final currentAnswers = Map<String, String>.from(box.get(testId) ?? {});

    // 2. Yeni cevabı ekle veya güncelle
    currentAnswers[questionId] = answerId;

    // 3. Güncellenmiş haritayı tekrar kutuya koy
    await box.put(testId, currentAnswers);

    print("💾 Cevap kaydedildi: $questionId -> $answerId (Test: $testId)");
  }

  /// [getSavedAnswers] - Bir test için kaydedilmiş tüm cevapları getirir.
  Map<String, String> getSavedAnswers(String testId) {
    final box = Hive.box<Map>(_boxName);
    return Map<String, String>.from(box.get(testId) ?? {});
  }

  /// [clearSession] - Test bittiğinde ve sunucuya gönderildiğinde temizlik yapar.
  Future<void> clearSession(String testId) async {
    final box = Hive.box<Map>(_boxName);
    await box.delete(testId);
    print("🗑️ Oturum temizlendi: $testId");
  }
}

// --- Provider ---
final testSessionLocalDataSourceProvider = Provider<TestSessionLocalDataSource>(
  (ref) {
    return TestSessionLocalDataSource();
  },
);
