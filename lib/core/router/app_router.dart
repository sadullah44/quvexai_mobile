import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:quvexai_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:quvexai_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_list_screen.dart';
import 'package:quvexai_mobile/features/tests/presentation/screens/test_detail_screen.dart';
import 'package:quvexai_mobile/features/test_session/presentation/screens/test_session_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/tests', builder: (_, __) => const TestListScreen()),
      GoRoute(
        path: '/tests/:id',
        builder: (_, state) {
          final test = state.extra as TestModel;
          return TestDetailScreen(test: test);
        },
      ),
      GoRoute(
        path: '/test-session/:testId',
        builder: (_, state) {
          final test =
              state.extra as TestModel; // extra ile test objesi geliyor
          return TestSessionScreen(test: test);
        },
      ),
    ],
  );
}
