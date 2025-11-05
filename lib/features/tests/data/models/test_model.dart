import 'package:equatable/equatable.dart';

class TestModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final int estimatedTimeMins;
  final String difficulty;
  final String? description;

  const TestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedTimeMins,
    required this.difficulty,
    this.description,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      estimatedTimeMins: json['estimated_time_mins'] as int,
      difficulty: json['difficulty'] as String,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    estimatedTimeMins,
    difficulty,
    description,
  ];
}
