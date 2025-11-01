// 1. Gerekli paketleri ve dosyaları içe aktarıyoruz
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:quvexai_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart';

// -------------------------------------------------------------------
// PARÇA 1: Provider (Arayüzün Erişim Noktası)
// -------------------------------------------------------------------

/// Bu, Arayüzün (UI) 'AuthNotifier'a erişmek için kullanacağı
/// "anahtar yuvasıdır". UI bu provider'ı 'watch' (izleyecek) veya 'read' (okuyacak).
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

// -------------------------------------------------------------------
// PARÇA 2: Notifier (Motor Beyni / Yönetici)
// -------------------------------------------------------------------

/// Bu sınıf, 'AuthState' gösterge panelini aktif olarak yöneten beyindir.
/// Tüm mantık buradadır.
class AuthNotifier extends Notifier<AuthState> {
  // --- 1. Başlangıç Durumunu Ayarlama ---

  @override
  AuthState build() {
    // Bu 'build' metodu, provider ilk kez okunduğunda (kontak çevrildiğinde) çalışır.
    // 'AuthState.initial()' döndürerek gösterge panelinin
    // varsayılan halini (tüm ışıklar sönük) ayarlar.
    return AuthState.initial();
  }

  // --- 2. Ana İşlevler (Actions) ---

  /// LOGIN (GİRİŞ YAP) FONKSİYONU
  /// Arayüz (LoginScreen) bu fonksiyonu çağıracak.
  Future<void> login(String email, String password) async {
    // try-catch bloğu: Giriş işlemi risklidir (API hata verebilir).
    // Bu yüzden tüm işlemi "dene-yakala" bloğuna alırız.
    try {
      // ADIM A: YÜKLENİYOR IŞIĞINI YAK
      // Arayüze "Bekle" diyoruz.
      // 'copyWith' kullanarak mevcut durumun kopyasını alırız:
      // - isLoading ışığını 'true' yaparız.
      // - Varsa eski hata mesajını 'null' ile temizleriz.
      // ... try bloğunun içindeyiz ...
      state = state.copyWith(isLoading: true, errorMessage: null);

      // --- SİLDİĞİNİZ KODUN YERİNE BU SATIRI EKLEYİN ---
      // Riverpod 'ref' aracını kullanarak, "Aracı Fabrikası"ndan
      // bir 'AuthRepository' istiyoruz ve onun 'login' metodunu çağırıyoruz.
      final token = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      // ---------------------------------------------------

      // ADIM B: BAŞARILI DURUM (TOKEN IŞIĞINI YAK)
      // const mockToken = "xyz-123-fake-token"; // <-- BU SATIRI DA SİLİN

      // Gösterge panelini güncelliyoruz:
      // - isLoading ışığını 'false' (söndür) yapıyoruz.
      // - token ışığını (anahtarını) 'Aracı'dan gelen 'token' ile yakıyoruz.
      state = state.copyWith(isLoading: false, token: token);
      await ref.read(storageServiceProvider).writeToken(token);
      // ... catch bloğu devam ediyor ...
    } catch (e) {
      // ADIM C: HATA DURUMU (MOTOR ARIZA IŞIĞINI YAK)
      // 'try' bloğunda bir hata "fırlatılırsa" (throw), kod buraya düşer.

      // Gösterge panelini güncelliyoruz:
      // - isLoading ışığını 'false' (söndür) yapıyoruz.
      // - errorMessage ışığını (arıza mesajı) gelen hata 'e' ile yakıyoruz.
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// LOGOUT (ÇIKIŞ YAP) FONKSİYONU
  Future<void> logout() async {
    // (GÖREV 4'te burada 'StorageService' ile token'ı telefondan sileceğiz)
    await ref.read(storageServiceProvider).deleteToken();
    // Gösterge panelini tamamen sıfırla (başlangıç haline döndür).
    state = AuthState.initial();
  }
}
