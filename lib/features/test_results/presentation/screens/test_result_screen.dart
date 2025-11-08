import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/test_result_provider.dart';

class TestResultScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const TestResultScreen({super.key, required this.sessionId});

  @override
  ConsumerState<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends ConsumerState<TestResultScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran ilk açıldığında BİR KERE veriyi çek.
    // 'fetchTestResult' DEĞİL, 'fetchResult' (doğru isim bu).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testResultProvider.notifier).fetchResult(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Provider'ı izle
    final state = ref.watch(testResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Sonucu')),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(child: Text('Hata: ${state.errorMessage}'));
          } else if (state.result != null) {
            final result = state.result!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplam Puan: ${result.totalScore.toStringAsFixed(1)}', // Ondalıklı gösterebiliriz
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gelişim Önerisi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(result.feedback),

                  const SizedBox(height: 32),
                  // TODO: Buraya grafik widget'ları (Radar/Bar Chart) gelecek
                  const Center(
                    child: Text(
                      '(Grafik Alanı)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Sonuç bulunamadı.'));
          }
        },
      ),
    );
  }
}
