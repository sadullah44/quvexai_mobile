// Bu dosyaya "mixin" yazmak yerine, statik metotları olan bir "class"
// yazmak, başlamak için daha kolay ve temiz bir yöntemdir.

class Validators {
  /// [validateEmail] - Email doğrulaması yapar.
  ///
  /// Flutter Form 'validator' fonksiyonları şu kurala uyar:
  /// - Girdi geçerliyse: 'null' döndürür.
  /// - Girdi geçersizse: Hata mesajını (String) döndürür.
  static String? validateEmail(String? value) {
    // 1. Kural: Boş olamaz
    if (value == null || value.isEmpty) {
      return 'Lütfen bir e-posta adresi girin.';
    }

    // 2. Kural: Geçerli bir e-posta formatında olmalı
    // Bu, "RegExp" (Regular Expression) denilen bir kalıptır.
    // İnternetteki en yaygın email kontrol kalıbıdır.
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Lütfen geçerli bir e-posta adresi girin.';
    }

    // Tüm kurallar geçildiyse, hata yok demektir.
    return null;
  }

  /// [validatePassword] - Şifre doğrulaması yapar.
  static String? validatePassword(String? value) {
    // 1. Kural: Boş olamaz
    if (value == null || value.isEmpty) {
      return 'Lütfen bir şifre girin.';
    }

    // 2. Kural: Minimum uzunlukta olmalı
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }

    // Tüm kurallar geçildiyse, hata yok demektir.
    return null;
  }

  /// [validateRequiredField] - Genel "Boş Bırakılamaz" alan
  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Lütfen $fieldName alanını doldurun.';
    }
    return null;
  }

  /// [validatePasswordConfirmation] - Şifre tekrarı doğrulaması
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (password != confirmation) {
      return 'Şifreler uyuşmuyor.';
    }
    return null;
  }
}
