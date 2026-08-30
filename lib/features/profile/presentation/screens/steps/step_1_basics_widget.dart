import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step1BasicsWidget extends StatefulWidget {
  const Step1BasicsWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step1BasicsWidget> createState() => _Step1BasicsWidgetState();
}

class _Step1BasicsWidgetState extends State<Step1BasicsWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    final minDate = DateTime(now.year - 110, now.month, now.day);
    final initialDate = DateTime(now.year - 25);

    return Form(
      key: widget.parent.formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.genderLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<GenderEnum>(
                    emptySelectionAllowed: true,
                    segments: [
                      ButtonSegment(
                        value: GenderEnum.female,
                        label: Text(l10n.genderFemale),
                      ),
                      ButtonSegment(
                        value: GenderEnum.male,
                        label: Text(l10n.genderMale),
                      ),
                      ButtonSegment(
                        value: GenderEnum.other,
                        label: Text(l10n.genderOther),
                      ),
                    ],
                    selected: widget.parent.selectedGender != null
                        ? {widget.parent.selectedGender!}
                        : {},
                    onSelectionChanged: (newSelection) => setState(
                      () => widget.parent.selectedGender =
                          newSelection.firstOrNull,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.birthDateLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.centerLeft,
                    ),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      widget.parent.selectedBirthDate != null
                          ? '${widget.parent.selectedBirthDate!.toLocal()}'
                                .split(' ')[0]
                          : l10n.selectDate,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            widget.parent.selectedBirthDate ?? initialDate,
                        firstDate: minDate,
                        lastDate: maxDate,
                      );
                      if (picked != null) {
                        setState(
                          () => widget.parent.selectedBirthDate = picked,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.parent.heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.heightLabel,
                            suffixText: 'cm',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return l10n.errorFieldRequired;
                            }

                            final h = double.tryParse(val.replaceAll(',', '.'));
                            if (h == null || h < 100 || h > 250) {
                              return l10n.errorHeightRange;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: widget.parent.weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.weightLabel,
                            suffixText: 'kg',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return l10n.errorFieldRequired;
                            }

                            final w = double.tryParse(val.replaceAll(',', '.'));
                            if (w == null || w < 30 || w > 300) {
                              return l10n.errorWeightRange;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CheckboxListTile(
                          title: Text(
                            l10n.bodyFatCheckbox,
                            style: const TextStyle(fontSize: 14),
                          ),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: widget.parent.knowsBodyFat,
                          onChanged: (val) {
                            setState(() {
                              widget.parent.knowsBodyFat = val ?? false;
                              if (!widget.parent.knowsBodyFat) {
                                widget.parent.bodyFatController.clear();
                              }
                            });
                          },
                        ),
                        if (widget.parent.knowsBodyFat) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: widget.parent.bodyFatController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.bodyFatLabel,
                              suffixText: '%',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (!widget.parent.knowsBodyFat) return null;
                              if (val == null || val.isEmpty) {
                                return l10n.errorFieldRequired;
                              }

                              final bf = double.tryParse(
                                val.replaceAll(',', '.'),
                              );
                              if (bf == null || bf < 3 || bf > 65) {
                                return l10n.errorBodyFatRange;
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (!widget.parent.formKey1.currentState!.validate()) return;
              if (widget.parent.selectedGender == null ||
                  widget.parent.selectedBirthDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorFieldRequired)),
                );
                return;
              }

              final age =
                  DateTime.now()
                      .difference(widget.parent.selectedBirthDate!)
                      .inDays ~/
                  365;
              if (age < 18 || age > 110) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorValidationError)),
                );
                return;
              }

              if (!widget.parent.knowsBodyFat &&
                  widget.parent.selectedBmrMethod ==
                      BmrMethodEnum.katchMcArdle) {
                widget.parent.selectedBmrMethod = null;
              }
              widget.parent.nextPage();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.nextButton, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
