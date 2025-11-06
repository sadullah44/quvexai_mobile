// 1. Gerekli importlar
import 'package:equatable/equatable.dart';
// 2. Az önce oluşturduğumuz "Cevap Modelini" import ediyoruz
import 'package:quvexai_mobile/features/test_session/data/models/answer_model.dart';

/// Bu sınıf, bir testteki *tek bir* sorunun "kalıbıdır".
class QuestionModel extends Equatable {
  // 3. Alanlar (Fields)
  final String id; // Sorunun benzersiz kimliği (örn: 'q1', 'q2')
  final String text; // Ekranda gösterilecek soru metni
  final String questionType; // Soru tipi (örn: 'likert', 'multiple_choice')

  // 4. İLİŞKİLİ MODEL:
  //    Bir sorunun, bir "Cevap Modeli" listesi ('List<AnswerModel>') vardır.
  final List<AnswerModel> answers;

  // 5. Standart Kurucu (Constructor)
  const QuestionModel({
    required this.id,
    required this.text,
    required this.questionType,
    required this.answers,
  });

  // 6. "Fabrika" Kurucusu (Factory Constructor) - JSON TERCÜMANI
  /// API'den gelen 'Map<String, dynamic>' (çözülmüş JSON) verisini
  /// alır ve onu 'QuestionModel' nesnesine dönüştürür.
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // 7. AŞAMA 1: 'answers' listesini (iç içe JSON) "tercüme et"
    // 'answers' anahtarındaki JSON listesini ('List<dynamic>') al
    final answersListJson = json['answers'] as List<dynamic>;

    // Bu listeyi 'map' (dönüştür) işlemiyle 'List<AnswerModel>'e çevir
    // Her bir 'answerJson' öğesi için 'AnswerModel.fromJson' "tercümanını" çağır
    final List<AnswerModel> answersList = answersListJson.map((answerJson) {
      return AnswerModel.fromJson(answerJson as Map<String, dynamic>);
    }).toList(); // Sonucu Listeye dönüştür

    // 8. AŞAMA 2: 'QuestionModel'i inşa et
    return QuestionModel(
      // JSON'daki 'id' anahtarını oku -> 'id' alanına ata
      id: json['id'] as String,
      // JSON'daki 'text' anahtarını oku -> 'text' alanına ata
      text: json['text'] as String,
      // JSON'daki 'question_type' anahtarını oku -> 'questionType' alanına ata
      questionType: json['question_type'] as String,

      // AŞAMA 1'de tercüme ettiğimiz 'answersList'i buraya ata
      answers: answersList,
    );
  }

  // 9. Equatable (Karşılaştırma) için gerekli
  @override
  List<Object?> get props => [id, text, questionType, answers];
}
