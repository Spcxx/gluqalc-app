import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/core/presentation/widgets/app_drawer.dart';
import 'package:gluqalc_app/features/home/data/models/day_summary_model.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedDate = ref.watch(homeSelectedDateProvider);
    final summaryAsync = ref.watch(daySummaryControllerProvider);
    final controller = ref.read(daySummaryControllerProvider.notifier);

    final summary =
        summaryAsync.value ?? controller.getCachedSummary(selectedDate);

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
      body: Column(
        children: [
          const _DateSliderSelector(),
          const Divider(height: 1),
          if (summaryAsync.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: summary == null && summaryAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : summaryAsync.hasError && summary == null
                ? Center(
                    child: Text(
                      l10n.errorUnknown(summaryAsync.error.toString()),
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Center(
                    child: Text(
                      'todo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomMacroSummary(
        consumed:
            summary?.consumed ??
            const NutrientValues(
              energyKcal: 0,
              protein: 0,
              fat: 0,
              carbohydrates: 0,
            ),
        target:
            summary?.target ??
            const NutrientValues(
              energyKcal: 2000,
              protein: 150,
              fat: 65,
              carbohydrates: 200,
            ),
        l10n: l10n,
      ),
    );
  }
}

class _BottomMacroSummary extends StatefulWidget {
  const _BottomMacroSummary({
    required this.consumed,
    required this.target,
    required this.l10n,
  });

  final NutrientValues consumed;
  final NutrientValues target;
  final AppLocalizations l10n;

  @override
  State<_BottomMacroSummary> createState() => _BottomMacroSummaryState();
}

class _BottomMacroSummaryState extends State<_BottomMacroSummary> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKcalBar(
                    context: context,
                    label: widget.l10n.macroKcal,
                    current: widget.consumed.energyKcal,
                    limit: widget.target.energyKcal,
                    color: Colors.orange.shade600,
                    l10n: widget.l10n,
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: _isExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildCircularMacro(
                                  context: context,
                                  label: widget.l10n.macroCarbs,
                                  current: widget.consumed.carbohydrates,
                                  limit: widget.target.carbohydrates,
                                  color: Colors.blue.shade500,
                                  unit: 'g',
                                ),
                                _buildCircularMacro(
                                  context: context,
                                  label: widget.l10n.macroProtein,
                                  current: widget.consumed.protein,
                                  limit: widget.target.protein,
                                  color: Colors.red.shade500,
                                  unit: 'g',
                                ),
                                _buildCircularMacro(
                                  context: context,
                                  label: widget.l10n.macroFat,
                                  current: widget.consumed.fat,
                                  limit: widget.target.fat,
                                  color: Colors.amber.shade600,
                                  unit: 'g',
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ],
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

class _DateSliderSelector extends ConsumerStatefulWidget {
  const _DateSliderSelector();

  @override
  ConsumerState<_DateSliderSelector> createState() =>
      _DateSliderSelectorState();
}

class _DateSliderSelectorState extends ConsumerState<_DateSliderSelector> {
  late PageController _pageController;
  late DateTime _baseDate;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _baseDate = _today.subtract(const Duration(days: 60));

    final initialDate = ref.read(homeSelectedDateProvider);
    final initialIndex = initialDate.difference(_baseDate).inDays;

    _pageController = PageController(
      initialPage: initialIndex,
      viewportFraction: 0.2,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getShortDayName(DateTime date, AppLocalizations l10n) {
    switch (date.weekday) {
      case 1:
        return l10n.shortMon;
      case 2:
        return l10n.shortTue;
      case 3:
        return l10n.shortWed;
      case 4:
        return l10n.shortThu;
      case 5:
        return l10n.shortFri;
      case 6:
        return l10n.shortSat;
      case 7:
        return l10n.shortSun;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDate = ref.watch(homeSelectedDateProvider);

    ref.listen(homeSelectedDateProvider, (prev, next) {
      if (prev == next) return;
      final nextIndex = next.difference(_baseDate).inDays;
      if (_pageController.hasClients &&
          _pageController.page?.round() != nextIndex) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    final isTodayVisible = selectedDate.difference(_today).inDays.abs() <= 2;
    final formattedDate = DateFormat.MMMMd(l10n.localeName)
        .format(selectedDate);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isTodayVisible ? 0.0 : 1.0,
                  child: TextButton.icon(
                    onPressed: isTodayVisible
                        ? null
                        : () => ref
                              .read(homeSelectedDateProvider.notifier)
                              .updateDate(_today),
                    icon: const Icon(Icons.arrow_back_rounded, size: 14),
                    label: Text(
                      l10n.backToToday,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          height: 70,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 121,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              final newDate = _baseDate.add(Duration(days: index));
              if (ref.read(homeSelectedDateProvider) != newDate) {
                ref.read(homeSelectedDateProvider.notifier).updateDate(newDate);
              }
            },
            itemBuilder: (context, index) {
              final date = _baseDate.add(Duration(days: index));
              final isSelected = date == selectedDate;
              final isToday = date == _today;

              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            )
                          : Border.all(color: Colors.transparent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getShortDayName(date, l10n),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
