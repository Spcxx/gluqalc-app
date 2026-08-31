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
          Text(
            l10n.insulinDoseDetailsTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              l10n.insulinTotalDose,
              '${dose.totalDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
              isBold: true,
            ),
            const Divider(height: 16),
            _buildDetailRow(
              context,
              l10n.insulinCarbDose,
              '${dose.carbDose.toStringAsFixed(2)} ${l10n.unitInsulin} (${dose.carbUnit.toStringAsFixed(1)} ${l10n.unitCarbExchange})',
            ),
            const SizedBox(height: 4),
            _buildDetailRow(
              context,
              l10n.insulinFatProteinDose,
              '${dose.fatProteinDose.toStringAsFixed(2)} ${l10n.unitInsulin} (${dose.fatProteinUnit.toStringAsFixed(1)} ${l10n.unitFatProteinExchange})',
            ),
            if (showDurationRow && durationText.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildDetailRow(
                context,
                l10n.insulinBolusDuration,
                durationText,
              ),
            ],
            if (descriptionSentences.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.insulinDescription,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              for (final sentence in descriptionSentences)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
          ],
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
      ),
    );
  }
}

Widget _buildDetailRow(
  BuildContext context,
  String label,
  String value, {
  bool isBold = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

Widget buildInsulinComponent(
  BuildContext context,
  InsulinDoseInfo? dose,
  ProfileResponse? profile,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  if (dose == null || dose.totalDose <= 0) {
    return Center(
      child: Text(
        '-',
        style: textTheme.bodyMedium?.copyWith(
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
    line2 = '+ ${dose.fatProteinDose.toStringAsFixed(2)}${l10n.unitInsulin}';
  }

  if (timeLabel.isNotEmpty) {
    line2 = line2.isNotEmpty ? '$line2 / $timeLabel' : timeLabel;
  }

  return InkWell(
    onTap: () => showInsulinDetailsModal(context, dose, profile, l10n),
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${primaryDose.toStringAsFixed(2)}${l10n.unitInsulin}',
            style: textTheme.bodyMedium?.copyWith(
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
