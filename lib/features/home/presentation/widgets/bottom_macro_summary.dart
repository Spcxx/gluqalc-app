import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/home/data/models/day_summary_model.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class BottomMacroSummary extends StatefulWidget {
  const BottomMacroSummary({
    required this.consumed,
    required this.target,
    required this.l10n,
    this.insulinSummary,
    super.key,
  });

  final NutrientValues consumed;
  final NutrientValues target;
  final AppLocalizations l10n;
  final DailyInsulinSummary? insulinSummary;

  @override
  State<BottomMacroSummary> createState() => _BottomMacroSummaryState();
}

class _BottomMacroSummaryState extends State<BottomMacroSummary> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasInsulinData =
        widget.insulinSummary != null &&
        widget.insulinSummary!.estimatedBolusTarget != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildKcalBar(
                                  context: context,
                                  label: widget.l10n.macroKcal,
                                  current: widget.consumed.energyKcal,
                                  limit: widget.target.energyKcal,
                                  color: colorScheme.primary,
                                  l10n: widget.l10n,
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  height: _isExpanded ? 115.0 : 0.0,
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: _buildCircularMacro(
                                                context: context,
                                                label: widget.l10n.macroCarbs,
                                                current: widget
                                                    .consumed
                                                    .carbohydrates,
                                                limit:
                                                    widget.target.carbohydrates,
                                                color: colorScheme.primary,
                                                unit: 'g',
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: _buildCircularMacro(
                                                context: context,
                                                label: widget.l10n.macroProtein,
                                                current:
                                                    widget.consumed.protein,
                                                limit: widget.target.protein,
                                                color: colorScheme.error,
                                                unit: 'g',
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: _buildCircularMacro(
                                                context: context,
                                                label: widget.l10n.macroFat,
                                                current: widget.consumed.fat,
                                                limit: widget.target.fat,
                                                color: colorScheme.tertiary,
                                                unit: 'g',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasInsulinData) ...[
                            const SizedBox(width: 12),
                            _buildInsulinBar(
                              context: context,
                              summary: widget.insulinSummary!,
                              isExpanded: _isExpanded,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final rawProgress = limit > 0 ? (current / limit) : 0.0;
    final progress = rawProgress.clamp(0.0, 1.0);

    final remaining = (limit - current).toInt();
    final isExceeded = remaining < 0;

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
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                l10n.kcalRemaining(remaining),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isExceeded
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
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

  Widget _buildInsulinBar({
    required BuildContext context,
    required DailyInsulinSummary summary,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final limit = summary.estimatedBolusTarget ?? 0;

    final current = summary.consumedBolusDose;

    final rawProgress = limit > 0 ? (current / limit) : 0.0;
    final progress = rawProgress.clamp(0.0, 1.0);
    final isExceeded = (limit - current) < 0;
    final primaryColor = colorScheme.secondary;

    final totalHeight = isExpanded ? (38.0 + 115.0) : 48.0;

    return Tooltip(
      message: '${current.toStringAsFixed(1)} / ${limit.toStringAsFixed(1)} u',
      triggerMode: TooltipTriggerMode.tap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        height: totalHeight,
        width: 32,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 10,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: progress,
                    child: Container(
                      width: 10,
                      decoration: BoxDecoration(
                        color: isExceeded ? colorScheme.error : primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${current.toStringAsFixed(0)}u',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isExceeded ? colorScheme.error : primaryColor,
              ),
            ),
            if (isExpanded)
              Text(
                '/${limit.toStringAsFixed(0)}u',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final rawProgress = limit > 0 ? (current / limit) : 0.0;
    final progress = rawProgress.clamp(0.0, 1.0);
    final isExceeded = rawProgress > 1.0;

    return SizedBox(
      width: 90,
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
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isExceeded
                              ? colorScheme.error
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        '/${limit.toInt()}$unit',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
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
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
