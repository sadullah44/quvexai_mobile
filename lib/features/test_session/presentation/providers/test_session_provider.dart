import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/test_session/data/repositories/test_session_repository.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_state.dart';

final testSessionProvider =
    NotifierProvider<TestSessionNotifier, TestSessionState>(
      () => TestSessionNotifier(),
    );

class TestSessionNotifier extends Notifier<TestSessionState> {
  @override
  TestSessionState build() {
    return TestSessionState.initial();
  }

  Future<void> loadQuestions(String testId) async {
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.loaded) {
      return;
    }

    try {
      state = state.copyWith(
        status: TestSessionStatus.loading,
        errorMessage: null,
      );

      final questionsList = await ref
          .read(testSessionRepositoryProvider)
          .getTestQuestions(testId);
      final savedAnswers = ref
          .read(testSessionRepositoryProvider)
          .getSavedAnswers(testId);

      state = state.copyWith(
        status: TestSessionStatus.loaded,
        questions: questionsList,
        currentIndex: 0,
        userAnswers: savedAnswers,
      );
    } catch (e) {
      state = state.copyWith(
        status: TestSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> selectAnswer(
    String questionId,
    String answerId,
    String testId,
  ) async {
    final newAnswers = Map<String, String>.from(state.userAnswers);
    newAnswers[questionId] = answerId;
    state = state.copyWith(userAnswers: newAnswers);

    try {
      await ref
          .read(testSessionRepositoryProvider)
          .saveAnswer(testId, questionId, answerId);
    } catch (e) {
      print("⚠️ Cevap kaydedilemedi: $e");
    }
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

  // --- GÜNCELLENEN METOT: SYNC ENTEGRASYONU ---
  Future<void> submitTest(String testId) async {
    try {
      state = state.copyWith(
        status: TestSessionStatus.submitting,
        errorMessage: null,
      );

      // ARTIK SAHTE BEKLEME YOK!
      // İşi Repository'ye devrediyoruz. O da duruma göre API'ye veya Kuyruğa atacak.
      // Kullanıcının verdiği cevapları (state.userAnswers) da gönderiyoruz.
      await ref
          .read(testSessionRepositoryProvider)
          .submitTest(testId, state.userAnswers);

      // Repository hata fırlatmadıysa (API başarılı VEYA Kuyruğa eklendi),
      // İşlem tamamlandı sayılır.
      state = state.copyWith(status: TestSessionStatus.finished);
    } catch (e) {
      // Sadece beklenmedik, kurtarılamayan bir hata olursa buraya düşer
      state = state.copyWith(
        status: TestSessionStatus.error,
        errorMessage: "Gönderim hatası: $e",
      );
    }
  }
}
