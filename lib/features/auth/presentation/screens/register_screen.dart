import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Adım 5'te burayı dolduracağız.
    // Şimdilik sadece ortada bir "Yükleniyor..." yazısı gösterelim.
    return const Scaffold(
      body: Center(child: Text('Register Ekranı - Yükleniyor...')),
    );
  }
}
