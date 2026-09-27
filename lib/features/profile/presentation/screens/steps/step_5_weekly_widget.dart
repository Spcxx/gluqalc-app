import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step5WeeklyWidget extends StatefulWidget {
  const Step5WeeklyWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step5WeeklyWidget> createState() => _Step5WeeklyWidgetState();
}

class _Step5WeeklyWidgetState extends State<Step5WeeklyWidget> {
  String _getLocalizedDayName(WeekDayEnum day, AppLocalizations l10n) {
    switch (day) {
      case WeekDayEnum.monday:
        return l10n.monday;
      case WeekDayEnum.tuesday:
        return l10n.tuesday;
      case WeekDayEnum.wednesday:
        return l10n.wednesday;
      case WeekDayEnum.thursday:
        return l10n.thursday;
      case WeekDayEnum.friday:
        return l10n.friday;
      case WeekDayEnum.saturday:
        return l10n.saturday;
      case WeekDayEnum.sunday:
        return l10n.sunday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final weeklySum = widget.parent.getWeeklySum();
    final isSumValid =
        !widget.parent.enableWeeklyDistribution || weeklySum == 0;

    final errorColor = theme.brightness == Brightness.light
        ? Colors.red.shade700
        : Colors.red.shade300;
    final errorContainerColor = theme.brightness == Brightness.light
        ? Colors.red.shade50
        : errorColor.withValues(alpha: 0.1);
    final onErrorContainerColor = theme.brightness == Brightness.light
        ? Colors.red.shade900
        : Colors.red.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.weeklyDistributionTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.weeklyDistributionSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            l10n.weeklyDistributionSwitch,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          value: widget.parent.enableWeeklyDistribution,
          onChanged: (val) =>
              setState(() => widget.parent.enableWeeklyDistribution = val),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: widget.parent.enableWeeklyDistribution
                ? ListView(
                    children: [
                      ...widget.parent.dayControllers.entries.map((entry) {
                        final dayEnum = entry.key;
                        final controller = entry.value;
                        final dayName = _getLocalizedDayName(dayEnum, l10n);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  dayName,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                      ),
                                  decoration: InputDecoration(
                                    suffixText: 'kcal',
                                    suffixStyle: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    filled: true,
                                    fillColor: colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.2),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSumValid
                              ? colorScheme.tertiaryContainer.withValues(
                                  alpha: 0.3,
                                )
                              : errorContainerColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSumValid
                                ? colorScheme.tertiary.withValues(alpha: 0.5)
                                : errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSumValid
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: isSumValid
                                  ? colorScheme.tertiary
                                  : errorColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isSumValid
                                    ? l10n.weeklySumValid
                                    : l10n.weeklySumInvalid(weeklySum),
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSumValid
                                      ? colorScheme.onTertiaryContainer
                                      : onErrorContainerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      l10n.weeklyStandardDistribution,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton(
              onPressed: widget.parent.prevStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                l10n.backButton,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: isSumValid ? widget.parent.nextPage : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.nextButton,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
