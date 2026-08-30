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

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

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
    final emailAsync = ref.watch(currentUserEmailProvider);
    final userEmail = emailAsync.asData?.value ?? 'Loading...';
    final versionAsync = ref.watch(appVersionProvider);

    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.4),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(authStateControllerProvider.notifier)
                          .logout();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(l10n.drawerLogout),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
            const Spacer(),
            const Divider(),
            const SizedBox(height: 8),
            versionAsync.when(
              data: (version) => Text(
                'v$version',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.madeByLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
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
                          Colors.grey.shade400,
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
                          Colors.grey.shade400,
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

    return ListTile(
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      onTap: () async {
        Navigator.of(context).pop();
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
