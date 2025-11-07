// lib/features/tests/data/datasources/mock_test_data_source.dart
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

class TestApiDataSource {
  Future<List<TestModel>> getTests() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // API gecikmesi simülasyonu

    return [
      TestModel(
        id: '1',
        name: 'Flutter Başlangıç Testi',
        category: 'Mobil Geliştirme',
        difficulty: 'Kolay',
        estimatedTimeMins: 10,
        description: 'Bu test, Flutter temel bilgilerini ölçer.',
        questions: [
          Question(
            id: 'q1',
            question: 'Flutter nedir?',
            options: [
              'Web framework',
              'Mobil framework',
              'Mobil & Web framework',
              'Hiçbiri',
            ],
            answer: 'Mobil & Web framework',
          ),
          Question(
            id: 'q2',
            question: 'Flutter hangi dili kullanır?',
            options: ['Java', 'Dart', 'Kotlin', 'C#'],
            answer: 'Dart',
          ),
        ],
      ),
      TestModel(
        id: '2',
        name: 'Veri Yapıları Testi',
        category: 'Bilgisayar Bilimi',
        difficulty: 'Orta',
        estimatedTimeMins: 15,
        description: 'Algoritma ve veri yapıları testi.',
        questions: [
          Question(
            id: 'q1',
            question: 'Liste (List) veri yapısı sıralı mıdır?',
            options: ['Evet', 'Hayır'],
            answer: 'Evet',
          ),
        ],
      ),
    ];
  }
}
