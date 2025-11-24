import 'package:hive/hive.dart';

part 'test_result_model.g.dart';

@HiveType(typeId: 0)
class TestResultModel {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final double totalScore;

  @HiveField(2)
  final Map<String, int> categoryScores;

  @HiveField(3)
  final String feedback;

  @HiveField(4)
  final DateTime completedAt;

  // --- YENİ ALAN ---
  @HiveField(5) // Yeni alan için yeni index verdik
  final String testName;

  TestResultModel({
    required this.sessionId,
    required this.totalScore,
    required this.categoryScores,
    required this.feedback,
    required this.completedAt,
    required this.testName, // Artık zorunlu
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      sessionId: json['sessionId'] ?? '',
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      categoryScores: Map<String, int>.from(json['categoryScores'] ?? {}),
      feedback: json['feedback'] ?? '',
      completedAt: DateTime.parse(
        json['completedAt'] ?? DateTime.now().toIso8601String(),
      ),
      // JSON'da yoksa varsayılan bir isim verelim
      testName: json['testName'] ?? 'Bilinmeyen Test',
    );
  }
}
