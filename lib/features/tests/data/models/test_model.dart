// 1. Equatable (Karşılaştırma için)
import 'package:equatable/equatable.dart';

/// Bu sınıf, 'Test' verisinin "kalıbıdır".
/// API'den gelen JSON'u, Dart kodunun anlayabileceği
/// bir 'Dart nesnesine' dönüştüren "tercümandır".
class TestModel extends Equatable {
  // 1. Alanlar (Postman'den gördüklerimiz)
  final String id;
  final String name;
  final String category;
  final int estimatedTimeMins;
  final String difficulty;

  // --- DÜZELTME: EKSİK ALANI EKLEME ---
  // Arkadaşınızın (Kişi 2) 'TestDetailScreen'de ihtiyaç duyduğu
  // 'description' (açıklama) alanını ekliyoruz.
  // API'de bu alan boş gelebileceği için 'nullable' (?) yaptık.
  final String? description;
  // --- DÜZELTME SONU ---

  // 2. Standart Kurucu (Constructor)
  const TestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedTimeMins,
    required this.difficulty,
    this.description, // <-- Buraya da ekledik
  });

  // 3. "Fabrika" Kurucusu (JSON TERCÜMANI)
  /// Bu 'fabrika' metodu, 'Map<String, dynamic>' (Flutter'ın
  /// JSON verisine verdiği ad) tipinde bir veri alır ve onu
  /// 'TestModel' nesnesine dönüştürür.
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      // API'nizden (veya sahte JSON'dan) gelen verinin
      // 'int' (sayı) olduğundan emin olun
      estimatedTimeMins: json['estimated_time_mins'] as int,
      difficulty: json['difficulty'] as String,

      // --- DÜZELTME: TERCÜMANA YENİ KURAL EKLEME ---
      // 'description' anahtarını JSON'dan oku.
      // 'as String?' -> Bu, 'null' olabileceği anlamına gelir.
      description: json['description'] as String?,
      // --- DÜZELTME SONU ---
    );
  }

  // 4. Equatable (Karşılaştırma) için gerekli
  @override
  List<Object?> get props {
    // --- DÜZELTME: 'props' LİSTESİNE EKLEME ---
    // 'description' alanını da karşılaştırmaya dahil et
    return [
      id,
      name,
      category,
      estimatedTimeMins,
      difficulty,
      description, // <-- Buraya da ekledik
    ];
    // --- DÜZELTME SONU ---
  }
}
