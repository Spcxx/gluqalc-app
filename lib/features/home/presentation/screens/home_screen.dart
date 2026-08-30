import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/core/presentation/widgets/app_drawer.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileState = ref.watch(profileControllerProvider);
    final targets = profileState.value?.targets;

    final limitKcal = targets?.dailyKcalGoal ?? 1.0;
    final limitCarbs = targets?.carbsGrams ?? 1.0;
    final limitProtein = targets?.proteinGrams ?? 1.0;
    final limitFat = targets?.fatGrams ?? 1.0;

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
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next == AppConnectionState.online &&
          prev == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOnline),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
                color: isOnline ? Colors.blue : colorScheme.error,
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
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Center(
        child: profileState.isLoading
            ? const CircularProgressIndicator()
            : Text(
                l10n.homeTabLabel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
                  context: context,
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
                      context: context,
                      label: l10n.macroCarbs,
                      current: currentCarbs,
                      limit: limitCarbs,
                      color: Colors.blue.shade500,
                      unit: 'g',
                    ),
                    _buildCircularMacro(
                      context: context,
                      label: l10n.macroProtein,
                      current: currentProtein,
                      limit: limitProtein,
                      color: Colors.red.shade500,
                      unit: 'g',
                    ),
                    _buildCircularMacro(
                      context: context,
                      label: l10n.macroFat,
                      current: currentFat,
                      limit: limitFat,
                      color: Colors.amber.shade600,
                      unit: 'g',
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

  Widget _buildKcalBar({
    required BuildContext context,
    required String label,
    required double current,
    required double limit,
    required Color color,
    required AppLocalizations l10n,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                l10n.kcalRemaining(remaining),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildCircularMacro({
    required BuildContext context,
    required String label,
    required double current,
    required double limit,
    required Color color,
    required String unit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        '/${limit.toInt()}$unit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
