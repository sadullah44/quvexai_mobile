import 'package:quvexai_mobile/features/auth/data/datasources/mock_auth_api_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bu, bizim "Aracı" sınıfımızdır (Repository).
// "Beyin" (AuthNotifier) SADECE bu sınıfla konuşur.
class AuthRepository {
  // 1. BAĞIMLILIK (Dependency):
  // Bu 'Aracı', çalışmak için bir 'Veri Kaynağı'na (DataSource) ihtiyaç duyar.
  // Bu kaynağı dışarıdan (constructor ile) alır. Buna "Dependency Injection" denir.
  final MockAuthApiDataSource _apiDataSource;

  AuthRepository(this._apiDataSource);

  // 2. LOGIN (GİRİŞ YAP) FONKSİYONU
  // Beyin (AuthNotifier) bu fonksiyonu çağırır.
  Future<String> login(String email, String password) async {
    // 3. İŞİ DELEGE ETME:
    // 'AuthRepository' kendi başına bir iş yapmaz.
    // Sadece "Beyin"den gelen 'login' talebini,
    // kendisine verilmiş olan "Veri Kaynağı"na (DataSource) iletir.
    try {
      // Git, Veri Kaynağı'ndan ('_apiDataSource') 'login' yap ve cevabı bekle
      final token = await _apiDataSource.login(email, password);

      // Cevabı (token) Beyin'e (AuthNotifier) geri ilet
      return token;
    } catch (e) {
      // Eğer 'DataSource' hata fırlatırsa ('throw Exception'),
      // bu hatayı yakala ve 'Beyin'e (AuthNotifier) geri fırlat.
      rethrow;
    }
  }

  // 4. REGISTER (KAYIT OL) FONKSİYONU
  Future<String> register(String email, String password) async {
    try {
      // İşi Veri Kaynağı'na delege et
      final token = await _apiDataSource.register(email, password);
      return token;
    } catch (e) {
      rethrow;
    }
  }

  // 5. LOGOUT (ÇIKIŞ YAP) FONKSİYONU
  Future<void> logout() async {
    try {
      // İşi Veri Kaynağı'na delege et
      await _apiDataSource.logout();
    } catch (e) {
      rethrow;
    }
  }
}
// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a AuthRepository sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // 1. ADIM: Bağımlılığı (Veri Kaynağını) al
  // Riverpod'a "Bana 'mockAuthApiDataSourceProvider' fabrikasının
  // ürettiği nesneyi (DataSource) ver" diyoruz.
  final apiDataSource = ref.read(mockAuthApiDataSourceProvider);

  // 2. ADIM: Aracı'yı (Repository) inşa et
  // Aldığımız 'apiDataSource' nesnesini, 'AuthRepository'nin
  // kurucusuna (constructor) "enjekte ediyoruz".
  return AuthRepository(apiDataSource);
});
