// 1. Equatable (Riverpod performans optimizasyonu için)
import 'package:equatable/equatable.dart';

/// Bu sınıf, API'den gelen /tests listesindeki TEK BİR TEST'in
/// Dart kodundaki "kalıbıdır" (modelidir).
/// Ham JSON metnini, kodumuzun anlayabileceği
/// bir 'Dart nesnesine' dönüştüren "tercümandır".
class TestModel extends Equatable {
  // 2. Alanlar (Fields): JSON'daki her 'anahtara' (key) karşılık gelir.
  final String id;
  final String name;
  final String category;
  final int estimatedTimeMins; // Tahmini süre (dakika)
  final String difficulty;

  // 3. Standart Kurucu (Constructor)
  const TestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedTimeMins,
    required this.difficulty,
  });

  // 4. "Fabrika" Kurucusu (Factory Constructor) - JSON TERCÜMANI
  /// Bu 'fabrika' metodu, 'Map<String, dynamic>' (Flutter'ın
  /// JSON verisine verdiği ad) tipinde bir veri alır ve onu
  /// 'TestModel' nesnesine dönüştürür.
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      // JSON'daki 'id' anahtarını oku -> 'id' alanına ata
      id: json['id'] as String,

      // JSON'daki 'name' anahtarını oku -> 'name' alanına ata
      name: json['name'] as String,

      // JSON'daki 'category' anahtarını oku -> 'category' alanına ata
      category: json['category'] as String,

      // JSON'daki 'estimated_time_mins' anahtarını oku -> 'estimatedTimeMins' alanına ata
      // (Dart'ta 'camelCase' (estimatedTimeMins),
      //  JSON'da 'snake_case' (estimated_time_mins)
      //  kullanmak yaygın bir standarttır, dönüşümü burada yaparız)
      estimatedTimeMins: json['estimated_time_mins'] as int,

      // JSON'daki 'difficulty' anahtarını oku -> 'difficulty' alanına ata
      difficulty: json['difficulty'] as String,
    );
  }

  // 5. Equatable (Karşılaştırma) için gerekli
  // Riverpod'ın, iki test nesnesinin "aynı" olup olmadığını
  // 'id'lerine bakarak anlamasını sağlar.
  @override
  List<Object?> get props => [
    id,
    name,
    category,
    estimatedTimeMins,
    difficulty,
  ];
}
