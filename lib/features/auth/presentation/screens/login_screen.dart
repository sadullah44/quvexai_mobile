import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 👈 ekle, yönlendirme için gerekli

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                Image.asset('assets/fonts/images/logo.png', height: 120),
                const SizedBox(height: 32),

                Text(
                  "Hoş Geldiniz",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Giriş Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Giriş Yap"),
                  ),
                ),

                const SizedBox(height: 16),

                // Kayıt Ol Butonu 👇👇👇
                TextButton(
                  onPressed: () {
                    context.go('/register'); // 🔥 GoRouter yönlendirmesi
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
