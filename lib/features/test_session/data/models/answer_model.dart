// 1. Gerekli import (Riverpod state'leri için 'equatable' her zaman iyidir)
import 'package:equatable/equatable.dart';

/// Bu sınıf, bir "Soru"nun ('QuestionModel') sahip olabileceği
/// *tek bir* cevap seçeneğinin "kalıbıdır".
class AnswerModel extends Equatable {
  // 2. Alanlar (Fields)
  final String id; // Cevabın benzersiz kimliği (örn: 'a1', 'a2', 'a3')
  final String text; // Ekranda gösterilecek metin (örn: "Tamamen Katılıyorum")
  // (Puanlama için 'value' (değer) alanı da eklenebilir, şimdilik basit tutalım)

  // 3. Standart Kurucu (Constructor)
  const AnswerModel({required this.id, required this.text});

  // 4. "Fabrika" Kurucusu (Factory Constructor) - JSON TERCÜMANI
  /// API'den gelen 'Map<String, dynamic>' (çözülmüş JSON) verisini
  /// alır ve onu 'AnswerModel' nesnesine dönüştürür.
  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      // JSON'daki 'id' anahtarını oku -> 'id' alanına ata
      id: json['id'] as String,
      // JSON'daki 'text' anahtarını oku -> 'text' alanına ata
      text: json['text'] as String,
    );
  }

  // 5. Equatable (Karşılaştırma) için gerekli
  @override
  List<Object?> get props => [id, text];
}
