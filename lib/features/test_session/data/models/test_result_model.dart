class TestResult {
  final String sessionId;
  final double totalScore;
  final Map<String, double> categoryScores;
  final String feedback;
  final DateTime completedAt;

  TestResult({
    required this.sessionId,
    required this.totalScore,
    required this.categoryScores,
    required this.feedback,
    required this.completedAt,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      sessionId: json['sessionId'] ?? '',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      categoryScores: Map<String, double>.from(
        (json['categoryScores'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      feedback: json['feedback'] ?? '',
      completedAt:
          DateTime.tryParse(json['completedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'totalScore': totalScore,
    'categoryScores': categoryScores,
    'feedback': feedback,
    'completedAt': completedAt.toIso8601String(),
  };
}
