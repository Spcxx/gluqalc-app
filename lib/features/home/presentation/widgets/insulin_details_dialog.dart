import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

final _decimalDotRegExp = RegExp(r'(\d)\.(\d)');
final _abbrRegExp = RegExp(r'\b(approx|np|dr|m\.in|tj|tzv|ul)\.');

String getInsulinDurationText(InsulinDoseInfo dose, ProfileResponse? profile) {
  final isPen = profile?.insulinDeliveryMethod == 'PEN';
  final isPankowska = profile?.combinedInsulinCalculationMethod == 'PANKOWSKA';

  if (isPankowska && isPen) {
    return '2-4h';
  } else if (isPen) {
    return 'ext.';
  } else if (dose.bolusDurationMinutes > 0) {
    final hours = dose.bolusDurationMinutes / 60.0;
    return hours == hours.toInt()
        ? '${hours.toInt()}h'
        : '${hours.toStringAsFixed(1)}h';
  }
  return '';
}

Future<void> showInsulinDetailsModal(
  BuildContext context,
  InsulinDoseInfo dose,
  ProfileResponse? profile,
  AppLocalizations l10n,
) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  var descriptionSentences = <String>[];
  if (dose.description != null && dose.description!.isNotEmpty) {
    var desc = dose.description!;
    desc = desc.replaceAllMapped(
      _decimalDotRegExp,
      (m) => '${m[1]}___DOT___${m[2]}',
    );
    desc = desc.replaceAllMapped(_abbrRegExp, (m) => '${m[1]}___DOT___');

    descriptionSentences = desc
        .split('.')
        .map((s) => s.replaceAll('___DOT___', '.').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  final durationText = getInsulinDurationText(dose, profile);
  final isPen = profile?.insulinDeliveryMethod == 'PEN';
  final showDurationRow =
      dose.bolusDurationMinutes > 0 || (isPen && dose.fatProteinDose > 0);

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.bolt, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.insulinDoseDetailsTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 340;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.insulinTotalDose,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${dose.totalDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        if (isNarrow) ...[
                          _buildPrimaryDoseCol(
                            context: context,
                            title: l10n.insulinCarbDose,
                            doseVal: dose.carbDose,
                            unit: dose.carbUnit,
                            unitLabel: l10n.unitCarbExchange,
                            l10n: l10n,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                              height: 1,
                            ),
                          ),
                          _buildPrimaryDoseCol(
                            context: context,
                            title: l10n.insulinFatProteinDose,
                            doseVal: dose.fatProteinDose,
                            unit: dose.fatProteinUnit,
                            unitLabel: l10n.unitFatProteinExchange,
                            durationText: showDurationRow ? durationText : null,
                            l10n: l10n,
                          ),
                        ] else ...[
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildPrimaryDoseCol(
                                    context: context,
                                    title: l10n.insulinCarbDose,
                                    doseVal: dose.carbDose,
                                    unit: dose.carbUnit,
                                    unitLabel: l10n.unitCarbExchange,
                                    l10n: l10n,
                                  ),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                Expanded(
                                  child: _buildPrimaryDoseCol(
                                    context: context,
                                    title: l10n.insulinFatProteinDose,
                                    doseVal: dose.fatProteinDose,
                                    unit: dose.fatProteinUnit,
                                    unitLabel: l10n.unitFatProteinExchange,
                                    durationText: showDurationRow
                                        ? durationText
                                        : null,
                                    l10n: l10n,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (descriptionSentences.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.insulinDescription,
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (final sentence in descriptionSentences)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDescriptionSentence(
                                      context,
                                      sentence,
                                      colorScheme,
                                      textTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(l10n.closeButton),
        ),
      ],
    ),
  );
}

Widget _buildPrimaryDoseCol({
  required BuildContext context,
  required String title,
  required double doseVal,
  required double unit,
  required String unitLabel,
  required AppLocalizations l10n,
  String? durationText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Column(
    children: [
      Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 6),
      Text(
        '${doseVal.toStringAsFixed(2)} ${l10n.unitInsulin}',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 2),
      Text(
        '${unit.toStringAsFixed(1)} $unitLabel',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      if (durationText != null && durationText.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            durationText,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ],
  );
}

Widget _buildDescriptionSentence(
  BuildContext context,
  String sentence,
  ColorScheme colorScheme,
  TextTheme textTheme,
) {
  final colonIndex = sentence.indexOf(':');
  if (colonIndex != -1) {
    final prefix = sentence.substring(0, colonIndex + 1);
    final content = sentence.substring(colonIndex + 1).trim();
    return RichText(
      text: TextSpan(
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontFamily: DefaultTextStyle.of(context).style.fontFamily,
          height: 1.3,
        ),
        children: [
          TextSpan(
            text: '$prefix ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '$content.',
          ),
        ],
      ),
    );
  } else {
    return Text(
      '$sentence.',
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        height: 1.3,
      ),
    );
  }
}

Widget buildInsulinComponent(
  BuildContext context,
  InsulinDoseInfo? dose,
  ProfileResponse? profile,
  AppLocalizations l10n, {
  bool isNarrow = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  if (dose == null || dose.totalDose <= 0) {
    return Center(
      child: Text(
        '-',
        style: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  final primaryDose = dose.carbDose > 0 ? dose.carbDose : dose.totalDose;
  final timeLabel = getInsulinDurationText(dose, profile);

  var line2 = '';
  if (dose.fatProteinDose > 0) {
    line2 = isNarrow
        ? '+${dose.fatProteinDose.toStringAsFixed(1)}u'
        : '+ ${dose.fatProteinDose.toStringAsFixed(2)} ${l10n.unitInsulin}';
  }

  final isPen = profile?.insulinDeliveryMethod == 'PEN';
  final showDuration =
      dose.bolusDurationMinutes > 0 || (isPen && dose.fatProteinDose > 0);

  if (showDuration && timeLabel.isNotEmpty) {
    line2 = line2.isNotEmpty
        ? (isNarrow ? '$line2/$timeLabel' : '$line2 / $timeLabel')
        : timeLabel;
  }

  return InkWell(
    onTap: () => showInsulinDetailsModal(context, dose, profile, l10n),
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isNarrow
                ? '${primaryDose.toStringAsFixed(1)}u'
                : '${primaryDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
            style: textTheme.bodySmall?.copyWith(
              fontSize: isNarrow ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          if (line2.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              line2,
              style: textTheme.bodySmall?.copyWith(
                fontSize: isNarrow ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}
