// 1. Gerekli importlar
import 'package:flutter_riverpod/flutter_riverpod.dart';
// "Gösterge Panelimiz" (Canvas'taki dosyanız)
import 'package:quvexai_mobile/features/tests/presentation/providers/test_state.dart';
// "Aracımız" (Adım 9'da yaptık)
import 'package:quvexai_mobile/features/tests/data/repositories/test_repository.dart';

// -------------------------------------------------------------------
// PARÇA 1: Provider (Arayüzün Erişim Noktası)
// -------------------------------------------------------------------

/// Bu, Arayüzün (UI) 'TestNotifier'a erişmek için kullanacağı
/// "anahtar yuvasıdır". Arkadaşınızın (Kişi 2) 'TestlerTab' arayüzü
/// bu provider'ı 'watch' (izleyecek).
final testProvider = NotifierProvider<TestNotifier, TestState>(
  () => TestNotifier(),
);

// -------------------------------------------------------------------
// PARÇA 2: Notifier (Testler Beyni / Yönetici)
// -------------------------------------------------------------------

/// Bu sınıf, 'TestState' gösterge panelini aktif olarak yöneten beyindir.
class TestNotifier extends Notifier<TestState> {
  // --- 1. Başlangıç Durumunu Ayarlama ---

  @override
  TestState build() {
    // 'Provider' ilk kez okunduğunda (veya 'ref.watch' ilk kez çağrıldığında),
    // "Gösterge Paneli"ni varsayılan (boş) haliyle başlatır.
    return TestState.initial();
  }

  // --- 2. Ana İşlev (Action) ---

  /// [fetchTests] - Test verisini API'den getirir.
  /// Arkadaşınızın (Kişi 2) 'TestlerTab' arayüzü ilk açıldığında
  /// bu fonksiyonu çağırması gerekecek.
  Future<void> fetchTests() async {
    // 'try-catch' bloğu (API hataya düşebilir)
    try {
      // ADIM A: YÜKLENİYOR IŞIĞINI YAK
      // Arayüze "Bekle, veriyi çekiyorum" diyoruz.
      // (Eski hataları da temizliyoruz)
      state = state.copyWith(isLoading: true, errorMessage: null);

      // ADIM B: "ARACI"YI ÇAĞIR (Adım 9 Bağlantısı)
      // Riverpod 'ref' aracını kullanarak, "Aracı Fabrikası"ndan
      // ('testRepositoryProvider') bir 'TestRepository' istiyoruz
      // ve 'getTests' metodunu çağırıyoruz.
      final testsList = await ref.read(testRepositoryProvider).getTests();

      // (Bizim "Veri Hattımız" (Dio) API'ye gidecek,
      // "Token"ı ekleyecek, JSON'u alacak, "DataSource"
      // "Tercüman"ı (Model) çağıracak ve 'List<TestModel>'
      // olarak buraya döndürecek)

      // ADIM C: BAŞARILI DURUM (Veri Listesi Işığını Yak)
      // "Gösterge Paneli"ni güncelliyoruz:
      // - isLoading ışığını 'false' (söndür) yapıyoruz.
      // - 'tests' (test listesi) alanını, 'Aracı'dan gelen 'testsList' ile dolduruyoruz.
      state = state.copyWith(isLoading: false, tests: testsList);
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
