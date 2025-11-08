import 'package:hive/hive.dart';

// Bu satır, birazdan çalıştıracağımız "kod üretici"nin
// oluşturacağı dosyanın adıdır. Şu an kırmızı yanması normaldir.
part 'test_result_model.g.dart';

@HiveType(typeId: 0) // Bu sınıfa "0" numaralı kimliği verdik.
class TestResultModel {
  @HiveField(0) // sessionId verisi, kutudaki 0 numaralı rafa konacak.
  final String sessionId;

  @HiveField(1) // totalScore verisi, 1 numaralı rafa.
  final double totalScore;

  @HiveField(2) // categoryScores haritası, 2 numaralı rafa.
  final Map<String, int> categoryScores;

  @HiveField(3) // feedback metni, 3 numaralı rafa.
  final String feedback;

  @HiveField(4) // completedAt tarihi, 4 numaralı rafa.
  final DateTime completedAt;

  // Constructor (Kurucu Metot) - Aynen kalıyor
  TestResultModel({
    required this.sessionId,
    required this.totalScore,
    required this.categoryScores,
    required this.feedback,
    required this.completedAt,
  });

  // JSON Tercümanı - Aynen kalıyor (API'den gelen veri için lazım)
  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      sessionId: json['sessionId'] ?? '',
      // JSON'dan bazen int (85), bazen double (85.5) gelebilir.
      // .toDouble() ile garantiye alıyoruz.
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      categoryScores: Map<String, int>.from(json['categoryScores'] ?? {}),
      feedback: json['feedback'] ?? '',
      completedAt: DateTime.parse(
        json['completedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
