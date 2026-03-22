import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/budget/screens/budget_setup_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../constants/app_constants.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppConstants.routeBudgetSetup, // TODO: revert to routeShell (then routeLogin) after auth is wired
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSignup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppConstants.routeShell,
        builder: (context, state) => const MainShell(),
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) => const MainShell(),
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeBudgetSetup,
        builder: (context, state) => const BudgetSetupScreen(),
      ),
    ],
  );
}
