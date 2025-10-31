import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Adım 5'te burayı dolduracağız.
    // Şimdilik sadece ortada bir "Yükleniyor..." yazısı gösterelim.
    return const Scaffold(
      body: Center(child: Text('Dashboard Ekranı - Yükleniyor...')),
    );
  }
}
