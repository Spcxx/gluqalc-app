import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/core/presentation/screens/offline_screen.dart';
import 'package:gluqalc_app/features/about/presentation/screens/about_screen.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:gluqalc_app/features/auth/presentation/screens/consent_screen.dart';
import 'package:gluqalc_app/features/auth/presentation/screens/verify_screen.dart';
import 'package:gluqalc_app/features/home/presentation/screens/home_screen.dart';
import 'package:gluqalc_app/features/home/presentation/screens/meal_entry_details_screen.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/features/stats/presentation/screens/export_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

const _validRoutePatterns = [
  '/offline',
  '/auth',
  '/verify',
  '/home',
  '/about',
  '/consents',
  '/profile-setup',
  '/profile',
  '/export',
  '/meal-entry-details/:entryId',
];

final List<RegExp> _compiledRouteRegexes = _validRoutePatterns.map((pattern) {
  final regexPattern =
      '^${pattern.replaceAllMapped(
        RegExp(r':\w+'),
        (match) => '[^/]+',
      )}\$';
  return RegExp(regexPattern);
}).toList();

bool _isPathValid(String path) {
  for (final regex in _compiledRouteRegexes) {
    if (regex.hasMatch(path)) return true;
  }
  return false;
}

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

      final isValidPath = _isPathValid(path);

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
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) {
          final isEditing = state.uri.queryParameters['edit'] == 'true';
          return ProfileSetupScreen(isEditing: isEditing);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ProfileGuard(
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProfileGuard(child: ProfileScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProfileGuard(child: AboutScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/export',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProfileGuard(child: ExportScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/meal-entry-details/:entryId',
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          final categoryId = state.uri.queryParameters['categoryId'] ?? '';
          return MealEntryDetailsScreen(
            entryId: entryId,
            categoryId: categoryId,
          );
        },
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

class ProfileGuard extends ConsumerWidget {
  const ProfileGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return profileState.when(
      data: (profile) {
        if (profile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/profile-setup');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.errorTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logoutTooltip,
              onPressed: () async {
                await ref.read(authStateControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingProfile,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(profileControllerProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.tryAgainButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
