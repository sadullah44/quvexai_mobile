// 1. Gerekli importlar
import 'dart:convert'; // JSON çözme (decode) için gerekli
import 'package:flutter/services.dart'; // 'rootBundle' (asset okuma) için gerekli
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod Provider için
import 'package:quvexai_mobile/features/inventory/data/models/inventory_item_model.dart';

/// Bu sınıf, 'inventory.json' dosyasından veriyi okumaktan
/// ve onu Dart Modellerine ('InventoryItemModel') dönüştürmekten
/// sorumlu olan "Veri Kaynağı"dır.
class MockInventoryDataSource {
  /// [getInventoryItems] - Tüm envanter ürünlerini getirir.
  Future<List<InventoryItemModel>> getInventoryItems() async {
    try {
      // 1. Ağ gecikmesini simüle et (UI'da 'loading' test edebilmek için)
      await Future.delayed(const Duration(milliseconds: 800));

      // 2. ADIM: JSON Dosyasını Oku
      // 'rootBundle', 'assets' klasörümüze erişmemizi sağlar.
      // 'loadString' ile 'inventory.json' dosyasını bir 'String' (metin) olarak yükleriz.
      final String jsonString = await rootBundle.loadString(
        'assets/mock/inventory.json',
      );

      // 3. ADIM: JSON Metnini Çöz (Decode)
      // Aldığımız ham metni (jsonString), Dart'ın anlayabileceği
      // bir 'List<dynamic>' (içinde 'Map'ler olan) yapıya dönüştürürüz.
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      // 4. ADIM: Modeli "Tercüme Et" (Mapping)
      // 'jsonList' (çözülmüş liste) üzerinde 'map' (dönüştürme) işlemi yaparız.
      // Listedeki *her bir* 'item' (ki bu bir 'Map<String, dynamic>'tir)
      // alır ve onu 'InventoryItemModel.fromJson' "tercümanına" göndeririz.
      // Sonuç olarak 'List<InventoryItemModel>' (Ürün Modeli Listesi) elde ederiz.
      return jsonList.map(
        (item) {
          return InventoryItemModel.fromJson(item as Map<String, dynamic>);
        },
      ).toList(); // '.map' bir 'Iterable' döndürür, '.toList()' ile Listeye çeviririz.
    } catch (e) {
      // Bir hata olursa (dosya bulunamazsa, JSON formatı bozuksa)
      print('MockInventoryDataSource Hata: $e');
      throw Exception('Envanter verisi yüklenemedi: $e');
    }
  }
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a MockInventoryDataSource sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final mockInventoryDataSourceProvider = Provider<MockInventoryDataSource>((
  ref,
) {
  // Sadece sınıfın bir örneğini (instance) oluştur ve döndür.
  return MockInventoryDataSource();
});
