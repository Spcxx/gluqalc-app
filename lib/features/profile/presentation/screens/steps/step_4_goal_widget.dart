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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final diff = widget.parent.kcalGoalDifference;
    final currentGoal = widget.parent.goalType;

    final textColor = diff < 0
        ? colorScheme.error
        : (diff > 0 ? colorScheme.tertiary : colorScheme.primary);

    final isChangingWeight =
        currentGoal == GoalTypeEnum.lose || currentGoal == GoalTypeEnum.gain;
    final isMaintaining = currentGoal == GoalTypeEnum.maintain;

    final isExtremeLoss =
        currentGoal == GoalTypeEnum.lose &&
        widget.parent.weightChangeTargetKg > 11.0;
    final isHighLoss =
        currentGoal == GoalTypeEnum.lose &&
        widget.parent.weightChangeTargetKg > 7.0 &&
        !isExtremeLoss;

    return Column(
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
        const SizedBox(height: 24),
        SegmentedButton<GoalTypeEnum>(
          emptySelectionAllowed: true,
          segments: [
            ButtonSegment(
              value: GoalTypeEnum.lose,
              label: Text(l10n.goalLose),
            ),
            ButtonSegment(
              value: GoalTypeEnum.maintain,
              label: Text(l10n.goalMaintain),
            ),
            ButtonSegment(
              value: GoalTypeEnum.gain,
              label: Text(l10n.goalGain),
            ),
          ],
          selected: currentGoal != null ? {currentGoal} : {},
          onSelectionChanged: (newSelection) {
            setState(() {
              widget.parent.goalType = newSelection.firstOrNull;
              _recalculateGoal();
            });
          },
        ),
        const SizedBox(height: 24),
        Expanded(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isChangingWeight
                ? Column(
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
                        max: 15,
                        divisions: 29,
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
                                ? colorScheme.errorContainer.withValues(
                                    alpha: 0.5,
                                  )
                                : colorScheme.tertiaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isExtremeLoss
                                  ? colorScheme.error.withValues(alpha: 0.5)
                                  : colorScheme.tertiary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isExtremeLoss
                                    ? Icons.warning_rounded
                                    : Icons.info_outline,
                                color: isExtremeLoss
                                    ? colorScheme.error
                                    : colorScheme.tertiary,
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
                                        ? colorScheme.onErrorContainer
                                        : colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )
                : isMaintaining
                ? Center(
                    child: Text(
                      l10n.goalMaintainDesc,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: currentGoal != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          diff == 0
                              ? Icons.balance
                              : (diff < 0
                                    ? Icons.trending_down
                                    : Icons.trending_up),
                          size: 36,
                          color: textColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.caloricTargetLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                diff == 0
                                    ? l10n.caloricTargetMaintain
                                    : l10n.caloricTargetValue(
                                        diff > 0 ? '+$diff' : '$diff',
                                      ),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
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
}
