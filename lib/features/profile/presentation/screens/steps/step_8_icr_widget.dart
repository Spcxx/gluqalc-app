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
    final l10n = AppLocalizations.of(context)!;
    final stringError = widget.parent.validateHourlyIcr(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.icrTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
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
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
          icon: const Icon(Icons.add),
          label: Text(l10n.addHourButton),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: stringError == null
                ? Colors.green.shade50
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: stringError == null
                  ? Colors.green.shade200
                  : Colors.red.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                stringError == null ? Icons.check_circle : Icons.error_outline,
                color: stringError == null ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stringError ?? l10n.icrConfigValid,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: stringError == null
                        ? Colors.green.shade800
                        : Colors.red.shade800,
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
              ),
              child: Text(
                l10n.backButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: stringError == null ? widget.parent.nextPage : null,
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

  Widget _buildIcrCard(HourIcrItem item, int index, AppLocalizations l10n) {
    return Card(
      key: ObjectKey(item),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                initialValue: item.hour,
                decoration: InputDecoration(
                  labelText: l10n.hourLabel,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                items: List.generate(
                  24,
                  (h) => DropdownMenuItem(
                    value: h,
                    child: Text('$h:00'),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.icrValueLabel,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) {
                  item.icrValue =
                      double.tryParse(val.replaceAll(',', '.')) ?? 0;
                },
              ),
            ),
            if (widget.parent.hourIcrItems.length > 1)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
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
