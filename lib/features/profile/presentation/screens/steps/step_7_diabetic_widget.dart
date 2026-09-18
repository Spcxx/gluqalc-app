import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step7DiabeticWidget extends StatefulWidget {
  const Step7DiabeticWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step7DiabeticWidget> createState() => _Step7DiabeticWidgetState();
}

class _Step7DiabeticWidgetState extends State<Step7DiabeticWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: widget.parent.formKeyDiabetic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.insulinSettingsTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.insulinSettingsSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildParameterField(
                      controller: widget.parent.isfController,
                      labelText: l10n.isfLabel,
                      suffixText: l10n.isfSuffix,
                      infoTitle: l10n.isfInfoTitle,
                      infoDesc: l10n.isfInfoDesc,
                      minValue: 1,
                      maxValue: 300,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 20),
                    _buildParameterField(
                      controller: widget.parent.ifpController,
                      labelText: l10n.ifpLabel,
                      suffixText: l10n.ifpSuffix,
                      infoTitle: l10n.ifpInfoTitle,
                      infoDesc: l10n.ifpInfoDesc,
                      minValue: 0,
                      maxValue: 10,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 20),
                    _buildParameterField(
                      controller: widget.parent.tddController,
                      labelText: l10n.tddLabel,
                      suffixText: 'U / kg',
                      infoTitle: l10n.tddInfoTitle,
                      infoDesc: l10n.tddInfoDesc,
                      minValue: 0.1,
                      maxValue: 3.0,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 20),
                    _buildParameterField(
                      controller: widget.parent.basalController,
                      labelText: l10n.basalLabel,
                      suffixText: 'U',
                      infoTitle: l10n.basalInfoTitle,
                      infoDesc: l10n.basalInfoDesc,
                      minValue: 0.0,
                      maxValue: 200.0,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          l10n.insulinDeliveryMethodLabel,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                          ),
                          onPressed: () => widget.parent.showInfoDialog(
                            l10n.deliveryMethodInfoTitle,
                            l10n.deliveryMethodInfoDesc,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<InsulinDeliveryEnum>(
                      segments: [
                        ButtonSegment(
                          value: InsulinDeliveryEnum.pen,
                          label: Text(l10n.insulinPen),
                        ),
                        ButtonSegment(
                          value: InsulinDeliveryEnum.pump,
                          label: Text(l10n.insulinPump),
                        ),
                      ],
                      selected: {widget.parent.insulinDeliveryMethod},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          widget.parent.insulinDeliveryMethod =
                              newSelection.first;
                        });
                      },
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
                  onPressed: () {
                    if (!widget.parent.formKeyDiabetic.currentState!
                        .validate()) {
                      return;
                    }
                    widget.parent.nextPage();
                  },
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
      ),
    );
  }

  Widget _buildParameterField({
    required TextEditingController controller,
    required String labelText,
    required String suffixText,
    required String infoTitle,
    required String infoDesc,
    required double minValue,
    required double maxValue,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              suffixText: suffixText,
              suffixStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.2,
              ),
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
            validator: (val) {
              if (val == null || val.isEmpty) {
                return l10n.errorFieldRequired;
              }
              final n = double.tryParse(val.replaceAll(',', '.'));
              if (n == null) {
                return l10n.errorValidationError;
              }
              if (n < minValue || n > maxValue) {
                return l10n.errorRange(minValue.toInt(), maxValue.toInt());
              }
              return null;
            },
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: colorScheme.primary,
          ),
          onPressed: () => widget.parent.showInfoDialog(
            infoTitle,
            infoDesc,
          ),
        ),
      ],
    );
  }
}
