import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import 'package:quvexai_mobile/features/tests/presentation/providers/test_provider.dart';

class TestListScreen extends ConsumerStatefulWidget {
  const TestListScreen({super.key});

  @override
  ConsumerState<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends ConsumerState<TestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testProvider.notifier).fetchTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Listesi')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Testler yüklenemedi: ${state.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    onPressed: () {
                      ref.read(testProvider.notifier).fetchTests();
                    },
                  ),
                ],
              ),
            )
          : state.tests.isEmpty
          ? const Center(
              child: Text(
                'Gösterilecek test bulunamadı.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: state.tests.length,
              itemBuilder: (context, index) {
                final test = state.tests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(test.name),
                    subtitle: Text(
                      '${test.category} • ${test.difficulty} • ${test.estimatedTimeMins} dk',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () {
                      // TestSessionScreen'e test objesini gönderiyoruz
                      context.push('/test-session/${test.id}', extra: test);
                    },
                  ),
                );
              },
            ),
    );
  }
}
