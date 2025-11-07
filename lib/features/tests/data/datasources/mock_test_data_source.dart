import 'dart:convert'; // JSON çözme (decode) için gerekli
import 'package:flutter/services.dart'; // 'rootBundle' (asset okuma) için gerekli
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod Provider için
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart'; // "Tercümanımız"

/// Bu sınıf, 'test_list.json' dosyasından sahte veriyi okur.
/// Gerçek API hazır olana kadar 'TestApiDataSource'un yerini alır.
class MockTestDataSource {
  Future<List<TestModel>> getTests() async {
    try {
      // 1. Ağ gecikmesini simüle et (UI'da 'loading' test edebilmek için)
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. ADIM: JSON Dosyasını Oku
      // DİKKAT: 'test_api_data_source.dart' değil,
      // 'test_list.json' dosyasını okuyoruz.
      final String jsonString = await rootBundle.loadString(
        'assets/mock/test_list.json',
      );

      // 3. ADIM: JSON Metnini Çöz (Decode)
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      // 4. ADIM: Modeli "Tercüme Et" (Mapping)
      // "JSON Tercümanı"mızı ('TestModel.fromJson') kullanarak
      // ham JSON listesini, Dart Nesneleri listesine çeviriyoruz.
      return jsonList.map((item) {
        return TestModel.fromJson(item as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('MockTestDataSource Hata: $e');
      throw Exception('Sahte test verisi yüklenemedi: $e');
    }
  }
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a MockTestDataSource sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
/// 'TestRepository' (Aracı) bu provider'ı okuyacak.
final mockTestDataSourceProvider = Provider<MockTestDataSource>((ref) {
  return MockTestDataSource();
});
