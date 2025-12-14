import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_provider.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_state.dart';
import 'package:quvexai_mobile/core/widgets/offline_banner_widget.dart';
import 'package:quvexai_mobile/core/notifications/notification_service.dart';

class TestSessionScreen extends ConsumerStatefulWidget {
  final String testId;
  final String testName;

  const TestSessionScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  ConsumerState<TestSessionScreen> createState() => _TestSessionScreenState();
}

class _TestSessionScreenState extends ConsumerState<TestSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testSessionProvider.notifier).loadQuestions(widget.testId);
    });
  }

  /// 🔥 Mini toast göster
  void _showMiniToast(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        backgroundColor: isSuccess
            ? Colors.green.shade600
            : Colors.orange.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 🔥 Gecikmeli navigasyon (mounted kontrolü ile)
  void _navigateAfterDelay(String route) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testSessionProvider);

    // 🔥 Cevap kaydedildi toast'ı
    ref.listen(testSessionProvider, (previous, next) {
      // Cevap kaydedildiğinde toast göster
      if (next.lastAnswerSaved != null &&
          (previous?.lastAnswerSaved == null ||
              next.lastAnswerSaved != previous?.lastAnswerSaved)) {
        _showMiniToast("Cevabın kaydedildi ✓");
      }

      // Test bittiğinde
      if (next.status == TestSessionStatus.finished) {
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        debugPrint("🔍 DEBUG: Test finished!");
        debugPrint("📝 submitMessage: '${next.submitMessage}'");
        debugPrint("🌐 isOffline: ${next.isOfflineSubmit}");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        if (next.isOfflineSubmit) {
          // OFFLINE - Ana sayfaya dön (SnackBar gösterme)
          // 🔥 Test sonucu hazır bildirimi göster (offline için beklemede)
          NotificationService.instance.showNotification(
            title: "Test Kuyruğa Eklendi 📴",
            body: "İnternet bağlantısı geldiğinde otomatik gönderilecek.",
            payload: "test_queued:${widget.testId}",
          );
          _navigateAfterDelay('/');
        } else {
          // ONLINE - Sonuç ekranına git
          _showResultSnackBar('Test başarıyla gönderildi! ✅', isOffline: false);
          // 🔥 Test sonucu hazır bildirimi
          NotificationService.instance.showTestResultReadyNotification(
            testName: widget.testName,
            sessionId: 'mock-session-123',
          );
          _navigateAfterDelay('/test-results/mock-session-123');
        }
      }

      // Hata durumu
      if (next.status == TestSessionStatus.error && next.errorMessage != null) {
        _showResultSnackBar(
          next.errorMessage!,
          isOffline: false,
          isError: true,
        );
      }
    });

    return PopScope(
      canPop: state.status != TestSessionStatus.submitting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.status == TestSessionStatus.submitting) {
          _showMiniToast(
            "Test gönderiliyor, lütfen bekleyin...",
            isSuccess: false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.testName),
          centerTitle: true,
          leading: state.status == TestSessionStatus.submitting
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/dashboard'),
                ),
        ),
        body: OfflineBannerWidget(child: _buildBody(state, context)),
      ),
    );
  }

  void _showResultSnackBar(
    String message, {
    required bool isOffline,
    bool isError = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : (isOffline ? Colors.orange : Colors.green),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildBody(TestSessionState state, BuildContext context) {
    // Loading durumu
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error durumu
    if (state.status == TestSessionStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Bir hata oluştu',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(testSessionProvider.notifier)
                      .loadQuestions(widget.testId);
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      );
    }

    // Soru yok
    if (state.questions.isEmpty) {
      return const Center(child: Text("Bu testte hiç soru bulunamadı."));
    }

    final currentQuestion = state.questions[state.currentIndex];
    final totalQuestions = state.questions.length;
    final selectedAnswerId = state.userAnswers[currentQuestion.id];
    final isSubmitting = state.status == TestSessionStatus.submitting;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru ${state.currentIndex + 1} / $totalQuestions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (isSubmitting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: 0,
              end: (state.currentIndex + 1) / totalQuestions,
            ),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),

          // Question & Answers
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>(currentQuestion.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.text,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),

                    // Answers
                    Expanded(
                      child: ListView.separated(
                        itemCount: currentQuestion.answers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final answer = currentQuestion.answers[index];
                          final isSelected = answer.id == selectedAnswerId;

                          return InkWell(
                            onTap: isSubmitting
                                ? null
                                : () {
                                    ref
                                        .read(testSessionProvider.notifier)
                                        .selectAnswer(
                                          currentQuestion.id,
                                          answer.id,
                                          widget.testId,
                                        );
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Colors.grey.shade100,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      answer.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              if (state.currentIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            ref
                                .read(testSessionProvider.notifier)
                                .previousQuestion();
                          },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Geri"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
              else
                const Spacer(),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton.icon(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          state.currentIndex == totalQuestions - 1
                              ? Icons.check_circle
                              : Icons.arrow_forward,
                        ),
                  label: Text(
                    isSubmitting
                        ? "Gönderiliyor..."
                        : (state.currentIndex == totalQuestions - 1
                              ? "Bitir & Gönder"
                              : "İleri"),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        state.currentIndex == totalQuestions - 1 &&
                            !isSubmitting
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedAnswerId == null || isSubmitting
                      ? null
                      : () {
                          if (state.currentIndex == totalQuestions - 1) {
                            ref
                                .read(testSessionProvider.notifier)
                                .submitTest(widget.testId);
                          } else {
                            ref
                                .read(testSessionProvider.notifier)
                                .nextQuestion();
                          }
                        },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 16),
        ],
      ),
    );
  }
}
