import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step2BmrWidget extends StatefulWidget {
  const Step2BmrWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step2BmrWidget> createState() => _Step2BmrWidgetState();
}

class _Step2BmrWidgetState extends State<Step2BmrWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final recommendedMethod = widget.parent.getRecommendedBmrMethod();
    final isBodyFatProvided =
        widget.parent.knowsBodyFat &&
        widget.parent.bodyFatController.text.isNotEmpty;

    final availableMethods = [
      {
        'enum': BmrMethodEnum.harrisBenedict,
        'title': l10n.bmrHarrisTitle,
        'desc': l10n.bmrHarrisDesc,
      },
      {
        'enum': BmrMethodEnum.mifflinStJeor,
        'title': l10n.bmrMifflinTitle,
        'desc': l10n.bmrMifflinDesc,
      },
      {
        'enum': BmrMethodEnum.katchMcArdle,
        'title': l10n.bmrKatchTitle,
        'desc': l10n.bmrKatchDesc,
        'requiresBodyFat': true,
      },
      {
        'enum': BmrMethodEnum.owen,
        'title': l10n.bmrOwenTitle,
        'desc': l10n.bmrOwenDesc,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.bmrMethodTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bmrMethodSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RadioGroup<BmrMethodEnum>(
            groupValue: widget.parent.selectedBmrMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() => widget.parent.selectedBmrMethod = val);
                widget.parent.recalculateDraftTargets();
              }
            },
            child: ListView.separated(
              itemCount: availableMethods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = availableMethods[index];
                final bmrEnum = method['enum']! as BmrMethodEnum;
                final requiresBF = method['requiresBodyFat'] == true;
                final isDisabled = requiresBF && !isBodyFatProvided;
                final isRecommended =
                    bmrEnum == recommendedMethod && !isDisabled;
                final isSelected = widget.parent.selectedBmrMethod == bmrEnum;

                return Opacity(
                  opacity: isDisabled ? 0.5 : 1.0,
                  child: InkWell(
                    onTap: isDisabled
                        ? null
                        : () {
                            setState(
                              () => widget.parent.selectedBmrMethod = bmrEnum,
                            );
                            widget.parent.recalculateDraftTargets();
                          },
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
                          Radio<BmrMethodEnum>(
                            value: bmrEnum,
                            enabled: !isDisabled,
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
                                if (isDisabled) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.katchMcArdleDisabledReason,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                ],
                                if (isRecommended && !isDisabled) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.recommendedForYou,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
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
                  ),
                );
              },
            ),
          ),
        ),
        widget.parent.buildDraftTargetBanner(l10n, colorScheme, textTheme),
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
                onPressed: widget.parent.selectedBmrMethod != null
                    ? widget.parent.nextPage
                    : null,
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
