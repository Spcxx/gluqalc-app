import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/core/presentation/screens/offline_screen.dart';
import 'package:gluqalc_app/core/routing/scaffold_with_nav_bar.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:gluqalc_app/features/auth/presentation/screens/consent_screen.dart';
import 'package:gluqalc_app/features/auth/presentation/screens/verify_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateControllerProvider);

      final isLoggedIn = authState.asData?.value ?? false;
      final netState = ref.read(connectivityServiceProvider);
      final isOfflineStartup = netState == AppConnectionState.offlineStartup;

      final path = state.uri.path;

      if (isOfflineStartup) {
        if (path != '/offline') return '/offline';
        return null;
      } else {
        if (path == '/offline') {
          return isLoggedIn ? '/home' : '/auth';
        }
      }

      const publicPaths = ['/auth', '/verify', '/offline'];
      final isPublicPath = publicPaths.contains(path);

      const validPaths = [
        '/offline',
        '/auth',
        '/verify',
        '/home',
        '/settings',
        '/consents',
      ];
      final isValidPath = validPaths.contains(path);

      if (!isValidPath) {
        return isLoggedIn ? '/consents' : '/auth';
      }

      if (!isLoggedIn && !isPublicPath) {
        return '/auth';
      }

      if (isLoggedIn && (path == '/auth' || path == '/verify')) {
        return '/consents';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/offline',
        builder: (context, state) => const OfflineScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) => const VerifyScreen(),
      ),
      GoRoute(
        path: '/consents',
        builder: (context, state) => const ConsentScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Home'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Settings'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authStateControllerProvider, (_, _) => notifyListeners());
    _ref.listen(connectivityServiceProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}

class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // temp
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authStateControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Screen: $title',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
