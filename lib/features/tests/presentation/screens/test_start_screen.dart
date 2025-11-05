import 'package:flutter/material.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

class TestStartScreen extends StatelessWidget {
  final TestModel test;

  const TestStartScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${test.name} Başlat')),
      body: Center(
        child: Text(
          'Test "${test.name}" başlatılıyor...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
