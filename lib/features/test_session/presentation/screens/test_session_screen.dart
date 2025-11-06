import 'package:flutter/material.dart';

// Bu, Kişi 2'nin (Arayüz) daha sonra 'ConsumerWidget'a dönüştüreceği
// ve içini "Soru", "Cevap" vb. ile dolduracağı boş iskelettir.
class TestSessionScreen extends StatelessWidget {
  // 'app_router'dan (Harita) bu iki parametreyi alacak şekilde
  // constructor'ını (kurucusunu) hazırlıyoruz.
  final String testId;
  final String testName;

  const TestSessionScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 'app_router'dan gelen 'testName'i AppBar'da gösteriyoruz
        title: Text(testName),
      ),
      body: Center(
        child: Text(
          'Test Çözme Ekranı (Test ID: $testId). Arayüz (Kişi 2) burayı dolduracak.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
