import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quvexai_mobile/features/auth/presentation/providers/auth_provider.dart';

import 'package:quvexai_mobile/features/dashboard/presentation/tabs/inventory_tab.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/qr_tab.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/tabs/profile_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    InventoryTab(),
    QrTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(authProvider, (previous, next) {
        final wasLoggedIn = previous != null && previous.token != null;
        final isLoggedOut = next.token == null;
        if (wasLoggedIn && isLoggedOut) {
          context.go('/login');
        }
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
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
      ),
    );
  }
}
