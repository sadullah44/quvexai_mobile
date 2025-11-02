import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                Image.asset('assets/fonts/images/logo.png', height: 120),
                const SizedBox(height: 32),

                Text(
                  "Kayıt Ol",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre (Tekrar)",
                    prefixIcon: Icon(Icons.lock_person_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Kayıt Ol"),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Zaten hesabın var mı? "),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
