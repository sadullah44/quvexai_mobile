import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth (Giriş) Beynini import ediyoruz (Çıkışı dinlemek için)
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

// Sekmelerimizi import ediyoruz
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/test_list_tab.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0; // 0 = Testler, 1 = Profil

  // Sekme Listesi
  static const List<Widget> _widgetOptions = <Widget>[
    TestListTab(), // Test Listesi Sekmesi
    ProfileTab(), // Profil Sekmesi
  ];

  @override
  void initState() {
    super.initState();
    // Testleri burada çekmemize gerek yok,
    // çünkü 'TestListTab' kendi içinde (initState'inde) zaten çekiyor.
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Testlerim', 'Profil'];

    // --- ÇIKIŞ DİNLEYİCİSİ ---
    // Kullanıcı 'Profil' sekmesinden çıkış yaparsa,
    // token silinir ve bu dinleyici çalışır.
    ref.listen(authProvider, (previousState, newState) {
      final wasLoggedIn = previousState != null && previousState.token != null;
      final isLoggedOut = newState.token == null;

      // Eğer giriş halinden çıkış haline geçildiyse:
      if (wasLoggedIn && isLoggedOut) {
        context.go('/login'); // Login ekranına at
      }
    });
    // -------------------------

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex]), centerTitle: true),
      // Seçili sekmeyi göster
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // Alt Navigasyon Çubuğu
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
