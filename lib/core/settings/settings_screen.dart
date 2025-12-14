import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/core/notifications/notification_service.dart';
import 'package:quvexai_mobile/core/sync/sync_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyReminderEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled = await NotificationService.instance
        .areNotificationsEnabled();
    final dailyReminderEnabled = await NotificationService.instance
        .isDailyReminderEnabled();

    if (mounted) {
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _dailyReminderEnabled = dailyReminderEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // İzin iste
      final granted = await NotificationService.instance
          .requestAllPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bildirim izni verilmedi. Ayarlardan izin verebilirsiniz.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    await NotificationService.instance.setNotificationsEnabled(value);
    if (mounted) {
      setState(() => _notificationsEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Bildirimler açıldı ✅' : 'Bildirimler kapatıldı 🔕',
          ),
          backgroundColor: value ? Colors.green : Colors.grey,
        ),
      );
    }
  }

  Future<void> _toggleDailyReminder(bool value) async {
    await NotificationService.instance.setDailyReminderEnabled(value);
    if (mounted) {
      setState(() => _dailyReminderEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Günlük hatırlatma açıldı ✅'
                : 'Günlük hatırlatma kapatıldı 🔕',
          ),
          backgroundColor: value ? Colors.green : Colors.grey,
        ),
      );
    }
  }

  Future<void> _manualSync() async {
    final syncService = ref.read(syncServiceProvider);

    if (syncService.isSyncing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senkronizasyon zaten devam ediyor...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final queueSize = syncService.getQueueSize();
    if (queueSize == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senkronize edilecek test yok ✅'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Senkronize ediliyor...'),
            ],
          ),
        ),
      );
    }

    final report = await syncService.manualSync();

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(report.allSuccess ? 'Başarılı ✅' : 'Tamamlandı ⚠️'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Toplam: ${report.total} test'),
              Text(
                'Başarılı: ${report.success} test',
                style: const TextStyle(color: Colors.green),
              ),
              if (report.hasFailures)
                Text(
                  'Başarısız: ${report.failed} test',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncService = ref.watch(syncServiceProvider);
    final queueSize = syncService.getQueueSize();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), centerTitle: true),
      body: ListView(
        children: [
          // Bildirimler Bölümü
          _buildSectionHeader('Bildirimler'),
          SwitchListTile(
            title: const Text('Bildirimleri Aç'),
            subtitle: const Text('Tüm bildirimleri kontrol eder'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled ? Colors.green : Colors.grey,
            ),
          ),
          SwitchListTile(
            title: const Text('Günlük Test Hatırlatması'),
            subtitle: const Text('Her gün saat 20:00\'da hatırlatma'),
            value: _dailyReminderEnabled,
            onChanged: _notificationsEnabled ? _toggleDailyReminder : null,
            secondary: Icon(
              _dailyReminderEnabled ? Icons.alarm : Icons.alarm_off,
              color: _dailyReminderEnabled && _notificationsEnabled
                  ? Colors.blue
                  : Colors.grey,
            ),
          ),
          const Divider(),

          // Senkronizasyon Bölümü
          _buildSectionHeader('Senkronizasyon'),
          ListTile(
            leading: const Icon(Icons.cloud_sync, color: Colors.blue),
            title: const Text('Bekleyen Testler'),
            subtitle: Text(
              queueSize == 0
                  ? 'Tüm testler senkronize edildi ✅'
                  : '$queueSize test senkronizasyon bekliyor',
            ),
            trailing: queueSize > 0
                ? ElevatedButton.icon(
                    onPressed: _manualSync,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Şimdi Senkronize Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  )
                : null,
          ),
          if (queueSize > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'İnternet bağlantısı geldiğinde otomatik olarak gönderilecektir.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ),
          const Divider(),

          // Test İzinleri
          _buildSectionHeader('İzinler'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text('Bildirim İzinleri'),
            subtitle: const Text('Uygulama bildirim izinlerini kontrol et'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bildirim İzinleri'),
                  content: const Text(
                    'Bildirimleri kaçırmamak için:\n\n'
                    '• Android: Ayarlar > Uygulamalar > QuvexAI > Bildirimler\n'
                    '• iOS: Ayarlar > QuvexAI > Bildirimler\n\n'
                    'Tüm izinlerin açık olduğundan emin olun.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
