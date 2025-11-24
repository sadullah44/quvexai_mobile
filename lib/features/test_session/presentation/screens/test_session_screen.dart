import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_provider.dart';
import 'package:quvexai_mobile/features/test_session/presentation/providers/test_session_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testSessionProvider);

    ref.listen(testSessionProvider, (previous, next) {
      if (next.status == TestSessionStatus.finished) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test başarıyla gönderildi! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        // Sonuç ekranına yönlendir
        context.go('/test-results/mock-session-123');
      }
      if (next.status == TestSessionStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.testName), centerTitle: true),
      body: _buildBody(state, context),
    );
  }

  Widget _buildBody(TestSessionState state, BuildContext context) {
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == TestSessionStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Bir hata oluştu:\n${state.errorMessage}',
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
      );
    }

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
          // --- ÜST KISIM (Sayaç ve Progress) ---
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
          // Animasyonlu Progress Bar
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

          // --- SORU KARTI (ANİMASYONLU GEÇİŞ) ---
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              // Geçiş Efekti: Yeni soru sağdan gelir, eski soru sola gider
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.1), // Hafif aşağıdan yukarı
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
              // Animasyonun çalışması için her soruya benzersiz bir KEY veriyoruz
              child: KeyedSubtree(
                key: ValueKey<String>(currentQuestion.id), // <-- KRİTİK NOKTA
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.text,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),

                    // Cevap Seçenekleri
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
                                        );
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ), // Seçim animasyonu
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

          // --- ALT BUTONLAR ---
          const SizedBox(height: 16),
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
                      ? const SizedBox.shrink()
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
                            ref.read(testSessionProvider.notifier).submitTest();
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
