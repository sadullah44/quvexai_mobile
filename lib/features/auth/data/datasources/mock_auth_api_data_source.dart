import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/features/auth/data/models/user_model.dart';

class MockAuthApiDataSource {
  /// [login] - Giriş yapma simülasyonu
  Future<String> login(String email, String password) async {
    // 1. Ağ gecikmesini simüle et
    await Future.delayed(const Duration(seconds: 1));

    // 2. Hata senaryosu testi için özel durum
    if (email == 'error@test.com') {
      throw Exception('Hatalı şifre veya e-posta (Mock Hata)');
    }

    // 3. ZEKİ MOCK MANTIĞI:
    // Token olarak rastgele şifre yerine E-POSTA adresini dönüyoruz.
    // Böylece 'Beni Hatırla' dediğimizde kimin girdiğini hatırlayabileceğiz.
    return email;
  }

  /// [register] - Kayıt olma simülasyonu
  Future<String> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Hata senaryosu
    if (email == 'taken@test.com') {
      throw Exception('Bu e-posta zaten kullanımda (Mock Hata)');
    }

    // Kayıt başarılı, token (e-posta) dön
    return email;
  }

  /// [logout] - Çıkış yapma simülasyonu
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// [getUserProfile] - Token'a (yani E-postaya) bakarak kullanıcıyı oluşturur.
  /// Bu sayede veritabanı olmadan dinamik kullanıcılar yaratırız.
  Future<UserModel> getUserProfile(String token) async {
    await Future.delayed(const Duration(seconds: 1));

    // Bizim sistemimizde Token = Email
    final email = token;

    // E-postadan İsim Türetme Mantığı:
    // "sadullah@gmail.com" -> "Sadullah"
    String name = "Kullanıcı";
    if (email.contains('@')) {
      name = email.split('@')[0]; // @ işaretinden öncesini al

      // İsmin baş harfini büyüt (Süsleme)
      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
      }
    }

    // Dinamik Kullanıcıyı Döndür
    return UserModel(
      id: 'user_${email.hashCode}', // E-postaya özel sabit bir ID üretir
      name: name,
      email: email,
      // Robohash servisi, e-postaya göre her seferinde AYNI ama kişiye ÖZEL
      // bir avatar (kedi/robot) üretir.
      profileImageUrl: 'https://robohash.org/$email?set=set4',
      totalTestsTaken:
          email.length, // Rastgele sayı yerine ismin uzunluğunu verelim :)
    );
  }
}

// --- Riverpod Provider ---
final mockAuthApiDataSourceProvider = Provider<MockAuthApiDataSource>((ref) {
  return MockAuthApiDataSource();
});
