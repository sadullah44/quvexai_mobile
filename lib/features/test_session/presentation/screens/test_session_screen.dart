import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Kendi provider ve state dosyalarımızı import ediyoruz
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
    // Ekran ilk açıldığında soruları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testSessionProvider.notifier).loadQuestions(widget.testId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Durumu (State) izle
    final state = ref.watch(testSessionProvider);

    // 2. Önemli olayları (Bitiş, Hata) dinle
    ref.listen(testSessionProvider, (previous, next) {
      // Test başarıyla bittiyse
      if (next.status == TestSessionStatus.finished) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test başarıyla gönderildi! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        // Dashboard'a yönlendir (veya sonuç ekranına)
        context.go('/test-results/mock-session-123');
      }
      // Hata oluştuysa
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

  // Duruma göre ekranın içeriğini oluşturan yardımcı metot
  Widget _buildBody(TestSessionState state, BuildContext context) {
    // Yükleniyor durumu
    if (state.status == TestSessionStatus.loading ||
        state.status == TestSessionStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata durumu
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

    // Soru listesi boşsa
    if (state.questions.isEmpty) {
      return const Center(child: Text("Bu testte hiç soru bulunamadı."));
    }

    // --- Test Çözme Arayüzü ---
    final currentQuestion = state.questions[state.currentIndex];
    final totalQuestions = state.questions.length;
    final selectedAnswerId = state.userAnswers[currentQuestion.id];
    // Eğer şu an gönderiliyorsa butonları kilitlemek için:
    final isSubmitting = state.status == TestSessionStatus.submitting;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Bilgi: Soru Sayacı ve İlerleme Çubuğu
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
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / totalQuestions,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 32),

          // Soru Metni
          Text(
            currentQuestion.text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          // Cevap Seçenekleri Listesi
          Expanded(
            child: ListView.separated(
              itemCount: currentQuestion.answers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final answer = currentQuestion.answers[index];
                final isSelected = answer.id == selectedAnswerId;

                return InkWell(
                  // Gönderiliyorsa tıklamayı engelle
                  onTap: isSubmitting
                      ? null
                      : () {
                          ref
                              .read(testSessionProvider.notifier)
                              .selectAnswer(currentQuestion.id, answer.id);
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
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

          // Alt Navigasyon Butonları
          const SizedBox(height: 16),
          Row(
            children: [
              // GERİ BUTONU (İlk soruda gizli)
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
                const Spacer(), // Sol tarafı boş bırak

              const SizedBox(width: 16),

              // İLERİ / BİTİR BUTONU
              Expanded(
                child: ElevatedButton.icon(
                  // Son soruda ikon ve metin değişir
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
                    // Son soruda buton rengini yeşil yapalım
                    backgroundColor:
                        state.currentIndex == totalQuestions - 1 &&
                            !isSubmitting
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),

                  // Cevap seçilmediyse veya gönderiliyorsa butonu kilitle
                  onPressed: selectedAnswerId == null || isSubmitting
                      ? null
                      : () {
                          if (state.currentIndex == totalQuestions - 1) {
                            // Son soru: Gönder
                            ref.read(testSessionProvider.notifier).submitTest();
                          } else {
                            // Diğer sorular: İleri git
                            ref
                                .read(testSessionProvider.notifier)
                                .nextQuestion();
                          }
                        },
                ),
              ),
            ],
          ),
          // Alt boşluk (SafeArea için)
          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 16),
        ],
      ),
    );
  }
}
