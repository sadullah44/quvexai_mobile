import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth provider
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:quvexai_mobile/core/widgets/sync_status_widget.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Token yoksa login'e yönlendir
    if (authState.token == null) {
      Future.microtask(() {
        if (context.mounted) context.go('/login');
      });
      return const SizedBox();
    }

    // Kullanıcı bilgisi henüz yoksa yükleniyor göster
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profil resmi
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // İsim ve email
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

          // Sync durumu widget
          const SyncStatusWidget(),

          // İstatistik kartı
          Card(
            elevation: 2,
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
                  _buildStatItem(context, 'Ortalama Puan', '85'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Menü butonları
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
            onTap: () => context.push('/settings'),
          ),

          const SizedBox(height: 24),

          // Çıkış butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Yardımcı widgetlar
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
