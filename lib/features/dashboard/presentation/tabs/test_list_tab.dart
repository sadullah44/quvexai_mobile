import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bu, 2. Hafta'da dolduracağımız "Testler" sekmesinin boş halidir.
class TestlerTab extends ConsumerWidget {
  const TestlerTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Şimdilik sadece bir yer tutucu metin gösteriyoruz.
    return const Center(
      child: Text(
        'Psikolojik Testler Buraya Gelecek',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
