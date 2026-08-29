import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step10SummaryWidget extends StatelessWidget {
  const Step10SummaryWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  String _formatGender(GenderEnum? g, AppLocalizations l10n) {
    if (g == null) return l10n.notSet;
    switch (g) {
      case GenderEnum.female:
        return l10n.genderFemale;
      case GenderEnum.male:
        return l10n.genderMale;
      case GenderEnum.other:
        return l10n.genderOther;
    }
  }

  String _formatBmr(BmrMethodEnum? m, AppLocalizations l10n) {
    if (m == null) return l10n.notSet;
    switch (m) {
      case BmrMethodEnum.harrisBenedict:
        return l10n.bmrHarrisTitle;
      case BmrMethodEnum.mifflinStJeor:
        return l10n.bmrMifflinTitle;
      case BmrMethodEnum.katchMcArdle:
        return l10n.bmrKatchTitle;
      case BmrMethodEnum.owen:
        return l10n.bmrOwenTitle;
    }
  }

  String _formatGoal(GoalTypeEnum? g, int diff, AppLocalizations l10n) {
    if (g == null) return l10n.notSet;
    switch (g) {
      case GoalTypeEnum.lose:
        return l10n.summaryGoalLose(diff.abs());
      case GoalTypeEnum.gain:
        return l10n.summaryGoalGain(diff);
      case GoalTypeEnum.maintain:
        return l10n.summaryGoalMaintain;
    }
  }

  String _formatDeliveryMethod(
    InsulinDeliveryEnum method,
    AppLocalizations l10n,
  ) {
    switch (method) {
      case InsulinDeliveryEnum.pump:
        return l10n.insulinPump;
      case InsulinDeliveryEnum.pen:
        return l10n.insulinPen;
    }
  }

  String _formatCombinedInsulin(
    CombinedInsulinEnum method,
    AppLocalizations l10n,
  ) {
    switch (method) {
      case CombinedInsulinEnum.pankowska:
        return l10n.pankowskaTitle;
      case CombinedInsulinEnum.sieradzki:
        return l10n.sieradzkiTitle;
    }
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.summaryTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.summarySubtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildSummaryItem(
                    l10n.summaryGender,
                    _formatGender(parent.selectedGender, l10n),
                  ),
                  _buildSummaryItem(
                    l10n.summaryBirthDate,
                    parent.selectedBirthDate?.toIso8601String().split('T')[0] ??
                        l10n.notSet,
                  ),
                  _buildSummaryItem(
                    l10n.summaryHeightWeight,
                    '${parent.heightController.text} cm, ${parent.weightController.text} kg',
                  ),
                  _buildSummaryItem(
                    l10n.summaryBodyFat,
                    parent.knowsBodyFat
                        ? '${parent.bodyFatController.text}%'
                        : l10n.notProvided,
                  ),
                  _buildSummaryItem(
                    l10n.summaryBmrMethod,
                    _formatBmr(parent.selectedBmrMethod, l10n),
                  ),
                  _buildSummaryItem(
                    l10n.summaryPal,
                    parent.palValue.toStringAsFixed(2),
                  ),
                  _buildSummaryItem(
                    l10n.summaryGoal,
                    _formatGoal(
                      parent.goalType,
                      parent.kcalGoalDifference,
                      l10n,
                    ),
                  ),
                  _buildSummaryItem(
                    l10n.summaryWeekly,
                    parent.enableWeeklyDistribution
                        ? l10n.summaryWeeklyCustom
                        : l10n.summaryWeeklyUniform,
                  ),
                  _buildSummaryItem(
                    l10n.summaryMacros,
                    'P: ${parent.proteinPercent.toInt()}%, F: ${parent.fatPercent.toInt()}%, C: ${parent.carbPercent.toInt()}%',
                  ),
                  _buildSummaryItem(
                    l10n.summaryInsulinParams,
                    '${parent.isfController.text} mg/dL/U | ${parent.ifpController.text} U/FPU',
                  ),
                  _buildSummaryItem(
                    l10n.summaryInsulinDelivery,
                    _formatDeliveryMethod(parent.insulinDeliveryMethod, l10n),
                  ),
                  _buildSummaryItem(
                    l10n.summaryIcrHours,
                    l10n.summaryIntervals(parent.hourIcrItems.length),
                  ),
                  _buildSummaryItem(
                    l10n.summaryFpuMethod,
                    _formatCombinedInsulin(parent.combinedInsulinMethod, l10n),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton(
              onPressed: parent.prevStep,
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
                onPressed: parent.finishSetup,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  l10n.finishButton,
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
