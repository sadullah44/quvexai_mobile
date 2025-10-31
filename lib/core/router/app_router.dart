// 1. Gerekli kütüphaneleri ve ekranları içe aktarıyoruz
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';

// 2. Rota sınıfımızı oluşturuyoruz
class AppRouter {
  // 3. 'router' adında, tüm uygulama tarafından erişilebilen (static)
  // ve değiştirilemeyen (final) bir GoRouter nesnesi tanımlıyoruz.
  static final GoRouter router = GoRouter(
    // 4. Uygulama ilk açıldığında hangi adrese yönleneceğini belirtiyoruz.
    initialLocation: '/login',

    // 5. 'routes' listesi, uygulamamızın tüm adres haritasıdır.
    routes: <GoRoute>[
      // 6. Splash Ekranı Rotası
      GoRoute(
        path: '/splash', // Web adresi gibi 'path' (yol) tanımlıyoruz
        builder: (BuildContext context, GoRouterState state) {
          // Bu adrese gidildiğinde hangi ekranın (widget)
          // inşa edileceğini (build) söylüyoruz.
          return const SplashScreen();
        },
      ),

      // 7. Login Ekranı Rotası
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),

      // 8. Register Ekranı Rotası
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),

      // 9. Dashboard Ekranı Rotası
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
    ],
  );
}
