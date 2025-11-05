import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Kişi 1'in (benim) oluşturduğu "Testler Beyni"ni import et
import 'package:quvexai_mobile/features/tests/presentation/providers/test_provider.dart';
// Az önce (Adım 3) oluşturduğun "Test Kartı" widget'ını import et
import 'package:quvexai_mobile/features/tests/presentation/widgets/test_card.dart';

/// Bu, 'Dashboard'daki 'Testler' sekmesinin ana arayüzüdür.
class TestListTab extends ConsumerStatefulWidget {
  const TestListTab({super.key});

  @override
  ConsumerState<TestListTab> createState() => _TestListTabState();
}

class _TestListTabState extends ConsumerState<TestListTab> {
  // --- 1. VERİYİ TETİKLEME (Fetch) ---
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testProvider.notifier).fetchTests();
    });
  }

  // --- 2. ARAYÜZÜ (UI) ÇİZME ---
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Testler yüklenemedi: ${state.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(testProvider.notifier).fetchTests();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.tests.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.tests.length,
        itemBuilder: (context, index) {
          final test = state.tests[index];
          return TestCard(test: test);
        },
      );
    }

    return const Center(child: Text('Gösterilecek test bulunamadı.'));
  }
}
