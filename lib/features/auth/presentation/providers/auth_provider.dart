import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_state.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  // --- YENİ FONKSİYON: KULLANICI BİLGİLERİNİ YÜKLE ---
  /// Token'ı kullanarak API'den (veya Mock'tan) kullanıcının
  /// adını, mailini vb. çeker ve State'e yazar.
  Future<void> loadUser(String token) async {
    try {
      // 1. Aracıdan (Repository) kullanıcıyı iste
      final user = await ref.read(authRepositoryProvider).getUserProfile(token);

      // 2. Gelen kullanıcıyı State'e (Gösterge Paneline) yaz
      // Artık arayüz (UI), 'state.user.name' diyerek isme ulaşabilir.
      state = state.copyWith(user: user);
    } catch (e) {
      print("Kullanıcı bilgisi yüklenirken hata: $e");
      // Token geçersizse veya internet yoksa burada hata alabiliriz.
      // Şimdilik sadece logluyoruz. İleride burada oturumu kapatabiliriz.
    }
  }

  // --- GÜNCELLENMİŞ LOGIN FONKSİYONU ---
  Future<void> login(String email, String password) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 1. Token al
      final token = await ref
          .read(authRepositoryProvider)
          .login(email, password);

      // 2. Token'ı telefona kaydet
      await ref.read(storageServiceProvider).writeToken(token);

      // 3. State'i güncelle (Token var)
      state = state.copyWith(isLoading: false, token: token);

      // 4. (YENİ) Kullanıcı bilgilerini de hemen çek!
      await loadUser(token);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- GÜNCELLENMİŞ REGISTER FONKSİYONU ---
  Future<void> register(String email, String password) async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 1. Kayıt ol ve Token al
      final token = await ref
          .read(authRepositoryProvider)
          .register(email, password);

      // 2. Token'ı telefona kaydet
      await ref.read(storageServiceProvider).writeToken(token);

      // 3. State'i güncelle
      state = state.copyWith(isLoading: false, token: token);

      // 4. (YENİ) Kullanıcı bilgilerini de hemen çek!
      await loadUser(token);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- LOGOUT FONKSİYONU ---
  Future<void> logout() async {
    // Token'ı telefondan sil
    await ref.read(storageServiceProvider).deleteToken();

    // API'ye çıkış isteği at (opsiyonel ama iyi pratik)
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {} // Hata olsa bile devam et

    // State'i tamamen sıfırla (User ve Token silinir)
    state = AuthState.initial();
  }
}
