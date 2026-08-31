import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/config/app_config.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_drawer.g.dart';

@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: AppDrawerBody(),
    );
  }
}

class AppDrawerBody extends ConsumerWidget {
  const AppDrawerBody({this.isDrawer = true, super.key});

  final bool isDrawer;

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final uri = Uri.parse(urlString);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showErrorSnackBar(context, l10n);
      }
    } on Object catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, l10n);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.errorOpenUrl),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final emailAsync = ref.watch(currentUserEmailProvider);
    final userEmail = emailAsync.asData?.value ?? l10n.loadingState;
    final versionAsync = ref.watch(appVersionProvider);

    final currentPath = GoRouterState.of(context).uri.path;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userEmail,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (isDrawer) {
                      Navigator.of(context).pop();
                    }
                    await ref
                        .read(authStateControllerProvider.notifier)
                        .logout();
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.drawerLogout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: l10n.drawerProfile,
                  isSelected: currentPath == '/profile',
                  targetRoute: '/profile',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.download_outlined,
                  title: l10n.drawerExport,
                  isSelected: currentPath == '/export',
                  targetRoute: '/export',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: l10n.drawerAbout,
                  isSelected: currentPath == '/about',
                  targetRoute: '/about',
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          const SizedBox(height: 8),
          versionAsync.when(
            data: (version) => Text(
              'v$version',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.madeByLabel,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: l10n.tooltipApiRepo,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _launchUrl(context, AppConfig.githubApiUrl),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Assets.icons.githubBlack.svg(
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: l10n.tooltipFrontendRepo,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _launchUrl(context, AppConfig.githubAppUrl),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Assets.icons.githubBlack.svg(
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required String targetRoute,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListTile(
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      onTap: () async {
        if (isDrawer) {
          Navigator.of(context).pop();
        }
        if (!isSelected) {
          Future.delayed(const Duration(milliseconds: 250), () async {
            if (context.mounted) {
              await context.push(targetRoute);
            }
          });
        }
      },
    );
  }
}
