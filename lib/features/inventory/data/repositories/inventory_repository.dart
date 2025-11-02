// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/inventory/data/datasources/mock_inventory_data_source.dart';
import 'package:quvexai_mobile/features/inventory/data/models/inventory_item_model.dart';

/// Bu, "Envanter Beyni"nin ('InventoryNotifier') konuşacağı "Aracı"dır (Repository).
/// Görevi, "Beyin"den gelen talebi "Veri Kaynağı"na iletmektir.
class InventoryRepository {
  // 2. BAĞIMLILIK:
  // Bu 'Aracı', çalışmak için bir 'Veri Kaynağı'na (DataSource) ihtiyaç duyar.
  final MockInventoryDataSource _apiDataSource;

  // 3. BAĞIMLILIK ENJEKSİYONU (Constructor):
  // Bu bağımlılığı (DataSource) dışarıdan alır.
  InventoryRepository(this._apiDataSource);

  /// [getInventoryItems] - Envanter ürünlerini getirir.
  /// "Beyin" (Notifier) bu fonksiyonu çağırır.
  Future<List<InventoryItemModel>> getInventoryItems() async {
    // 4. İŞİ DELEGE ETME:
    // 'Repository' mantık çalıştırmaz, sadece talebi 'DataSource'a iletir.
    try {
      // Git, Veri Kaynağı'ndan ('_apiDataSource') 'getInventoryItems' yap
      // ve cevabı (List<InventoryItemModel>) bekle.
      final items = await _apiDataSource.getInventoryItems();

      // Cevabı "Beyin"e (Notifier) geri ilet.
      return items;
    } catch (e) {
      // Eğer 'DataSource' hata fırlatırsa ('throw Exception'),
      // bu hatayı yakala ve "Beyin"e geri fırlat.
      rethrow;
    }
  }
}

// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a InventoryRepository sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  // 1. ADIM: Bağımlılığı (Veri Kaynağını) al
  // Riverpod'a "Bana 'mockInventoryDataSourceProvider' fabrikasının
  // ürettiği nesneyi (DataSource) ver" diyoruz.
  final apiDataSource = ref.read(mockInventoryDataSourceProvider);

  // 2. ADIM: Aracı'yı (Repository) inşa et
  // Aldığımız 'apiDataSource' nesnesini, 'InventoryRepository'nin
  // kurucusuna (constructor) "enjekte ediyoruz".
  return InventoryRepository(apiDataSource);
});
