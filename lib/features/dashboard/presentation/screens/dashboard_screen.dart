import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Yönlendirme için eklendi
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart'; // Auth state'i dinlemek için eklendi

// 1. GÜNCELLEME: Sildiğimiz 'inventory_tab.dart' yerine
// az önce oluşturduğumuz 'test_list_tab.dart' import edildi.
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/test_list_tab.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0; // 0 = Testler, 1 = Profil

  // 2. GÜNCELLEME: Widget listesi güncellendi.
  // 'InventoryTab' yerine 'TestlerTab' geldi.
  static const List<Widget> _widgetOptions = <Widget>[
    TestlerTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();

    // 3. GÜNCELLEME: 'fetchInventory()' tetikleyicisi kaldırıldı.
    // Artık 'initState' boş (veya 2. Hafta'da testleri
    // çekmek için yeni bir tetikleyici eklenebilir).
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4. GÜNCELLEME: AppBar başlığı "Testler" veya "Profil"
    // olarak değişecek şekilde ayarlandı.
    final titles = ['Testlerim', 'Profil'];

    // --- YENİ DÜZELTME: Çıkış Dinleyicisini Buraya Taşıma ---
    // 'ProfileTab' yerine 'DashboardScreen' (her zaman aktif olan ana ekran)
    // 'authProvider'ı dinler.
    ref.listen(authProvider, (previousState, newState) {
      // Önceki durumun "giriş yapmış" olduğunu kontrol et
      final wasLoggedIn = previousState != null && previousState.token != null;

      // Yeni durumun "çıkış yapmış" olduğunu kontrol et
      final isLoggedOut = newState.token == null;

      // Eğer "giriş yapmış" durumdan "çıkış yapmış" duruma bir GEÇİŞ olduysa:
      if (wasLoggedIn && isLoggedOut) {
        // Güvenli bir şekilde 'LoginScreen'e yönlendir.
        context.go('/login');
      }
    });
    // --- DÜZELTME SONU ---

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // 5. GÜNCELLEME: Sekme adı "Envanter"den "Testler"e değiştirildi.
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined), // Yeni ikon
            label: 'Testler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
