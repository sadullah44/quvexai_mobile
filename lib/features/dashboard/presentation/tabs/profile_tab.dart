import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. "Beyin"i izle (Veri değişikliklerini yakala)
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // --- DÜZELTME: EMNİYET SÜBAPI ---
    // Eğer token 'null' olduysa (yani çıkış yapıldıysa)
    // ama biz hala bu ekrandaysak, bekleme yapma, hemen git!
    if (authState.token == null) {
      // 'build' sırasında yönlendirme hatası almamak için 'microtask' kullanıyoruz
      Future.microtask(() => context.go('/login'));
      return const SizedBox(); // Boş bir widget döndür
    }
    // --------------------------------

    // Eğer kullanıcı bilgisi henüz yüklenmediyse (ve token hala varsa)
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. PROFİL ARAYÜZÜ
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // --- Profil Resmi ---
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // --- İsim ve Email ---
          Text(
            user.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // --- İstatistik Kartı ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    'Çözülen Test',
                    user.totalTestsTaken.toString(),
                  ),
                  _buildStatItem(
                    context,
                    'Ortalama Puan',
                    '85',
                  ), // (İleride gerçek veri olacak)
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- Menü Butonları ---
          _buildMenuButton(
            context,
            icon: Icons.history,
            label: 'Geçmiş Testlerim',
            onTap: () => context.push('/test-history'),
          ),
          _buildMenuButton(
            context,
            icon: Icons.settings,
            label: 'Ayarlar',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // --- Çıkış Yap Butonu ---
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Çıkış işlemini başlat
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Çıkış Yap",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı Widget: İstatistik Kutucuğu
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  // Yardımcı Widget: Menü Butonu
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
