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
    final l10n = AppLocalizations.of(context)!;
    final weeklySum = widget.parent.getWeeklySum();
    final isSumValid =
        !widget.parent.enableWeeklyDistribution || weeklySum == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.weeklyDistributionTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.weeklyDistributionSubtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            l10n.weeklyDistributionSwitch,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                      ),
                                  decoration: const InputDecoration(
                                    suffixText: 'kcal',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
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
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSumValid
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSumValid
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: isSumValid ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isSumValid
                                    ? l10n.weeklySumValid
                                    : l10n.weeklySumInvalid(weeklySum),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSumValid
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
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
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
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
              ),
              child: Text(
                l10n.backButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: isSumValid ? widget.parent.nextPage : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  l10n.nextButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
