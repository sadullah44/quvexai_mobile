import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. GEREKLİ İMPORTLARI EKLEYELİM
// "Envanter Beyni"ni (G5'te yazdığınız) import ediyoruz
import 'package:quvexai_mobile/features/inventory/presentation/providers/inventory_provider.dart';
// "Giriş Beyni"ni (G3'te yazdığınız) import ediyoruz
import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

// Arkadaşınızın (Kişi 2) G5'te yazdığı (veya yazması gerektiği) Sekmeler
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/inventory_tab.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/qr_tab.dart';
// import 'package:quvexai_mobile/features/dashboard/presentation/tabs/profile_tab.dart'; // Bu dosya yokmuş

// 2. EKSİK OLAN "PROFILE_TAB" YERİNE GEÇİCİ BİR TANE OLUŞTURALIM
// (Arkadaşınız bu dosyayı yapmayı unutmuş, biz burada geçici bir tane yapalım)
class TempProfileTab extends ConsumerWidget {
  const TempProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. ÇIKIŞ YAP DİNLEYİCİSİNİ BURAYA, DOĞRU YERE ALALIM
    // (Daha önce initState'te yanlış yerdeydi)
    ref.listen(authProvider, (previous, next) {
      final wasLoggedIn = previous != null && previous.token != null;
      final isLoggedOut = next.token == null;
      if (wasLoggedIn && isLoggedOut) {
        context.go('/login');
      }
    });

    // 4. ÇIKIŞ YAP BUTONU
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        child: const Text('Çıkış Yap'),
        onPressed: () {
          ref.read(authProvider.notifier).logout();
        },
      ),
    );
  }
}

// ----------------- ANA DASHBOARD KODU -----------------

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  // 5. WIDGET LİSTESİNİ GÜNCELLEYELİM
  // (Arkadaşınızın 'profile_tab.dart'ı yerine 'TempProfileTab'ı kullanalım)
  static final List<Widget> _widgetOptions = <Widget>[
    const InventoryTab(),
    const QrTab(), // (Umarım arkadaşınız bunu yapmıştır, yoksa 'Text' ile değiştirin)
    const TempProfileTab(), // (Geçici 'Profil' sekmemiz)
  ];

  @override
  void initState() {
    super.initState();

    // 6. HATALI 'initState'İ DÜZELTELİM
    // --- DOĞRU KOD BUDUR ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // "Envanter Beyni"ne ('inventoryProvider') ulaş ve
      // 'fetchInventory' (veriyi çek) fonksiyonunu tetikle.
      // EKSİK OLAN KRİTİK PARÇA BUYDU.
      ref.read(inventoryProvider.notifier).fetchInventory();
    });
    // --- DÜZELTME SONU ---
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envanter Sistemi'),
        // 7. (Alternatif) Çıkış butonunu buraya da koyabilirdik,
        //    ancak sekme yapısı daha temiz.
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Envanter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Tara',
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
