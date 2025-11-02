import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Gerekli tüm "Beyin" ve "Araç Kutusu" importları
import 'package:quvexai_mobile/core/utils/snackbar_helper.dart';
import 'package:quvexai_mobile/core/utils/validators.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

// 1. Arayüzü 'ConsumerWidget' yaptık ('ref'i kullanabilmek için)
class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Form Anahtarı ve 3 adet Kontrolcü
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController(); // <-- YENİ

    // 3. 'ref.listen' (Giriş (Login) ile aynı)
    //    Hata ışığını (Snackbar) veya Başarı ışığını (Yönlendirme) dinler
    ref.listen(authProvider, (previousState, newState) {
      if (newState.errorMessage != null) {
        showSnackbar(context, newState.errorMessage!, isError: true);
      }
      if (newState.token != null) {
        context.go('/dashboard');
      }
    });

    // 4. 'ref.watch' (Giriş (Login) ile aynı)
    //    'isLoading' ışığını izler ve UI'ın (butonun) güncellenmesini sağlar
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        // 'LoginScreen'e geri dönmek için otomatik bir 'geri' oku ekler
        title: const Text("Kayıt Ol"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            // 5. Form (Anahtarı atadık)
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (Login ile aynı)
                  Image.asset('assets/fonts/images/logo.png', height: 100),
                  const SizedBox(height: 24),
                  Text(
                    "Yeni Hesap Oluştur",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email (Login ile aynı)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "E-posta",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Şifre (Login ile aynı)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Şifre",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // --- YENİ ALAN ---
                  // Şifre Tekrarı
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Şifre Tekrarı",
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                      border: OutlineInputBorder(),
                    ),
                    // 6. ÖZEL VALIDATOR:
                    // 'value' (bu alanın değeri) ile
                    // '_passwordController.text' (diğer alanın değeri) karşılaştırılır
                    validator: (value) =>
                        Validators.validatePasswordConfirmation(
                          _passwordController.text,
                          value,
                        ),
                  ),
                  // --- YENİ ALAN SONU ---
                  const SizedBox(height: 24),

                  // Kayıt Ol Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // 7. YÜKLENME KONTROLÜ (Login ile aynı)
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              // 8. FORM KONTROLÜ (Login ile aynı)
                              if (_formKey.currentState!.validate()) {
                                // 9. BEYNİ ÇAĞIRMA (Farklı fonksiyon)
                                // 'login' yerine 'register' fonksiyonunu çağırıyoruz
                                ref
                                    .read(authProvider.notifier)
                                    .register(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                              }
                            },
                      // 10. YÜKLENME GÖSTERGESİ (Login ile aynı)
                      child: authState.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text("Kayıt Ol"),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Giriş Yap Butonu
                  TextButton(
                    onPressed: () {
                      context.go('/login'); // 'Login' ekranına geri dön
                    },
                    child: const Text("Zaten hesabın var mı? Giriş yap"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
