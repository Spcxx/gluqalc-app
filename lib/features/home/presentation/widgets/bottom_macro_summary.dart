import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/home/data/models/day_summary_model.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class BottomMacroSummary extends StatefulWidget {
  const BottomMacroSummary({
    required this.consumed,
    required this.target,
    required this.l10n,
    super.key,
  });

  final NutrientValues consumed;
  final NutrientValues target;
  final AppLocalizations l10n;

  @override
  State<BottomMacroSummary> createState() => _BottomMacroSummaryState();
}

class _BottomMacroSummaryState extends State<BottomMacroSummary> {
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
              onTap: () => setState(() => _isExpanded = !_isExpanded),
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
