import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/decisions/presentation/pages/create_decision_page.dart';
import '../../features/decisions/presentation/pages/decisions_page.dart';
import '../../features/decisions/presentation/pages/edit_decision_page.dart';
import '../../features/variables/presentation/pages/variables_page.dart';
import '../../features/scenarios/presentation/pages/scenarios_page.dart';
import '../../features/simulation/presentation/pages/simulation_page.dart';

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

    GoRoute(
      path: '/decisions/create',
      builder: (context, state) {
        return const CreateDecisionPage();
      },
    ),

    GoRoute(
      path: '/decisions/edit',
      builder: (context, state) {
        final decision = state.extra as Map<String, dynamic>;

        return EditDecisionPage(
          decision: decision,
        );
      },
    ),

    GoRoute(
      path: '/decisions',
      builder: (context, state) {
        return const DecisionsPage();
      },
    ),

    // VARIABLES DE UNA DECISIÓN
    GoRoute(
      path: '/decisions/variables',
      builder: (context, state) {
        final decision = state.extra as Map<String, dynamic>;

        return VariablesPage(
          decision: decision,
        );
      },
    ),

    // ESCENARIOS DE UNA DECISIÓN
    GoRoute(
      path: '/decisions/scenarios',
      builder: (context, state) {
        final decision = state.extra as Map<String, dynamic>;

        return ScenariosPage(
          decision: decision,
        );
      },
    ),

    // SIMULACIÓN DE UNA DECISIÓN
    GoRoute(
      path: '/decisions/simulate',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return SimulationPage(
          decision: data['decision'] as Map<String, dynamic>,
          initialScenarioId: data['scenario_id']?.toString(),
        );
      },
    ),
  ],
);