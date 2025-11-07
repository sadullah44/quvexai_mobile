// lib/features/tests/data/models/test_model.dart
class Question {
  final String id;
  final String question;
  final List<String> options;
  final String answer;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });
}

class TestModel {
  final String id;
  final String name;
  final String category;
  final int estimatedTimeMins;
  final String difficulty;
  final String? description;
  final List<Question> questions;

  const TestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedTimeMins,
    required this.difficulty,
    this.description,
    required this.questions,
  });
}
