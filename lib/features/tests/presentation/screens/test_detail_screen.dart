import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- ekle
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

/// Test detay ekranı
class TestDetailScreen extends StatelessWidget {
  final TestModel test;

  const TestDetailScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(test.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kategori: ${test.category}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Zorluk: ${test.difficulty}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "Tahmini Süre: ${test.estimatedTimeMins} dakika",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 40),
            Text(
              test.description ?? 'Bu test için açıklama bulunamadı.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Teste Başla',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  context.push('/test-session/${test.id}', extra: test);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
