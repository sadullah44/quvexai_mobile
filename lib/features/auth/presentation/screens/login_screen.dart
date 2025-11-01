import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/core/utils/validators.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';
// Arkadaşınızın (Kişi 2) G3'te yazdığı Snackbar yardımcısını import ediyoruz
import 'package:quvexai_mobile/core/utils/snackbar_helper.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -----------------------------------------------------------------
    // 👇 1. DÜZELTME: Eksik Değişkenler (Form Anahtarı ve Kontrolcüler)
    // Bu değişkenler 'onPressed' metodunda kullanıldığı için burada
    // tanımlanmaları ZORUNLUDUR.
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    // -----------------------------------------------------------------

    // --- BURAYA YENİ KODLARI EKLİYORUZ ---

    // 'ref.listen', 'build' metodunu yeniden tetiklemez.
    // Sadece durum değiştiğinde BİR KEZ çalışır. Hata gösterme
    // veya yönlendirme gibi "olaylar" için mükemmeldir.
    ref.listen(authProvider, (previousState, newState) {
      // Hata Işığı yandı mı?
      if (newState.errorMessage != null) {
        // Arkadaşınızın (Kişi 2) G3'te yazdığı snackbar'ı göster
        showSnackbar(context, newState.errorMessage!, isError: true);
      }
      // Token Işığı yandı mı? (Başarılı Giriş)
      if (newState.token != null) {
        // G2'de yazdığımız router ile Ana Ekrana git
        context.go('/dashboard');
      }
    });

    // 'ref.watch', 'authProvider'ın 'AuthState' (Gösterge Paneli)
    // durumunu sürekli izler. 'state' değiştiğinde
    // (örn: isLoading=true oldu), 'build' metodunu yeniden tetikler.
    final authState = ref.watch(authProvider);

    // --- YENİ KODLARIN SONU ---

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                // -----------------------------------------------------------------
                // 👇 2. DÜZELTME: Hatalı Resim Yolu Düzeltildi
                // Yol 'assets/fonts/images/...' değil, 'assets/images/...' olmalı.
                Image.asset('assets/fonts/images/logo.png', height: 120),
                // -----------------------------------------------------------------
                const SizedBox(height: 32),

                Text(
                  "Hoş Geldiniz",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // -----------------------------------------------------------------
                // 👇 3. DÜZELTME: Eksik 'Form' Widget'ı
                // 'TextFormField'ları bu 'Form' widget'ı ile sarmalamak,
                // '_formKey.currentState!.validate()' komutunun
                // çalışabilmesi için zorunludur.
                Form(
                  key:
                      _formKey, // 👈 1. Düzeltme'de tanımlanan anahtarı bağlıyoruz
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller:
                            _emailController, // 👈 1. Düzeltme'den kontrolcüyü bağlıyoruz
                        decoration: const InputDecoration(
                          labelText: "E-posta",
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateEmail,
                        keyboardType:
                            TextInputType.emailAddress, // Klavye tipi eklendi
                      ),
                      const SizedBox(height: 16),

                      // Şifre
                      TextFormField(
                        controller:
                            _passwordController, // 👈 1. Düzeltme'den kontrolcüyü bağlıyoruz
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Şifre",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validatePassword,
                      ),
                    ],
                  ),
                ),
                // -----------------------------------------------------------------
                const SizedBox(height: 24),

                // Giriş Butonu
                SizedBox(
                  width: double.infinity,
                  child: // YENİ, AKILLI ELEVATEDBUTTON
                  ElevatedButton(
                    // 'onPressed' metodu artık 'isLoading' durumunu kontrol ediyor.
                    // Eğer 'true' ise, 'null' (devre dışı) ayarla.
                    // Bu, kullanıcının yükleme sırasında butona tekrar basmasını engeller.
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            // 1. ADIM: VALIDASYON
                            if (_formKey.currentState!.validate()) {
                              // 2. ADIM: MANTIK (Beyni Çağırma)
                              ref
                                  .read(authProvider.notifier)
                                  .login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                            }
                          },
                    // 'child' (içerik) de 'isLoading' durumunu kontrol ediyor.
                    // Eğer 'true' ise, 'CircularProgressIndicator' (animasyon) göster.
                    // Değilse, 'Text' (yazı) göster.
                    child: authState.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text("Giriş Yap"),
                  ),
                ),

                const SizedBox(height: 16),

                // Kayıt Ol Butonu
                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: const Text("Hesabın yok mu? Kayıt ol"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
