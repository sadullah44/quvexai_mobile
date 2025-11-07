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

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
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

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      estimatedTimeMins: json['estimatedTimeMins'] ?? 0,
      difficulty: json['difficulty'] ?? '',
      description: json['description'],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'estimatedTimeMins': estimatedTimeMins,
      'difficulty': difficulty,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
