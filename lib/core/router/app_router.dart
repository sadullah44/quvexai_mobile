import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_detail_screen.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_list_screen.dart';
import 'package:quvexai_mobile/features/test_session/presentation/screens/test_session_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: <GoRoute>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/tests',
        builder: (context, state) => const TestListScreen(),
      ),
      GoRoute(
        path: '/tests/:id',
        builder: (context, state) {
          final test = state.extra as TestModel;
          return TestDetailScreen(test: test);
        },
      ),
      // ✅ Düzeltildi: Artık TestModel alıyor, testName değil
      GoRoute(
        path: '/test-session/:testId',
        builder: (context, state) {
          final test = state.extra as TestModel; // Test nesnesi geliyor
          final testId = state.pathParameters['testId']!;
          return TestSessionScreen(testId: testId, testName: test.name);
        },
      ),
    ],
  );
}
