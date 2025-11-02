// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart';
// "Gösterge Panelimiz" (InventoryState)
import 'package:quvexai_mobile/features/inventory/presentation/providers/inventory_state.dart';
// "Aracımız" (InventoryRepository - G5, Adım 9'da yaptık)
import 'package:quvexai_mobile/features/inventory/data/repositories/inventory_repository.dart';

// -------------------------------------------------------------------
// PARÇA 1: Provider (Arayüzün Erişim Noktası)
// -------------------------------------------------------------------

/// Bu, Arayüzün (UI) 'InventoryNotifier'a erişmek için kullanacağı
/// "anahtar yuvasıdır". Arkadaşınızın 'GridView'i bu provider'ı 'watch' (izleyecek).
final inventoryProvider = NotifierProvider<InventoryNotifier, InventoryState>(
  () => InventoryNotifier(),
);

// -------------------------------------------------------------------
// PARÇA 2: Notifier (Envanter Beyni / Yönetici)
// -------------------------------------------------------------------

/// Bu sınıf, 'InventoryState' gösterge panelini aktif olarak yöneten beyindir.
class InventoryNotifier extends Notifier<InventoryState> {
  // --- 1. Başlangıç Durumunu Ayarlama ---

  @override
  InventoryState build() {
    // 'Provider' ilk kez okunduğunda,
    // "Gösterge Paneli"ni varsayılan (boş) haliyle başlatır.
    return InventoryState.initial();
  }

  // --- 2. Ana İşlev (Action) ---

  /// [fetchInventory] - Envanter verisini 'Mock API'dan (JSON) getirir.
  /// Arkadaşınızın (Kişi 2) 'DashboardScreen'i ilk açıldığında
  /// bu fonksiyonu çağırması gerekecek.
  Future<void> fetchInventory() async {
    // 'try-catch' bloğu (JSON okuma hata verebilir)
    try {
      // ADIM A: YÜKLENİYOR IŞIĞINI YAK
      // Arayüze "Bekle, veriyi çekiyorum" diyoruz.
      // (Eski hataları da temizliyoruz)
      state = state.copyWith(isLoading: true, errorMessage: null);

      // ADIM B: "ARACI"YI ÇAĞIR (G5, Adım 9 Bağlantısı)
      // Riverpod 'ref' aracını kullanarak, "Aracı Fabrikası"ndan
      // bir 'InventoryRepository' istiyoruz ve 'getInventoryItems' metodunu çağırıyoruz.
      final itemsList = await ref
          .read(inventoryRepositoryProvider)
          .getInventoryItems();

      // (Bizim sahte 'DataSource'umuz 1 saniye bekleyip,
      // JSON'u okuyup, 'List<InventoryItemModel>' olarak buraya döndürecek)

      // ADIM C: BAŞARILI DURUM (Veri Listesi Işığını Yak)
      // "Gösterge Paneli"ni güncelliyoruz:
      // - isLoading ışığını 'false' (söndür) yapıyoruz.
      // - 'items' (ürün listesi) alanını, 'Aracı'dan gelen 'itemsList' ile dolduruyoruz.
      state = state.copyWith(isLoading: false, items: itemsList);
    } catch (e) {
      // ADIM D: HATA DURUMU (Motor Arıza Işığını Yak)
      // 'Repository' veya 'DataSource' bir hata "fırlatırsa" (throw), kod buraya düşer.

      // "Gösterge Paneli"ni güncelliyoruz:
      // - isLoading ışığını 'false' (söndür) yapıyoruz.
      // - 'errorMessage' ışığını (arıza mesajı) gelen hata 'e' ile yakıyoruz.
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
