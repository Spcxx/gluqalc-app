import 'package:flutter/material.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class Step3PalWidget extends StatefulWidget {
  const Step3PalWidget({required this.parent, super.key});
  final ProfileSetupScreenState parent;

  @override
  State<Step3PalWidget> createState() => _Step3PalWidgetState();
}

class _Step3PalWidgetState extends State<Step3PalWidget> {
  bool _isQuizComplete() {
    if (widget.parent.q1Answer == null ||
        widget.parent.q2Answer == null ||
        widget.parent.q3Answer == null) {
      return false;
    }
    if (widget.parent.q3Answer! > 0 && widget.parent.q4Answer == null) {
      return false;
    }
    return true;
  }

  void _recalculatePal() {
    var total = 1.1;
    if (widget.parent.q1Answer == 1) total += 0.10;
    if (widget.parent.q1Answer == 2) total += 0.25;
    if (widget.parent.q1Answer == 3) total += 0.40;
    if (widget.parent.q1Answer == 4) total += 0.60;

    if (widget.parent.q2Answer == 1) total += 0.10;
    if (widget.parent.q2Answer == 2) total += 0.15;
    if (widget.parent.q2Answer == 3) total += 0.25;

    if (widget.parent.q3Answer == 1) total += 0.05;
    if (widget.parent.q3Answer == 2) total += 0.10;
    if (widget.parent.q3Answer == 3) total += 0.15;

    if (widget.parent.q3Answer != null &&
        widget.parent.q3Answer! > 0 &&
        widget.parent.q4Answer != null) {
      if (widget.parent.q4Answer == 1) total += 0.05;
      if (widget.parent.q4Answer == 2) total += 0.10;
    }
    setState(
      () => widget.parent.palValue = double.parse(total.toStringAsFixed(2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canFinish = widget.parent.isManualPal || _isQuizComplete();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.palTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.palSubtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: widget.parent.isManualPal
              ? _buildManualPalEditor(l10n)
              : _buildPalQuiz(l10n),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: (!widget.parent.isManualPal && _isQuizComplete())
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAL: ${widget.parent.palValue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.readyToProceed,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              widget.parent.isManualPal = !widget.parent.isManualPal;
              if (!widget.parent.isManualPal) _recalculatePal();
            });
          },
          icon: Icon(widget.parent.isManualPal ? Icons.quiz : Icons.tune),
          label: Text(
            widget.parent.isManualPal
                ? l10n.quizPalSwitch
                : l10n.manualPalSwitch,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
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
                onPressed: canFinish ? widget.parent.nextPage : null,
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

  Widget _buildPalQuiz(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuizQuestion(
              title: l10n.palQ1Title,
              groupValue: widget.parent.q1Answer,
              onChanged: (val) {
                setState(() {
                  widget.parent.q1Answer = val;
                  _recalculatePal();
                });
              },
              options: [
                {
                  'value': 0,
                  'title': l10n.palQ1Opt0Title,
                  'desc': l10n.palQ1Opt0Desc,
                },
                {
                  'value': 1,
                  'title': l10n.palQ1Opt1Title,
                  'desc': l10n.palQ1Opt1Desc,
                },
                {
                  'value': 2,
                  'title': l10n.palQ1Opt2Title,
                  'desc': l10n.palQ1Opt2Desc,
                },
                {
                  'value': 3,
                  'title': l10n.palQ1Opt3Title,
                  'desc': l10n.palQ1Opt3Desc,
                },
                {
                  'value': 4,
                  'title': l10n.palQ1Opt4Title,
                  'desc': l10n.palQ1Opt4Desc,
                },
              ],
            ),
            if (widget.parent.q1Answer != null) ...[
              const SizedBox(height: 24),
              _buildQuizQuestion(
                title: l10n.palQ2Title,
                groupValue: widget.parent.q2Answer,
                onChanged: (val) {
                  setState(() {
                    widget.parent.q2Answer = val;
                    _recalculatePal();
                  });
                },
                options: [
                  {
                    'value': 0,
                    'title': l10n.palQ2Opt0Title,
                    'desc': l10n.palQ2Opt0Desc,
                  },
                  {
                    'value': 1,
                    'title': l10n.palQ2Opt1Title,
                    'desc': l10n.palQ2Opt1Desc,
                  },
                  {
                    'value': 2,
                    'title': l10n.palQ2Opt2Title,
                    'desc': l10n.palQ2Opt2Desc,
                  },
                  {
                    'value': 3,
                    'title': l10n.palQ2Opt3Title,
                    'desc': l10n.palQ2Opt3Desc,
                  },
                ],
              ),
            ],
            if (widget.parent.q2Answer != null) ...[
              const SizedBox(height: 24),
              _buildQuizQuestion(
                title: l10n.palQ3Title,
                groupValue: widget.parent.q3Answer,
                onChanged: (val) {
                  setState(() {
                    widget.parent.q3Answer = val;
                    if (widget.parent.q3Answer == 0) {
                      widget.parent.q4Answer = null;
                    }
                    _recalculatePal();
                  });
                },
                options: [
                  {
                    'value': 0,
                    'title': l10n.palQ3Opt0Title,
                    'desc': l10n.palQ3Opt0Desc,
                  },
                  {
                    'value': 1,
                    'title': l10n.palQ3Opt1Title,
                    'desc': l10n.palQ3Opt1Desc,
                  },
                  {
                    'value': 2,
                    'title': l10n.palQ3Opt2Title,
                    'desc': l10n.palQ3Opt2Desc,
                  },
                  {
                    'value': 3,
                    'title': l10n.palQ3Opt3Title,
                    'desc': l10n.palQ3Opt3Desc,
                  },
                ],
              ),
            ],
            if (widget.parent.q3Answer != null &&
                widget.parent.q3Answer! > 0) ...[
              const SizedBox(height: 24),
              _buildQuizQuestion(
                title: l10n.palQ4Title,
                groupValue: widget.parent.q4Answer,
                onChanged: (val) {
                  setState(() {
                    widget.parent.q4Answer = val;
                    _recalculatePal();
                  });
                },
                options: [
                  {
                    'value': 0,
                    'title': l10n.palQ4Opt0Title,
                    'desc': l10n.palQ4Opt0Desc,
                  },
                  {
                    'value': 1,
                    'title': l10n.palQ4Opt1Title,
                    'desc': l10n.palQ4Opt1Desc,
                  },
                  {
                    'value': 2,
                    'title': l10n.palQ4Opt2Title,
                    'desc': l10n.palQ4Opt2Desc,
                  },
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizQuestion({
    required String title,
    required int? groupValue,
    required ValueChanged<int?> onChanged,
    required List<Map<String, dynamic>> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        RadioGroup<int>(
          groupValue: groupValue,
          onChanged: onChanged,
          child: Column(
            children: options
                .map((opt) => _buildOptionCard(opt, groupValue, onChanged))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    Map<String, dynamic> opt,
    int? groupValue,
    ValueChanged<int?> onChanged,
  ) {
    final optValue = opt['value'] as int;
    final isSelected = groupValue == optValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(optValue),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<int>(
                value: optValue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opt['desc'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualPalEditor(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.parent.palValue.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          l10n.palMultiplierLabel,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 32),
        Slider(
          value: widget.parent.palValue,
          min: 1.10,
          max: 2.50,
          divisions: 140,
          label: widget.parent.palValue.toStringAsFixed(2),
          onChanged: (val) => setState(() => widget.parent.palValue = val),
        ),
      ],
    );
  }
}
