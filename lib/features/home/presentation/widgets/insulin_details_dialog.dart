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
  final colorScheme = Theme.of(context).colorScheme;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.bolt, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            l10n.insulinDoseDetailsTitle,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            l10n.insulinTotalDose,
            '${dose.totalDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
            isBold: true,
          ),
          const Divider(height: 16),
          _buildDetailRow(
            l10n.insulinCarbDose,
            '${dose.carbDose.toStringAsFixed(2)} ${l10n.unitInsulin} (${dose.carbUnit.toStringAsFixed(1)} ${l10n.unitCarbExchange})',
          ),
          _buildDetailRow(
            l10n.insulinFatProteinDose,
            '${dose.fatProteinDose.toStringAsFixed(2)} ${l10n.unitInsulin} (${dose.fatProteinUnit.toStringAsFixed(1)} ${l10n.unitFatProteinExchange})',
          ),
          if (showDurationRow && durationText.isNotEmpty)
            _buildDetailRow(
              l10n.insulinBolusDuration,
              durationText,
            ),
          if (descriptionSentences.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.insulinDescription,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildDescriptionSentence(
                        context,
                        sentence,
                        colorScheme,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
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
) {
  final colonIndex = sentence.indexOf(':');
  if (colonIndex != -1) {
    final prefix = sentence.substring(0, colonIndex + 1);
    final content = sentence.substring(colonIndex + 1).trim();
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
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
      style: TextStyle(
        fontSize: 13,
        color: colorScheme.onSurface,
      ),
    );
  }
}

Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// Funkcja publiczna używana w kategoriach i posiłkach
Widget buildInsulinComponent(
  BuildContext context,
  InsulinDoseInfo? dose,
  ProfileResponse? profile,
  AppLocalizations l10n,
) {
  final colorScheme = Theme.of(context).colorScheme;

  if (dose == null || dose.totalDose <= 0) {
    return Center(
      child: Text(
        '-',
        style: TextStyle(
          fontSize: 14,
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
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${primaryDose.toStringAsFixed(2)}${l10n.unitInsulin}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          if (line2.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              line2,
              style: TextStyle(
                fontSize: 11,
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
