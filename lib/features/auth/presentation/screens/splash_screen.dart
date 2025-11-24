import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/core/storage/storage_service.dart';
// YENİ İMPORT: Auth Beyni
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Logo görünsün diye kısa bekleme
    await Future.delayed(const Duration(seconds: 2));

    // Token'ı oku
    final token = await ref.read(storageServiceProvider).readToken();

    if (!mounted) return;

    if (token != null) {
      // --- KRİTİK EKLEME ---
      // Token var! Kullanıcıyı Dashboard'a atmadan önce
      // kim olduğunu (ad, soyad, resim) yükle.
      await ref.read(authProvider.notifier).loadUser(token);
      // ---------------------

      if (!mounted) return; // Async işlem sonrası güvenlik kontrolü
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Yükleniyor...'),
          ],
        ),
      ),
    );
  }
}
