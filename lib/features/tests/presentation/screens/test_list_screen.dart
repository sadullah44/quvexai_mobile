import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import 'package:quvexai_mobile/features/tests/data/datasources/test_api_data_source.dart';

class TestListScreen extends ConsumerWidget {
  const TestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testApi = ref.watch(testApiDataSourceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Listesi')),
      body: FutureBuilder<List<TestModel>>(
        future: testApi.getTests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          final tests = snapshot.data ?? [];

          if (tests.isEmpty) {
            return const Center(child: Text('Hiç test bulunamadı.'));
          }

          return ListView.builder(
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    context.push('/tests/${test.id}', extra: test);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
