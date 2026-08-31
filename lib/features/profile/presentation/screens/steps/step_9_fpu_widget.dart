import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step9FpuWidget extends StatefulWidget {
  const Step9FpuWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step9FpuWidget> createState() => _Step9FpuWidgetState();
}

class _Step9FpuWidgetState extends State<Step9FpuWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final availableMethods = [
      {
        'enum': CombinedInsulinEnum.pankowska,
        'title': l10n.pankowskaTitle,
        'desc': l10n.pankowskaDesc,
      },
      {
        'enum': CombinedInsulinEnum.sieradzki,
        'title': l10n.sieradzkiTitle,
        'desc': l10n.sieradzkiDesc,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.fpuMethodTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.fpuMethodSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: RadioGroup<CombinedInsulinEnum>(
            groupValue: widget.parent.combinedInsulinMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() => widget.parent.combinedInsulinMethod = val);
              }
            },
            child: ListView.separated(
              itemCount: availableMethods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = availableMethods[index];
                final fpuEnum = method['enum']! as CombinedInsulinEnum;
                final isSelected =
                    widget.parent.combinedInsulinMethod == fpuEnum;

                return InkWell(
                  onTap: () => setState(
                    () => widget.parent.combinedInsulinMethod = fpuEnum,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.5),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.05)
                          : Colors.transparent,
                    ),
                    padding: const EdgeInsets.only(
                      left: 8,
                      top: 12,
                      bottom: 12,
                      right: 4,
                    ),
                    child: Row(
                      children: [
                        Radio<CombinedInsulinEnum>(
                          value: fpuEnum,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title']! as String,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => widget.parent.showInfoDialog(
                            method['title']! as String,
                            method['desc']! as String,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                onPressed: widget.parent.nextPage,
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
