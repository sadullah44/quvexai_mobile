import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

/// Bu sınıf API yerine mock veri sağlıyor
class TestApiDataSource {
  TestApiDataSource();

  Future<List<TestModel>> getTests() async {
    await Future.delayed(
      const Duration(seconds: 1),
    ); // API gecikmesi simülasyonu

    final mockTests = [
      TestModel(
        id: '1',
        name: 'Flutter Başlangıç Testi',
        category: 'Mobil Geliştirme',
        difficulty: 'Kolay',
        estimatedTimeMins: 10,
        description:
            'Bu test, Flutter temel bilgilerini ölçmek için hazırlanmıştır.',
        questions: [
          Question(
            id: 'q1',
            question: 'Flutter nedir?',
            options: [
              'Bir oyun motoru',
              'Bir mobil framework',
              'Bir veritabanı',
              'Bir programlama dili',
            ],
            answer: 'Bir mobil framework',
          ),
          Question(
            id: 'q2',
            question: 'StatelessWidget ne zaman kullanılır?',
            options: [
              'Durum gerekmiyorsa',
              'Her zaman',
              'Sadece form yaparken',
              'Hiçbir zaman',
            ],
            answer: 'Durum gerekmiyorsa',
          ),
        ],
      ),
      TestModel(
        id: '2',
        name: 'Veri Yapıları ve Algoritmalar',
        category: 'Bilgisayar Bilimi',
        difficulty: 'Orta',
        estimatedTimeMins: 20,
        description: 'Algoritma ve veri yapıları bilgisini ölçer.',
        questions: [
          Question(
            id: 'q1',
            question: 'En hızlı arama yöntemi hangisidir?',
            options: ['Linear Search', 'Binary Search', 'Bubble Sort', 'DFS'],
            answer: 'Binary Search',
          ),
          Question(
            id: 'q2',
            question: 'Stack veri yapısında hangi işlem LIFO’ya örnektir?',
            options: ['Push', 'Pop', 'Enqueue', 'Dequeue'],
            answer: 'Pop',
          ),
        ],
      ),
    ];

    return mockTests;
  }
}

/// Riverpod provider
final testApiDataSourceProvider = Provider<TestApiDataSource>((ref) {
  return TestApiDataSource();
});
