import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/config/app_config.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'home_screen.g.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final emailAsync = ref.watch(currentUserEmailProvider);
    final userEmail = emailAsync.asData?.value ?? '...';

    final versionAsync = ref.watch(appVersionProvider);

    final profileState = ref.watch(profileControllerProvider);
    final targets = profileState.value?.targets;

    final limitKcal = targets?.dailyKcalGoal ?? 0.0;
    final limitCarbs = targets?.carbsGrams ?? 0.0;
    final limitProtein = targets?.proteinGrams ?? 0.0;
    final limitFat = targets?.fatGrams ?? 0.0;

    const currentKcal = 0.0;
    const currentCarbs = 0.0;
    const currentProtein = 0.0;
    const currentFat = 0.0;

    ref.listen<AppConnectionState>(connectivityServiceProvider, (prev, next) {
      if (next == AppConnectionState.offlineStartup) {
        context.go('/offline');
      } else if (next == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOffline),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next == AppConnectionState.online &&
          prev == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOnline),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    final connectionState = ref.watch(connectivityServiceProvider);
    final isOnline = connectionState == AppConnectionState.online;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Center(
          child: Tooltip(
            message: isOnline ? l10n.tooltipOnline : l10n.tooltipOffline,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? Colors.blue : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        title: Assets.icons.appIcon.image(
          height: 42,
          fit: BoxFit.contain,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ),
        ],
      ),

      endDrawer: Drawer(
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
                icon: Icons.person_outline,
                title: l10n.drawerProfile,
                onTap: () => Navigator.of(context).pop(),
              ),
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: l10n.drawerSettings,
                onTap: () => Navigator.of(context).pop(),
              ),
              _buildDrawerItem(
                icon: Icons.download_outlined,
                title: l10n.drawerExport,
                onTap: () => Navigator.of(context).pop(),
              ),
              _buildDrawerItem(
                icon: Icons.info_outline,
                title: l10n.drawerAbout,
                onTap: () => Navigator.of(context).pop(),
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
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
                      onTap: () => _launchUrl(AppConfig.githubApiUrl),
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
                      onTap: () => _launchUrl(AppConfig.githubAppUrl),
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
      ),

      body: Center(
        child: Text(
          l10n.homeTabLabel,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade300,
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildKcalBar(
                  label: l10n.macroKcal,
                  current: currentKcal,
                  limit: limitKcal,
                  color: Colors.orange.shade600,
                  l10n: l10n,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildCircularMacro(
                      l10n.macroCarbs,
                      currentCarbs,
                      limitCarbs,
                      Colors.blue.shade500,
                      'g',
                    ),
                    _buildCircularMacro(
                      l10n.macroProtein,
                      currentProtein,
                      limitProtein,
                      Colors.red.shade500,
                      'g',
                    ),
                    _buildCircularMacro(
                      l10n.macroFat,
                      currentFat,
                      limitFat,
                      Colors.amber.shade600,
                      'g',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildKcalBar({
    required String label,
    required double current,
    required double limit,
    required Color color,
    required AppLocalizations l10n,
  }) {
    final progress = limit > 0 ? (current / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = (limit - current).clamp(0.0, double.infinity).toInt();

    return Tooltip(
      message: '${current.toInt()} / ${limit.toInt()} kcal',
      triggerMode: TooltipTriggerMode.tap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                l10n.kcalRemaining(remaining),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMacro(
    String label,
    double current,
    double limit,
    Color color,
    String unit,
  ) {
    final progress = limit > 0 ? (current / limit).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4.5,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${current.toInt()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        '/${limit.toInt()}$unit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
