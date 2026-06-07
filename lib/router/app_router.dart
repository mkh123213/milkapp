import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/repos/auth_repo.dart';
import '../features/settings/data/repos/settings_repo.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/shell/presentation/screens/main_shell.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/today/presentation/screens/today_receiving_screen.dart';
import '../features/today/presentation/screens/entry_details_screen.dart';
import '../features/today/presentation/screens/edit_weight_screen.dart';
import '../features/suppliers/presentation/screens/suppliers_list_screen.dart';
import '../features/suppliers/presentation/screens/supplier_details_screen.dart';
import '../features/suppliers/presentation/screens/add_edit_supplier_screen.dart';
import '../features/suppliers/presentation/screens/route_ordering_screen.dart';
import '../features/reports/presentation/screens/weekly_reports_list_screen.dart';
import '../features/reports/presentation/screens/weekly_report_details_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthRepo authRepo, SettingsRepo settingsRepo) {
  final authNotifier = _AuthStreamNotifier(authRepo.authStateChanges);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authRepo.currentUser != null;
      final loc = state.matchedLocation;
      final authRoutes = ['/login', '/signup', '/forgot-password', '/onboarding'];
      final isOnAuthRoute = authRoutes.contains(loc);

      if (!isLoggedIn && !isOnAuthRoute) {
        final onboarded = settingsRepo.getOnboarded();
        return onboarded ? '/login' : '/onboarding';
      }
      if (isLoggedIn && isOnAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayReceivingScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/suppliers',
              builder: (_, _) => const SuppliersListScreen(),
              routes: [
                GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (_, _) => const AddEditSupplierScreen()),
                GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (_, state) => AddEditSupplierScreen(supplierId: state.pathParameters['id'])),
                GoRoute(path: 'details/:id', parentNavigatorKey: _rootNavigatorKey, builder: (_, state) => SupplierDetailsScreen(supplierId: state.pathParameters['id']!)),
                GoRoute(path: 'route-order', parentNavigatorKey: _rootNavigatorKey, builder: (_, _) => const RouteOrderingScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reports',
              builder: (_, _) => const WeeklyReportsListScreen(),
              routes: [
                GoRoute(path: ':id', parentNavigatorKey: _rootNavigatorKey, builder: (_, state) => WeeklyReportDetailsScreen(reportId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/entry/:id', parentNavigatorKey: _rootNavigatorKey, builder: (_, state) => EntryDetailsScreen(entryId: state.pathParameters['id']!)),
      GoRoute(path: '/entry/:id/edit', parentNavigatorKey: _rootNavigatorKey, builder: (_, state) => EditWeightScreen(entryId: state.pathParameters['id']!)),
    ],
  );
}

class _AuthStreamNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  _AuthStreamNotifier(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
