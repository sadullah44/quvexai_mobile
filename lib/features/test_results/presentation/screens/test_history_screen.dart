import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/test_history_provider.dart';

class TestHistoryScreen extends ConsumerStatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  ConsumerState<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends ConsumerState<TestHistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testHistoryProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Geçmişim')),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.history.isEmpty) {
            return const Center(
              child: Text(
                'Henüz çözülmüş bir test yok.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final result = state.history[index];
              final formattedDate = DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(result.completedAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(result.totalScore.toInt().toString()),
                  ),
                  title: const Text('Test Sonucu'),
                  subtitle: Text(formattedDate),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/test-results/${result.sessionId}');
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
