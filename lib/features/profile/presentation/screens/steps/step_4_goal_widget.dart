import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step4GoalWidget extends StatefulWidget {
  const Step4GoalWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step4GoalWidget> createState() => _Step4GoalWidgetState();
}

class _Step4GoalWidgetState extends State<Step4GoalWidget> {
  void _recalculateGoal() {
    final currentGoal = widget.parent.goalType;

    if (currentGoal == GoalTypeEnum.maintain || currentGoal == null) {
      widget.parent.kcalGoalDifference = 0;
    } else {
      final diff = (widget.parent.weightChangeTargetKg * 48).round();
      widget.parent.kcalGoalDifference = currentGoal == GoalTypeEnum.lose
          ? -diff
          : diff;
    }

    widget.parent.recalculateDraftTargets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final diff = widget.parent.kcalGoalDifference;
    final currentGoal = widget.parent.goalType;

    final isChangingWeight =
        currentGoal == GoalTypeEnum.lose || currentGoal == GoalTypeEnum.gain;
    final isMaintaining = currentGoal == GoalTypeEnum.maintain;

    final absDiff = diff.abs();
    final isExtremeLoss = currentGoal == GoalTypeEnum.lose && absDiff > 1000;
    final isHighLoss =
        currentGoal == GoalTypeEnum.lose && absDiff > 750 && !isExtremeLoss;

    final errorColor = theme.brightness == Brightness.light
        ? Colors.red.shade700
        : Colors.red.shade300;
    final errorContainerColor = theme.brightness == Brightness.light
        ? Colors.red.shade50
        : errorColor.withValues(alpha: 0.1);
    final onErrorContainerColor = theme.brightness == Brightness.light
        ? Colors.red.shade900
        : Colors.red.shade100;

    final warningColor = theme.brightness == Brightness.light
        ? Colors.orange.shade700
        : Colors.orange.shade300;
    final warningContainerColor = theme.brightness == Brightness.light
        ? Colors.orange.shade50
        : warningColor.withValues(alpha: 0.1);
    final onWarningContainerColor = theme.brightness == Brightness.light
        ? Colors.orange.shade900
        : Colors.orange.shade100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.goalTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.goalSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                Column(
                  children: [
                    _buildGoalChoiceCard(
                      title: l10n.goalLose,
                      icon: Icons.trending_down,
                      isSelected: currentGoal == GoalTypeEnum.lose,
                      onTap: () {
                        setState(() {
                          widget.parent.goalType = GoalTypeEnum.lose;
                          _recalculateGoal();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildGoalChoiceCard(
                      title: l10n.goalMaintain,
                      icon: Icons.balance,
                      isSelected: currentGoal == GoalTypeEnum.maintain,
                      onTap: () {
                        setState(() {
                          widget.parent.goalType = GoalTypeEnum.maintain;
                          _recalculateGoal();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildGoalChoiceCard(
                      title: l10n.goalGain,
                      icon: Icons.trending_up,
                      isSelected: currentGoal == GoalTypeEnum.gain,
                      onTap: () {
                        setState(() {
                          widget.parent.goalType = GoalTypeEnum.gain;
                          _recalculateGoal();
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (isChangingWeight)
                  Column(
                    children: [
                      Text(
                        l10n.goalLoseGainQuestion(
                          currentGoal == GoalTypeEnum.lose
                              ? l10n.goalActionLose
                              : l10n.goalActionGain,
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.parent.weightChangeTargetKg.toStringAsFixed(1)} kg',
                        style: textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Slider(
                        value: widget.parent.weightChangeTargetKg,
                        min: 0.5,
                        max: 25,
                        divisions: 49,
                        label:
                            '${widget.parent.weightChangeTargetKg.toStringAsFixed(1)} kg',
                        onChanged: (val) {
                          setState(() {
                            widget.parent.weightChangeTargetKg = val;
                            _recalculateGoal();
                          });
                        },
                      ),
                      if (isHighLoss || isExtremeLoss) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isExtremeLoss
                                ? errorContainerColor
                                : warningContainerColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isExtremeLoss
                                  ? errorColor.withValues(alpha: 0.3)
                                  : warningColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isExtremeLoss
                                    ? Icons.warning_rounded
                                    : Icons.info_outline,
                                color: isExtremeLoss
                                    ? errorColor
                                    : warningColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isExtremeLoss
                                      ? l10n.warningExtremeDeficitRed
                                      : l10n.warningHighDeficitYellow,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isExtremeLoss
                                        ? onErrorContainerColor
                                        : onWarningContainerColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )
                else if (isMaintaining)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.goalMaintainDesc,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (currentGoal != null)
          widget.parent.buildDraftTargetBanner(
            l10n,
            colorScheme,
            textTheme,
            subtitle: diff == 0
                ? l10n.caloricTargetMaintain
                : l10n.caloricTargetValue(diff > 0 ? '+$diff' : '$diff'),
          ),

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
                onPressed: currentGoal != null ? widget.parent.nextPage : null,
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

  Widget _buildGoalChoiceCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
