import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/test_session/data/repositories/test_session_repository.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_state.dart';

// Arayüzün (UI) bu "Beyin"e erişmesi için anahtar (Provider)
final testSessionProvider =
    NotifierProvider<TestSessionNotifier, TestSessionState>(
      () => TestSessionNotifier(),
    );

// Test oturumunu yöneten "Beyin" (Notifier) sınıfı
class TestSessionNotifier extends Notifier<TestSessionState> {
  @override
  TestSessionState build() {
    // Başlangıç durumu
    return TestSessionState.initial();
  }

  /// [loadQuestions] - Belirtilen test ID'si için soruları yükler.
  Future<void> loadQuestions(String testId) async {
    // Eğer zaten yükleniyorsa veya yüklendiyse tekrar yapma
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.loaded) {
      return;
    }

    try {
      // Yükleniyor durumuna geç
      state = state.copyWith(
        status: TestSessionStatus.loading,
        errorMessage: null,
      );

      // Repository'den (Aracı) soruları çek
      final questionsList = await ref
          .read(testSessionRepositoryProvider)
          .getTestQuestions(testId);

      // Başarılı durumu güncelle
      state = state.copyWith(
        status: TestSessionStatus.loaded,
        questions: questionsList,
        currentIndex: 0,
        userAnswers: {}, // Yeni test için cevapları temizle
      );
    } catch (e) {
      // Hata durumuna geç
      state = state.copyWith(
        status: TestSessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// [selectAnswer] - Kullanıcının bir soruya verdiği cevabı kaydeder.
  void selectAnswer(String questionId, String answerId) {
    // Mevcut cevap haritasının bir kopyasını al
    final newAnswers = Map<String, String>.from(state.userAnswers);
    // Yeni cevabı ekle veya güncelle
    newAnswers[questionId] = answerId;
    // Durumu güncelle
    state = state.copyWith(userAnswers: newAnswers);
  }

  /// [nextQuestion] - Bir sonraki soruya geçer.
  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// [previousQuestion] - Bir önceki soruya döner.
  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// [submitTest] - Testi bitirir ve gönderir.
  Future<void> submitTest() async {
    try {
      // 1. Durumu 'submitting' (gönderiliyor) yap - UI'da loader gösterilir
      state = state.copyWith(
        status: TestSessionStatus.submitting,
        errorMessage: null,
      );

      // 2. Simüle edilmiş bir ağ gecikmesi (gerçek API gelene kadar)
      await Future.delayed(const Duration(seconds: 2));

      // 3. Durumu 'finished' (bitti) yap - UI bunu dinleyip yönlendirme yapacak
      state = state.copyWith(status: TestSessionStatus.finished);
    } catch (e) {
      // Hata durumunda
      state = state.copyWith(
        status: TestSessionStatus.error,
        errorMessage: "Gönderim hatası: $e",
      );
    }
  }
}
