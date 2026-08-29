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
          widget.parent.proteinPercent = 30;
          widget.parent.fatPercent = 25;
          widget.parent.carbPercent = 45;
        case MacroPresetEnum.highProtein:
          widget.parent.proteinPercent = 40;
          widget.parent.fatPercent = 20;
          widget.parent.carbPercent = 40;
        case MacroPresetEnum.lowCarb:
          widget.parent.proteinPercent = 35;
          widget.parent.fatPercent = 45;
          widget.parent.carbPercent = 20;
        case MacroPresetEnum.keto:
          widget.parent.proteinPercent = 25;
          widget.parent.fatPercent = 70;
          widget.parent.carbPercent = 5;
        case MacroPresetEnum.custom:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.macroTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.macroSubtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                  color: Colors.red.shade400,
                  isWarning: isProteinWarning,
                  warningText: l10n.macroProteinNorm,
                  onChanged: widget.parent.macroPreset == MacroPresetEnum.custom
                      ? (val) =>
                            setState(() => widget.parent.proteinPercent = val)
                      : null,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                _buildMacroSlider(
                  title: l10n.macroFat,
                  value: widget.parent.fatPercent,
                  color: Colors.amber.shade700,
                  isWarning: isFatWarning,
                  warningText: l10n.macroFatNorm,
                  onChanged: widget.parent.macroPreset == MacroPresetEnum.custom
                      ? (val) => setState(() => widget.parent.fatPercent = val)
                      : null,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                _buildMacroSlider(
                  title: l10n.macroCarbs,
                  value: widget.parent.carbPercent,
                  color: Colors.blue.shade400,
                  isWarning: isCarbWarning,
                  warningText: l10n.macroCarbsNorm,
                  onChanged: widget.parent.macroPreset == MacroPresetEnum.custom
                      ? (val) => setState(() => widget.parent.carbPercent = val)
                      : null,
                  l10n: l10n,
                ),
                const SizedBox(height: 20),
                if (hasAnyWarning)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.macroWarningText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
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
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMacroValid
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMacroValid
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: isMacroValid ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isMacroValid
                              ? l10n.macroSumValid
                              : l10n.macroSumInvalid(totalMacro.toInt()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMacroValid
                                ? Colors.green.shade800
                                : Colors.red.shade800,
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
              ),
              child: Text(
                l10n.backButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: isMacroValid ? widget.parent.nextPage : null,
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

  Widget _buildPresetChip(String label, MacroPresetEnum preset) {
    return ChoiceChip(
      label: Text(label),
      selected: widget.parent.macroPreset == preset,
      onSelected: (_) => _applyMacroPreset(preset),
    );
  }

  Widget _buildMacroSlider({
    required String title,
    required double value,
    required Color color,
    required bool isWarning,
    required String warningText,
    required ValueChanged<double>? onChanged,
    required AppLocalizations l10n,
  }) {
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (isWarning) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.macroOutOfRange(warningText),
                    child: Icon(
                      Icons.info,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${value.toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isWarning ? Colors.orange.shade800 : color,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          max: 100,
          divisions: 100,
          activeColor: isWarning ? Colors.orange : color,
          label: '${value.toInt()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
