import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_result_model.dart';

class MockTestResultDataSource {
  Future<TestResultModel> getResult(String sessionId) async {
    // Gerçekçi olması için biraz bekletelim
    await Future.delayed(const Duration(seconds: 1));

    // Sahte bir sonuç döndürelim
    return TestResultModel(
      sessionId: sessionId,
      totalScore: 85.5,
      categoryScores: {'Bağlanma Kaygısı': 70, 'Kaçınganlık': 30, 'Güven': 85},
      feedback:
          "Sonuçlarınız, ilişkilerde genel olarak güvenli bir bağlanma stiline sahip olduğunuzu, ancak zaman zaman kaygı yaşayabileceğinizi gösteriyor. Kendinize güvenin!",
      completedAt: DateTime.now(),
    );
  }
}

final mockTestResultDataSourceProvider = Provider<MockTestResultDataSource>((
  ref,
) {
  return MockTestResultDataSource();
});
