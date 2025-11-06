import 'dart:convert'; // JSON çözme (decode) için gerekli
import 'package:flutter/services.dart'; // 'rootBundle' (asset okuma) için gerekli
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod Provider için
// 1. "Soru Tercümanı"mızı (G3, Adım 3'te yaptık) import ediyoruz
import 'package:quvexai_mobile/features/test_session/data/models/question_model.dart';

/// Bu sınıf, 'test_session.json' dosyasından sahte Soru/Cevap verisini okur.
/// Gerçek API hazır olana kadar 'DataSource' (Veri Kaynağı) görevini görür.
class TestSessionDataSource {
  /// [getTestQuestions] - Verilen 'testId' için soruları getirir.
  /// (Şimdilik 'testId'yi KULLANMIYORUZ, her teste aynı sahte soruları veriyoruz)
  Future<List<QuestionModel>> getTestQuestions(String testId) async {
    try {
      // 1. Ağ gecikmesini simüle et (UI'da 'loading' test edebilmek için)
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. ADIM: JSON Dosyasını Oku
      // 'rootBundle', 'assets' klasörümüze erişmemizi sağlar.
      // 'loadString' ile 'test_session.json' dosyasını bir 'String' (metin) olarak yükleriz.
      final String jsonString = await rootBundle.loadString(
        'assets/mock/test_session.json',
      );

      // 3. ADIM: JSON Metnini Çöz (Decode)
      // Aldığımız ham metni (jsonString), Dart'ın anlayabileceği
      // bir 'List<dynamic>' (içinde 'Map'ler olan) yapıya dönüştürürüz.
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      // 4. ADIM: Modeli "Tercüme Et" (Mapping)
      // 'jsonList' (çözülmüş liste) üzerinde 'map' (dönüştürme) işlemi yaparız.
      // Listedeki *her bir* 'item' (ki bu bir 'Map<String, dynamic>'tir)
      // alır ve onu 'QuestionModel.fromJson' "tercümanına" göndeririz.
      return jsonList.map(
        (item) {
          return QuestionModel.fromJson(item as Map<String, dynamic>);
        },
      ).toList(); // '.map' bir 'Iterable' döndürür, '.toList()' ile Listeye çeviririz.
    } catch (e) {
      // Bir hata olursa (dosya bulunamazsa, JSON formatı bozuksa)
      print('TestSessionDataSource Hata: $e');
      throw Exception('Test soruları yüklenemedi: $e');
    }
  }
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a TestSessionDataSource sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final testSessionDataSourceProvider = Provider<TestSessionDataSource>((ref) {
  // Sadece sınıfın bir örneğini (instance) oluştur ve döndür.
  return TestSessionDataSource();
});
