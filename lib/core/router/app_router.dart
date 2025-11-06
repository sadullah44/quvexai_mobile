// 1. Gerekli kütüphaneleri ve ekranları içe aktarıyoruz
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_detail_screen.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_list_screen.dart'; // ✅ EKLENDİ
// (Diğer import'larınızın yanına)
// Henüz oluşturulmadı ama oluşturulacak (Kişi 2 görevi)
import 'package:quvexai_mobile/features/test_session/presentation/screens/test_session_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',

    routes: <GoRoute>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),

      GoRoute(
        path: '/tests',
        builder: (BuildContext context, GoRouterState state) {
          return const TestListScreen();
        },
      ),

      GoRoute(
        path: '/tests/:id',
        builder: (BuildContext context, GoRouterState state) {
          final test = state.extra as TestModel;
          return TestDetailScreen(test: test);
        },
      ),
      GoRoute(
        path: '/test-session/:testId', // Test ID'sini 'path'ten (adresten) alır
        builder: (BuildContext context, GoRouterState state) {
          // 'TestDetailScreen'den (Kişi 2) 'extra' ile gönderilen
          // Testin Adını (AppBar'da göstermek için) yakalıyoruz.
          final testName = state.extra as String;

          // Adres çubuğundan gelen 'testId'yi alıyoruz
          final testId = state.pathParameters['testId']!;

          // Bu bilgileri 'TestSessionScreen'e (Kişi 2'nin oluşturacağı ekran) iletiyoruz.
          return TestSessionScreen(testId: testId, testName: testName);
        },
      ),
    ],
  );
}
