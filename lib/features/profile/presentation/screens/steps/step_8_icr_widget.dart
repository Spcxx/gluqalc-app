import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step8IcrWidget extends StatefulWidget {
  const Step8IcrWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step8IcrWidget> createState() => _Step8IcrWidgetState();
}

class _Step8IcrWidgetState extends State<Step8IcrWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final stringError = widget.parent.validateHourlyIcr(l10n);

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
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.icrTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: colorScheme.primary),
              onPressed: () => widget.parent.showInfoDialog(
                l10n.icrInfoTitle,
                l10n.icrInfoDesc,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.icrSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: widget.parent.hourIcrItems.length,
            itemBuilder: (context, index) {
              final item = widget.parent.hourIcrItems[index];
              return _buildIcrCard(item, index, l10n);
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              widget.parent.hourIcrItems.add(
                HourIcrItem(hour: 0, icrValue: 1),
              );
            });
          },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.addHourButton),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: stringError == null
                ? colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                : errorContainerColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: stringError == null
                  ? colorScheme.tertiary.withValues(alpha: 0.5)
                  : errorColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                stringError == null ? Icons.check_circle : Icons.error_outline,
                color: stringError == null ? colorScheme.tertiary : errorColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stringError ?? l10n.icrConfigValid,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stringError == null
                        ? colorScheme.onTertiaryContainer
                        : onErrorContainerColor,
                  ),
                ),
              ),
            ],
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
                onPressed: stringError == null ? widget.parent.nextPage : null,
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

  Widget _buildIcrCard(HourIcrItem item, int index, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      key: ObjectKey(item),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                initialValue: item.hour,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: l10n.hourLabel,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                items: List.generate(
                  24,
                  (h) => DropdownMenuItem(
                    value: h,
                    child: Text('$h:00', style: textTheme.bodyMedium),
                  ),
                ),
                onChanged: (val) {
                  if (val != null) setState(() => item.hour = val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: item.icrValue.toString(),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.icrValueLabel,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  item.icrValue =
                      double.tryParse(val.replaceAll(',', '.')) ?? 0;
                  setState(
                    () {},
                  );
                },
              ),
            ),
            if (widget.parent.hourIcrItems.length > 1)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                ),
                onPressed: () {
                  setState(() {
                    widget.parent.hourIcrItems.removeAt(index);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
