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
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: widget.parent.formKeyDiabetic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.insulinSettingsTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.insulinSettingsSubtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildParameterField(
                    controller: widget.parent.isfController,
                    labelText: l10n.isfLabel,
                    suffixText: l10n.isfSuffix,
                    infoTitle: l10n.isfInfoTitle,
                    infoDesc: l10n.isfInfoDesc,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),
                  _buildParameterField(
                    controller: widget.parent.ifpController,
                    labelText: l10n.ifpLabel,
                    suffixText: l10n.ifpSuffix,
                    infoTitle: l10n.ifpInfoTitle,
                    infoDesc: l10n.ifpInfoDesc,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        l10n.insulinDeliveryMethodLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
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
                  onPressed: () {
                    if (!widget.parent.formKeyDiabetic.currentState!
                        .validate()) {
                      return;
                    }
                    widget.parent.nextPage();
                  },
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
      ),
    );
  }

  Widget _buildParameterField({
    required TextEditingController controller,
    required String labelText,
    required String suffixText,
    required String infoTitle,
    required String infoDesc,
    required AppLocalizations l10n,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: labelText,
              suffixText: suffixText,
              border: const OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return l10n.errorFieldRequired;
              final n = double.tryParse(val.replaceAll(',', '.'));
              if (n == null || n <= 0) return l10n.errorValidationError;
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.info_outline,
            color: Colors.blue,
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
