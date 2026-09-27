import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class MacroTableFormWidget extends StatelessWidget {
  const MacroTableFormWidget({
    required this.kcalCtrl,
    required this.giCtrl,
    required this.fatCtrl,
    required this.satFatCtrl,
    required this.carbsCtrl,
    required this.sugarsCtrl,
    required this.fiberCtrl,
    required this.proteinCtrl,
    required this.saltCtrl,
    super.key,
  });

  final TextEditingController kcalCtrl;
  final TextEditingController giCtrl;
  final TextEditingController fatCtrl;
  final TextEditingController satFatCtrl;
  final TextEditingController carbsCtrl;
  final TextEditingController sugarsCtrl;
  final TextEditingController fiberCtrl;
  final TextEditingController proteinCtrl;
  final TextEditingController saltCtrl;

  Widget _buildField(
    BuildContext context,
    AppLocalizations l10n, {
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    bool isSubItem = false,
    String? suffix,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final displayLabel = isMandatory ? '$label *' : label;

    return TextFormField(
      controller: controller,
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
      ],
      decoration: InputDecoration(
        prefixIcon: isSubItem
            ? Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: displayLabel),
              if (!isMandatory)
                TextSpan(
                  text: ' (${l10n.optional})',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: isMandatory
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        suffixText: suffix,
        suffixStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroEnergy,
                    controller: kcalCtrl,
                    isMandatory: true,
                    suffix: 'kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroGlycemicIndex,
                    controller: giCtrl,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroFatFull,
                    controller: fatCtrl,
                    isMandatory: true,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroSaturatedFat,
                    controller: satFatCtrl,
                    isSubItem: true,
                    suffix: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroCarbohydratesFull,
                    controller: carbsCtrl,
                    isMandatory: true,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroSugars,
                    controller: sugarsCtrl,
                    isSubItem: true,
                    suffix: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroFiber,
                    controller: fiberCtrl,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroProteinFull,
                    controller: proteinCtrl,
                    isMandatory: true,
                    suffix: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    context,
                    l10n,
                    label: l10n.macroSalt,
                    controller: saltCtrl,
                    suffix: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
