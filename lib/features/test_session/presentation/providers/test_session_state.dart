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
  final String? submitMessage;
  final bool isOfflineSubmit;
  final DateTime? lastAnswerSaved; // 🔥 YENİ: Son cevap kayıt zamanı

  const TestSessionState({
    required this.status,
    this.errorMessage,
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
    this.submitMessage,
    this.isOfflineSubmit = false,
    this.lastAnswerSaved,
  });

  factory TestSessionState.initial() {
    return const TestSessionState(
      status: TestSessionStatus.initial,
      errorMessage: null,
      questions: [],
      userAnswers: {},
      currentIndex: 0,
      submitMessage: null,
      isOfflineSubmit: false,
      lastAnswerSaved: null,
    );
  }

  TestSessionState copyWith({
    TestSessionStatus? status,
    String? errorMessage,
    List<QuestionModel>? questions,
    Map<String, String>? userAnswers,
    int? currentIndex,
    String? submitMessage,
    bool? isOfflineSubmit,
    DateTime? lastAnswerSaved,
  }) {
    return TestSessionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
      submitMessage: submitMessage ?? this.submitMessage,
      isOfflineSubmit: isOfflineSubmit ?? this.isOfflineSubmit,
      lastAnswerSaved: lastAnswerSaved ?? this.lastAnswerSaved,
    );
  }

  /// 🔥 Helper: Tüm sorular cevaplanmış mı?
  bool get allQuestionsAnswered =>
      questions.length == userAnswers.length && questions.isNotEmpty;

  /// 🔥 Helper: Mevcut sorunun cevabı var mı?
  bool get currentQuestionAnswered {
    if (questions.isEmpty || currentIndex >= questions.length) return false;
    final currentQuestionId = questions[currentIndex].id;
    return userAnswers.containsKey(currentQuestionId);
  }

  /// 🔥 Helper: İlerleme yüzdesi
  double get progress {
    if (questions.isEmpty) return 0;
    return userAnswers.length / questions.length;
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    questions,
    userAnswers,
    currentIndex,
    submitMessage,
    isOfflineSubmit,
    lastAnswerSaved,
  ];
}
