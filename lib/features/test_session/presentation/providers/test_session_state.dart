import 'package:equatable/equatable.dart';
import 'package:quvexai_mobile/features/test_session/data/models/question_model.dart';

// Durum Enum'ı
enum TestSessionStatus { initial, loading, loaded, submitting, finished, error }

class TestSessionState extends Equatable {
  final TestSessionStatus status;
  final String? errorMessage;
  final List<QuestionModel> questions;
  final Map<String, String> userAnswers;
  final int currentIndex;

  const TestSessionState({
    required this.status,
    this.errorMessage,
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
  });

  factory TestSessionState.initial() {
    return const TestSessionState(
      status: TestSessionStatus.initial,
      errorMessage: null,
      questions: [],
      userAnswers: {},
      currentIndex: 0,
    );
  }

  TestSessionState copyWith({
    TestSessionStatus? status,
    String? errorMessage,
    List<QuestionModel>? questions,
    Map<String, String>? userAnswers,
    int? currentIndex,
  }) {
    return TestSessionState(
      status: status ?? this.status,
      errorMessage:
          errorMessage, // Hata mesajını temizleyebilmek için null gelebilsin
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    questions,
    userAnswers,
    currentIndex,
  ];
}
