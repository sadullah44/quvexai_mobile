// 1. Gerekli kütüphaneleri ve ekranları içe aktarıyoruz
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/screens/test_detail_screen.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_list_screen.dart'; // ✅ EKLENDİ

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
    ],
  );
}
