import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/test_session/data/repositories/test_session_repository.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_state.dart';
import 'package:quvexai_mobile/core/sync/sync_service.dart';

final testSessionProvider =
    NotifierProvider<TestSessionNotifier, TestSessionState>(
      () => TestSessionNotifier(),
    );

class TestSessionNotifier extends Notifier<TestSessionState> {
  // 🔥 Debounce mekanizması için
  DateTime? _lastStateChange;
  static const _debounceDelay = Duration(milliseconds: 100);

  @override
  TestSessionState build() {
    return TestSessionState.initial();
  }

  /// 🔥 Debounced state update
  void _updateState(TestSessionState newState) {
    final now = DateTime.now();
    if (_lastStateChange != null &&
        now.difference(_lastStateChange!) < _debounceDelay) {
      debugPrint("⏱️ State update debounced");
      return;
    }
    _lastStateChange = now;
    state = newState;
  }

  Future<void> loadQuestions(String testId) async {
    // Duplicate loading engelleme
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.loaded) {
      debugPrint("⚠️ Sorular zaten yükleniyor/yüklendi, atlanıyor");
      return;
    }

    try {
      _updateState(
        state.copyWith(status: TestSessionStatus.loading, errorMessage: null),
      );

      final questionsList = await ref
          .read(testSessionRepositoryProvider)
          .getTestQuestions(testId);

      final savedAnswers = ref
          .read(testSessionRepositoryProvider)
          .getSavedAnswers(testId);

      _updateState(
        state.copyWith(
          status: TestSessionStatus.loaded,
          questions: questionsList,
          currentIndex: 0,
          userAnswers: savedAnswers,
        ),
      );
    } catch (e) {
      debugPrint("❌ Test yükleme hatası: $e");
      _updateState(
        state.copyWith(
          status: TestSessionStatus.error,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> selectAnswer(
    String questionId,
    String answerId,
    String testId,
  ) async {
    // 🔥 Race condition önleme - Submitting durumunda cevap seçilemesin
    if (state.status == TestSessionStatus.submitting) {
      debugPrint("⚠️ Test gönderiliyor, cevap seçimi engellendi");
      return;
    }

    try {
      // 1. State'i hemen güncelle (UI feedback)
      final newAnswers = Map<String, String>.from(state.userAnswers);
      newAnswers[questionId] = answerId;

      _updateState(
        state.copyWith(
          userAnswers: newAnswers,
          lastAnswerSaved: DateTime.now(),
        ),
      );

      // 2. Background'da kaydet
      await ref
          .read(testSessionRepositoryProvider)
          .saveAnswer(testId, questionId, answerId);

      debugPrint("💾 Cevap kaydedildi: $questionId -> $answerId");
    } catch (e) {
      debugPrint("⚠️ Cevap kaydedilemedi: $e");
    }
  }

  void nextQuestion() {
    // 🔥 Submitting durumunda ilerleme engelle
    if (state.status == TestSessionStatus.submitting) {
      debugPrint("⚠️ Test gönderiliyor, ilerleme engellendi");
      return;
    }

    if (state.currentIndex < state.questions.length - 1) {
      _updateState(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previousQuestion() {
    // 🔥 Submitting durumunda geri gitme engelle
    if (state.status == TestSessionStatus.submitting) {
      debugPrint("⚠️ Test gönderiliyor, geri gitme engellendi");
      return;
    }

    if (state.currentIndex > 0) {
      _updateState(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  /// 🔥 Test gönderme - Offline/Online mantığı
  Future<SubmitResult> submitTest(String testId) async {
    // Duplicate submission engelleme
    if (state.status == TestSessionStatus.submitting) {
      debugPrint("⚠️ Test zaten gönderiliyor, atlanıyor");
      return SubmitResult(
        success: false,
        isOffline: false,
        message: "Test zaten gönderiliyor...",
      );
    }

    try {
      // 1. UI'yi blokla
      _updateState(
        state.copyWith(
          status: TestSessionStatus.submitting,
          errorMessage: null,
        ),
      );

      // 2. Repository'den submit (online/offline otomatik kontrol)
      final result = await ref
          .read(testSessionRepositoryProvider)
          .submitTest(testId, state.userAnswers);

      // 3. Sonuç durumuna göre state güncelle
      if (result.isOffline) {
        // 🔥 OFFLINE: Kuyruğa eklendi
        debugPrint("📴 Test offline kuyruğa eklendi");

        _updateState(
          state.copyWith(
            status: TestSessionStatus.finished,
            submitMessage: result.message,
            isOfflineSubmit: true,
          ),
        );

        // Sync service'e ekle
        await ref
            .read(syncServiceProvider)
            .addToQueue(testId, state.userAnswers);
      } else {
        // 🔥 ONLINE: Başarıyla gönderildi
        debugPrint("✅ Test online gönderildi");

        _updateState(
          state.copyWith(
            status: TestSessionStatus.finished,
            submitMessage: result.message,
            isOfflineSubmit: false,
          ),
        );
      }

      return result;
    } catch (e) {
      debugPrint("❌ Test gönderim hatası: $e");

      // Hata durumunda offline olarak kaydet
      final errorMessage = _getErrorMessage(e);

      // Network hatası ise kuyruğa ekle
      if (_isNetworkError(e)) {
        await ref
            .read(syncServiceProvider)
            .addToQueue(testId, state.userAnswers);

        _updateState(
          state.copyWith(
            status: TestSessionStatus.finished,
            submitMessage:
                "Test kuyruğa eklendi. İnternet geldiğinde gönderilecek.",
            isOfflineSubmit: true,
          ),
        );

        return SubmitResult(
          success: true,
          isOffline: true,
          message: "Test kuyruğa eklendi",
        );
      }

      // Diğer hatalar
      _updateState(
        state.copyWith(
          status: TestSessionStatus.error,
          errorMessage: errorMessage,
        ),
      );

      return SubmitResult(
        success: false,
        isOffline: false,
        message: errorMessage,
      );
    }
  }

  /// 🔥 Network hatası kontrolü
  bool _isNetworkError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout') ||
        errorStr.contains('failed host lookup');
  }

  /// 🔥 Hata mesajlarını kullanıcı dostu hale getirir
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('socket') || errorStr.contains('network')) {
      return "İnternet bağlantısı yok. Test kuyruğa eklendi.";
    } else if (errorStr.contains('timeout')) {
      return "Zaman aşımı. Test kuyruğa eklendi.";
    } else if (errorStr.contains('token') || errorStr.contains('401')) {
      return "Oturum süresi doldu. Lütfen giriş yapın.";
    } else if (errorStr.contains('404')) {
      return "Test bulunamadı.";
    } else if (errorStr.contains('500')) {
      return "Sunucu hatası. Lütfen daha sonra tekrar deneyin.";
    }

    return "Bir hata oluştu: $error";
  }

  /// 🔥 State'i sıfırla (yeni test için)
  void reset() {
    state = TestSessionState.initial();
    _lastStateChange = null;
  }
}
