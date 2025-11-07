// lib/features/test_session/presentation/providers/test_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

class TestSessionState {
  final List<Question> questions;
  final Map<String, String> userAnswers;
  final int currentIndex;

  TestSessionState({
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
  });

  factory TestSessionState.initial() =>
      TestSessionState(questions: [], userAnswers: {}, currentIndex: 0);

  TestSessionState copyWith({
    List<Question>? questions,
    Map<String, String>? userAnswers,
    int? currentIndex,
  }) {
    return TestSessionState(
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class TestSessionNotifier extends StateNotifier<TestSessionState> {
  TestSessionNotifier() : super(TestSessionState.initial());

  void loadQuestions(List<Question> questions) {
    state = state.copyWith(
      questions: questions,
      userAnswers: {},
      currentIndex: 0,
    );
  }

  void selectAnswer(String questionId, String answer) {
    final newAnswers = Map<String, String>.from(state.userAnswers);
    newAnswers[questionId] = answer;
    state = state.copyWith(userAnswers: newAnswers);
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
}

final testSessionProvider =
    StateNotifierProvider<TestSessionNotifier, TestSessionState>(
      (ref) => TestSessionNotifier(),
    );
