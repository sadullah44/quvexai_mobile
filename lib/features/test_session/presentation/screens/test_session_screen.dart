// lib/features/test_session/presentation/screens/test_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import '../providers/test_session_provider.dart';

class TestSessionScreen extends ConsumerStatefulWidget {
  final TestModel test;

  const TestSessionScreen({super.key, required this.test});

  @override
  ConsumerState<TestSessionScreen> createState() => _TestSessionScreenState();
}

class _TestSessionScreenState extends ConsumerState<TestSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(testSessionProvider.notifier)
          .loadQuestions(widget.test.questions);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testSessionProvider);

    if (state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.test.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = state.questions[state.currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.test.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.currentIndex + 1) / state.questions.length,
            ),
            const SizedBox(height: 16),
            Text(
              'Soru ${state.currentIndex + 1}/${state.questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ...currentQuestion.options.map(
              (option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: state.userAnswers[currentQuestion.id],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(testSessionProvider.notifier)
                        .selectAnswer(currentQuestion.id, value);
                  }
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: state.currentIndex > 0
                      ? () => ref
                            .read(testSessionProvider.notifier)
                            .previousQuestion()
                      : null,
                  child: const Text('Geri'),
                ),
                state.currentIndex < state.questions.length - 1
                    ? ElevatedButton(
                        onPressed: () => ref
                            .read(testSessionProvider.notifier)
                            .nextQuestion(),
                        child: const Text('İleri'),
                      )
                    : ElevatedButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Test Tamamlandı'),
                            content: const Text('Cevaplarınız gönderildi 🎉'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('Tamam'),
                              ),
                            ],
                          ),
                        ),
                        child: const Text('Bitir & Gönder'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
