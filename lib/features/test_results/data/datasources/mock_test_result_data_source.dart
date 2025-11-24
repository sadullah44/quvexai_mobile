import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_result_model.dart';

class MockTestResultDataSource {
  // Tekil Sonuç Getirme (Test Bitince Çağrılır)
  Future<TestResultModel> getResult(String sessionId) async {
    // Gerçekçi olması için biraz bekletelim
    await Future.delayed(const Duration(seconds: 1));

    return TestResultModel(
      sessionId: sessionId,
      testName: "Çocukluk Travmaları Testi", // <-- YENİ: Test Adı
      totalScore: 85.5,
      categoryScores: {'Bağlanma Kaygısı': 70, 'Kaçınganlık': 30, 'Güven': 85},
      feedback:
          "Sonuçlarınız, ilişkilerde genel olarak güvenli bir bağlanma stiline sahip olduğunuzu, ancak zaman zaman kaygı yaşayabileceğinizi gösteriyor.",
      completedAt: DateTime.now(),
    );
  }

  // --- GEÇMİŞ LİSTESİ (MADDE 2) ---
  Future<List<TestResultModel>> getAllTestResults() async {
    await Future.delayed(const Duration(seconds: 1));

    // Listeyi dolu göstermek için sahte geçmiş verileri
    // ARTIK 'testName' ALANIYLA BİRLİKTE:
    return [
      TestResultModel(
        sessionId: 'session_1',
        testName: "Stres Yönetimi Ölçeği", // <-- Arama burada yapılacak
        totalScore: 92.0,
        categoryScores: {'Stres': 20, 'Kaygı': 10},
        feedback: "Harika bir stres yönetimi!",
        completedAt: DateTime.now().subtract(const Duration(days: 1)), // Dün
      ),
      TestResultModel(
        sessionId: 'session_2',
        testName: "Bağlanma Stilleri Testi", // <-- Arama burada yapılacak
        totalScore: 45.5,
        categoryScores: {'Bağlanma': 80, 'Güven': 30},
        feedback: "Bağlanma konusunda çalışmalısın.",
        completedAt: DateTime.now().subtract(
          const Duration(days: 5),
        ), // 5 gün önce
      ),
      TestResultModel(
        sessionId: 'session_3',
        testName: "Çocukluk Travmaları Testi", // <-- Arama burada yapılacak
        totalScore: 78.0,
        categoryScores: {'Travma': 40, 'İyileşme': 60},
        feedback: "İyileşme sürecin devam ediyor.",
        completedAt: DateTime.now().subtract(
          const Duration(days: 10),
        ), // 10 gün önce
      ),
    ];
  }
}

final mockTestResultDataSourceProvider = Provider<MockTestResultDataSource>((
  ref,
) {
  return MockTestResultDataSource();
});
