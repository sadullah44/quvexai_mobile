import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/test_list_tab.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/profile_tab.dart';
import 'package:quvexai_mobile/core/notifications/notification_service.dart';
import 'package:quvexai_mobile/core/sync/sync_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TestListTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _checkSyncQueue();
  }

  Future<void> _initNotifications() async {
    // Günlük test hatırlatmasını planla
    final enabled = await NotificationService.instance.isDailyReminderEnabled();
    if (enabled) {
      NotificationService.instance.scheduleDailyTestReminder(
        hour: 20,
        minute: 0,
      );
    }
  }

  Future<void> _checkSyncQueue() async {
    // Kuyruk kontrolü
    final syncService = ref.read(syncServiceProvider);
    final queueSize = syncService.getQueueSize();

    if (queueSize > 0) {
      debugPrint("📦 $queueSize test senkronizasyon bekliyor");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Testlerim', 'Profil'];
    final syncService = ref.watch(syncServiceProvider);
    final queueSize = syncService.getQueueSize();

    // Çıkış dinleyicisi
    ref.listen(authProvider, (previousState, newState) {
      final wasLoggedIn = previousState != null && previousState.token != null;
      final isLoggedOut = newState.token == null;

      if (wasLoggedIn && isLoggedOut) {
        context.go('/login');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          // 🔥 Sync durumu göstergesi
          if (queueSize > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_upload),
                    tooltip: 'Bekleyen testler',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Bekleyen Testler'),
                          content: Text(
                            '$queueSize test senkronizasyon bekliyor.\n\n'
                            'İnternet bağlantısı geldiğinde otomatik olarak gönderilecektir.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Tamam'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.push('/settings');
                              },
                              child: const Text('Ayarlar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$queueSize',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // 🔥 Ayarlar butonu
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            label: 'Testler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
