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
    final l10n = AppLocalizations.of(context)!;
    final diff = widget.parent.kcalGoalDifference;
    final currentGoal = widget.parent.goalType;

    final textColor = diff < 0
        ? Colors.red.shade700
        : (diff > 0 ? Colors.green.shade700 : Colors.blue.shade700);

    final isChangingWeight =
        currentGoal == GoalTypeEnum.lose || currentGoal == GoalTypeEnum.gain;
    final isMaintaining = currentGoal == GoalTypeEnum.maintain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.goalTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.goalSubtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
        const SizedBox(height: 32),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.parent.weightChangeTargetKg.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Slider(
                        value: widget.parent.weightChangeTargetKg,
                        min: 0.5,
                        max: 30,
                        divisions: 59,
                        label:
                            '${widget.parent.weightChangeTargetKg.toStringAsFixed(1)} kg',
                        onChanged: (val) {
                          setState(() {
                            widget.parent.weightChangeTargetKg = val;
                            _recalculateGoal();
                          });
                        },
                      ),
                    ],
                  )
                : isMaintaining
                ? Center(
                    child: Text(
                      l10n.goalMaintainDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
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
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                diff == 0
                                    ? l10n.caloricTargetMaintain
                                    : l10n.caloricTargetValue(
                                        diff > 0 ? '+$diff' : '$diff',
                                      ),
                                style: TextStyle(
                                  fontSize: 20,
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
              ),
              child: Text(
                l10n.backButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: currentGoal != null ? widget.parent.nextPage : null,
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
