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
    var total = 1.20;

    if (widget.parent.q1Answer == 1) {
      total = 1.40;
    } else if (widget.parent.q1Answer == 2) {
      total = 1.65;
    } else if (widget.parent.q1Answer == 3) {
      total = 1.85;
    } else if (widget.parent.q1Answer == 4) {
      total = 2.0;
    }

    if (widget.parent.q2Answer == 1) {
      total += 0.04;
    } else if (widget.parent.q2Answer == 2) {
      total += 0.08;
    } else if (widget.parent.q2Answer == 3) {
      total += 0.15;
    }

    if (widget.parent.q3Answer == 1) {
      total += 0.02;
    } else if (widget.parent.q3Answer == 2) {
      total += 0.06;
    } else if (widget.parent.q3Answer == 3) {
      total += 0.12;
    }

    if (widget.parent.q3Answer != null &&
        widget.parent.q3Answer! > 0 &&
        widget.parent.q4Answer != null) {
      if (widget.parent.q4Answer == 1) total += 0.03;
      if (widget.parent.q4Answer == 2) total += 0.07;
    }

    setState(
      () => widget.parent.palValue = total.clamp(1.1, 2.4),
    );
    widget.parent.recalculateDraftTargets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final canFinish = widget.parent.isManualPal || _isQuizComplete();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.palTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.palSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
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
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PAL: ${widget.parent.palValue.toStringAsFixed(2)}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.readyToProceed,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
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
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(widget.parent.isManualPal ? Icons.quiz : Icons.tune),
            label: Text(
              widget.parent.isManualPal
                  ? l10n.quizPalSwitch
                  : l10n.manualPalSwitch,
              textAlign: TextAlign.center,
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
                  onPressed: canFinish ? widget.parent.nextPage : null,
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
      ),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.05)
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
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opt['desc'] as String,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.parent.palValue.toStringAsFixed(2),
          style: textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          l10n.palMultiplierLabel,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 32),
        Slider(
          value: widget.parent.palValue,
          min: 1.10,
          max: 2.50,
          divisions: 140,
          label: widget.parent.palValue.toStringAsFixed(2),
          onChanged: (val) {
            setState(() => widget.parent.palValue = val);
            widget.parent.recalculateDraftTargets();
          },
        ),
      ],
    );
  }
}
