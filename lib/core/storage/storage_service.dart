// 1. Gerekli paketi içe aktarıyoruz
// Bu paket, Gün 1'de 'pubspec.yaml'a eklenmişti.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bu sınıf, telefonun şifreli hafızasıyla (Keychain/Keystore)
/// konuşmaktan sorumlu olan tek "uzmandır".
class StorageService {
  // 2. FlutterSecureStorage aracının bir örneğini (instance) oluşturuyoruz.
  final _storage = const FlutterSecureStorage();

  // 3. Hafızaya yazarken kullanacağımız "anahtar" (key).
  //    Bu, veritabanındaki "sütun adı" gibidir.
  static const _tokenKey = 'auth_token';

  /// [writeToken] - Verilen token'ı şifreli hafızaya yazar.
  Future<void> writeToken(String token) async {
    try {
      // 'auth_token' anahtarıyla verilen 'token' değerini kaydet
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      // Hata olursa (örn: hafıza dolu, izin yok)
      print('Secure Storage - Token Yazma Hatası: $e');
    }
  }

  /// [readToken] - Hafızadaki token'ı okur.
  Future<String?> readToken() async {
    try {
      // 'auth_token' anahtarındaki değeri oku
      // Değer bulursa 'String' döner, bulamazsa 'null' döner.
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Secure Storage - Token Okuma Hatası: $e');
      return null;
    }
  }

  /// [deleteToken] - Hafızadaki token'ı siler. (Logout için)
  Future<void> deleteToken() async {
    try {
      // 'auth_token' anahtarındaki değeri sil
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('Secure Storage - Token Silme Hatası: $e');
    }
  }
}
// --- Riverpod Provider ---

/// Bu "sağlayıcı", Riverpod'a StorageService sınıfını
/// nasıl "inşa edeceğini" (oluşturacağını) öğreten "fabrika" tarifidir.
final storageServiceProvider = Provider<StorageService>((ref) {
  // Sadece sınıfın bir örneğini (instance) oluştur ve döndür.
  return StorageService();
});
