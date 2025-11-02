// 1. Gerekli paketleri ve dosyaları içe aktarıyoruz
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:quvexai_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final token = await ref
          .read(authRepositoryProvider)
          .login(email, password);

      state = state.copyWith(isLoading: false, token: token);
      await ref.read(storageServiceProvider).writeToken(token);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(storageServiceProvider).deleteToken();

    state = AuthState.initial();
  }

  /// REGISTER (KAYIT OL) FONKSİYONU
  /// Arayüz (RegisterScreen) bu fonksiyonu çağıracak.
  Future<void> register(String email, String password) async {
    // try-catch bloğu (API hata verebilir)
    try {
      // ADIM A: YÜKLENİYOR IŞIĞINI YAK
      // Arayüze "Bekle" diyoruz.
      state = state.copyWith(isLoading: true, errorMessage: null);

      // ADIM B: "ARACI"YI ÇAĞIR
      // (G3'te yazdığımız 'authRepositoryProvider'ı oku
      // ve 'register' metodunu çağır)
      final token = await ref
          .read(authRepositoryProvider)
          .register(email, password);

      // (Bizim sahte 'DataSource'umuz 1s bekleyip,
      // "taken@test.com" hatasını kontrol edip,
      // yeni bir token döndürecek)

      // ADIM C: BAŞARILI DURUM (TOKEN IŞIĞINI YAK & KAYDET)
      // Giriş (Login) ile aynı işlemi yap:

      // 1. Token'ı Hafızaya Kaydet (G3, Görev 4)
      await ref.read(storageServiceProvider).writeToken(token);

      // 2. "Gösterge Paneli"ni Güncelle (Kullanıcıyı giriş yapmış say)
      state = state.copyWith(isLoading: false, token: token);
    } catch (e) {
      // ADIM D: HATA DURUMU (MOTOR ARIZA IŞIĞINI YAK)
      // (örn: "Bu e-posta zaten kullanımda")
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
