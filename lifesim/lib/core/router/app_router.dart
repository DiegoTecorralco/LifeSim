import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const SplashPage();
      },
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginPage();
      },
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) {
        return const RegisterPage();
      },
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        return const ForgotPasswordPage();
      },
    ),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        return const DashboardPage();
      },
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return const ProfilePage();
      },
    ),
  ],
);