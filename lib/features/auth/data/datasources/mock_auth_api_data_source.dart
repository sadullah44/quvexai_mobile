import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bu, bizim "sahte" API sunucumuzdur.
// Gerçek bir API'nin davranışlarını taklit eder.
class MockAuthApiDataSource {
  /// [login] - Sahte Giriş Fonksiyonu
  ///
  /// Başarılı olursa, sahte bir 'token' (String) döndürür.
  /// Başarısız olursa, bir 'Exception' (Hata) fırlatır.
  Future<String> login(String email, String password) async {
    // 1. Ağ gecikmesini (network latency) taklit etmek için 1 saniye bekliyoruz.
    //    Bu, "Yükleniyor" animasyonunu test edebilmemiz için çok önemlidir.
    await Future.delayed(const Duration(seconds: 1));

    // 2. Başarısızlık durumunu simüle etme:
    //    Eğer 'error@test.com' kullanılırsa, hata ver.
    if (email == 'error@test.com') {
      // 'throw' komutu, kodun "catch" bloğuna düşmesini sağlar.
      throw Exception('Hatalı şifre veya e-posta (Mock Hata)');
    }

    // 3. Başarılı durumu simüle etme:
    //    Diğer tüm giriş denemeleri başarılı sayılsın ve
    //    sahte bir token döndürsün.
    return 'xyz-123-sahte-token-kaynaktan-geldi';
  }

  /// [register] - Sahte Kayıt Olma Fonksiyonu
  /// (Register ekranı için)
  Future<String> register(String email, String password) async {
    // 1 saniye bekle
    await Future.delayed(const Duration(seconds: 1));

    // 2. Kayıt hatasını simüle etme:
    if (email == 'taken@test.com') {
      throw Exception('Bu e-posta zaten kullanımda (Mock Hata)');
    }

    // 3. Başarılı kayıt (yeni bir token döndür)
    return 'abc-987-yeni-kayit-tokeni';
  }

  /// [logout] - Sahte Çıkış Yapma Fonksiyonu
  Future<void> logout() async {
    // Sadece çıkış yapmış gibi davran, 1 saniye bekle.
    await Future.delayed(const Duration(milliseconds: 500));
    return; // Hiçbir şey döndürme (void)
  }
}

final mockAuthApiDataSourceProvider = Provider<MockAuthApiDataSource>((ref) {
  // Sadece sınıfın bir örneğini (instance) oluştur ve döndür.
  return MockAuthApiDataSource();
});
