import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  /// [writeToken] - Verilen token'ı şifreli hafızaya yazar.
  Future<void> writeToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
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
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('Secure Storage - Token Silme Hatası: $e');
    }
  }
}
// --- Riverpod Provider ---

final storageServiceProvider = Provider<StorageService>((ref) {
  // Sadece sınıfın bir örneğini (instance) oluştur ve döndür.
  return StorageService();
});
