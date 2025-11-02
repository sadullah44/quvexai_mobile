import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous != null && previous.token != null;
      final isLoggedOut = next.token == null;
      if (wasLoggedIn && isLoggedOut) {
        context.go('/login');
      }
    });

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        onPressed: () => ref.read(authProvider.notifier).logout(),
        child: const Text('Çıkış Yap'),
      ),
    );
  }
}
