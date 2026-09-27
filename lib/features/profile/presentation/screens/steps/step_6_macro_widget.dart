import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step6MacroWidget extends StatefulWidget {
  const Step6MacroWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step6MacroWidget> createState() => _Step6MacroWidgetState();
}

class _Step6MacroWidgetState extends State<Step6MacroWidget> {
  void _applyMacroPreset(MacroPresetEnum preset) {
    setState(() {
      widget.parent.macroPreset = preset;
      switch (preset) {
        case MacroPresetEnum.balanced:
          widget.parent.proteinPercent = 20;
          widget.parent.fatPercent = 30;
          widget.parent.carbPercent = 50;
        case MacroPresetEnum.highProtein:
          widget.parent.proteinPercent = 35;
          widget.parent.fatPercent = 25;
          widget.parent.carbPercent = 40;
        case MacroPresetEnum.lowCarb:
          widget.parent.proteinPercent = 35;
          widget.parent.fatPercent = 45;
          widget.parent.carbPercent = 20;
        case MacroPresetEnum.keto:
          widget.parent.proteinPercent = 20;
          widget.parent.fatPercent = 75;
          widget.parent.carbPercent = 5;
        case MacroPresetEnum.custom:
          break;
      }
    });
    widget.parent.recalculateDraftTargets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final totalMacro =
        widget.parent.proteinPercent +
        widget.parent.fatPercent +
        widget.parent.carbPercent;
    final isMacroValid = (totalMacro - 100.0).abs() <= 0.01;

    final isCarbWarning =
        widget.parent.carbPercent < 45 || widget.parent.carbPercent > 65;
    final isProteinWarning =
        widget.parent.proteinPercent < 10 || widget.parent.proteinPercent > 35;
    final isFatWarning =
        widget.parent.fatPercent < 20 || widget.parent.fatPercent > 35;
    final hasAnyWarning = isCarbWarning || isProteinWarning || isFatWarning;

    final warningColor = theme.brightness == Brightness.light
        ? Colors.orange.shade700
        : Colors.orange.shade300;
    final warningContainerColor = theme.brightness == Brightness.light
        ? Colors.orange.shade50
        : warningColor.withValues(alpha: 0.1);
    final onWarningContainerColor = theme.brightness == Brightness.light
        ? Colors.orange.shade900
        : Colors.orange.shade100;

    final errorColor = theme.brightness == Brightness.light
        ? Colors.red.shade700
        : Colors.red.shade300;
    final errorContainerColor = theme.brightness == Brightness.light
        ? Colors.red.shade50
        : errorColor.withValues(alpha: 0.1);
    final onErrorContainerColor = theme.brightness == Brightness.light
        ? Colors.red.shade900
        : Colors.red.shade100;

    final dailyKcalGoal = widget.parent.draftTargets?.dailyKcalGoal;
    double? getGrams(double percent, double divisor) {
      if (dailyKcalGoal == null || dailyKcalGoal <= 0) return null;
      return (dailyKcalGoal * (percent / 100.0)) / divisor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.macroTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.macroSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip(l10n.macroBalanced, MacroPresetEnum.balanced),
            _buildPresetChip(
              l10n.macroHighProtein,
              MacroPresetEnum.highProtein,
            ),
            _buildPresetChip(l10n.macroLowCarb, MacroPresetEnum.lowCarb),
            _buildPresetChip(l10n.macroKeto, MacroPresetEnum.keto),
            _buildPresetChip(l10n.macroCustom, MacroPresetEnum.custom),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMacroSlider(
                  title: l10n.macroProtein,
                  value: widget.parent.proteinPercent,
                  grams: getGrams(widget.parent.proteinPercent, 4),
                  baseColor: colorScheme.error,
                  warningColor: warningColor,
                  isWarning: isProteinWarning,
                  warningText: l10n.macroProteinNorm,
                  onChanged: widget.parent.macroPreset == MacroPresetEnum.custom
                      ? (val) {
                          setState(() => widget.parent.proteinPercent = val);
                          widget.parent.recalculateDraftTargets();
                        }
                      : null,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                _buildMacroSlider(
                  title: l10n.macroFat,
                  value: widget.parent.fatPercent,
                  grams: getGrams(widget.parent.fatPercent, 9),
                  baseColor: colorScheme.tertiary,
                  warningColor: warningColor,
                  isWarning: isFatWarning,
                  warningText: l10n.macroFatNorm,
                  onChanged: widget.parent.macroPreset == MacroPresetEnum.custom
                      ? (val) {
                          setState(() => widget.parent.fatPercent = val);
                          widget.parent.recalculateDraftTargets();
                        }
                      : null,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                _buildMacroSlider(
                  title: l10n.macroCarbs,
                  value: widget.parent.carbPercent,
                  grams: getGrams(widget.parent.carbPercent, 4),
                  baseColor: colorScheme.primary,
                  warningColor: warningColor,
                  isWarning: isCarbWarning,
                  warningText: l10n.macroCarbsNorm,
                  onChanged: widget.parent.macroPreset == MacroPresetEnum.custom
                      ? (val) {
                          setState(() => widget.parent.carbPercent = val);
                          widget.parent.recalculateDraftTargets();
                        }
                      : null,
                  l10n: l10n,
                ),
                const SizedBox(height: 20),
                if (hasAnyWarning &&
                    widget.parent.macroPreset == MacroPresetEnum.custom)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: warningContainerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: warningColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: warningColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.macroWarningText,
                            style: textTheme.bodySmall?.copyWith(
                              color: onWarningContainerColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMacroValid
                        ? colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                        : errorContainerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMacroValid
                          ? colorScheme.tertiary.withValues(alpha: 0.5)
                          : errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMacroValid
                            ? Icons.check_circle
                            : Icons.error_outline_rounded,
                        color: isMacroValid ? colorScheme.tertiary : errorColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isMacroValid
                              ? l10n.macroSumValid
                              : l10n.macroSumInvalid(totalMacro.toInt()),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isMacroValid
                                ? colorScheme.onTertiaryContainer
                                : onErrorContainerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                onPressed: isMacroValid ? widget.parent.nextPage : null,
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

  Widget _buildPresetChip(String label, MacroPresetEnum preset) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSelected = widget.parent.macroPreset == preset;

    return ChoiceChip(
      label: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (_) => _applyMacroPreset(preset),
    );
  }

  Widget _buildMacroSlider({
    required String title,
    required double value,
    required double? grams,
    required Color baseColor,
    required Color warningColor,
    required bool isWarning,
    required String warningText,
    required ValueChanged<double>? onChanged,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final activeColor = isWarning ? warningColor : baseColor;

    final valueText = grams != null
        ? '${value.toInt()}% (${grams.toStringAsFixed(0)}g)'
        : '${value.toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isWarning) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.macroOutOfRange(warningText),
                    child: Icon(
                      Icons.info,
                      size: 16,
                      color: warningColor,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              valueText,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          max: 100,
          divisions: 100,
          activeColor: activeColor,
          label: '${value.toInt()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
