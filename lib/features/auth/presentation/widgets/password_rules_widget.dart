import 'package:flutter/material.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';

class PasswordRulesWidget extends StatelessWidget {
  const PasswordRulesWidget({required this.password, super.key});

  final String password;

  static final _upperRegex = RegExp('[A-Z]');
  static final _lowerRegex = RegExp('[a-z]');
  static final _digitRegex = RegExp('[0-9]');
  static final _specialRegex = RegExp(r'[!@#$&*~%^_\-+={\}\[\]|:;"\x27<>,.?/]');
  static final _repeatingRegex = RegExp(r'(.)\1{3,}');

  bool get hasMinLength => password.length >= 8;
  bool get hasUpper => _upperRegex.hasMatch(password);
  bool get hasLower => _lowerRegex.hasMatch(password);
  bool get hasDigit => _digitRegex.hasMatch(password);
  bool get hasSpecial => _specialRegex.hasMatch(password);

  bool get noRepeating =>
      !_repeatingRegex.hasMatch(password) && password.isNotEmpty;

  bool get isValid =>
      hasMinLength &&
      hasUpper &&
      hasLower &&
      hasDigit &&
      hasSpecial &&
      noRepeating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRuleItem(context, l10n.passwordRuleMinLength, hasMinLength),
        _buildRuleItem(context, l10n.passwordRuleUpper, hasUpper),
        _buildRuleItem(context, l10n.passwordRuleLower, hasLower),
        _buildRuleItem(context, l10n.passwordRuleDigit, hasDigit),
        _buildRuleItem(context, l10n.passwordRuleSpecial, hasSpecial),
        _buildRuleItem(context, l10n.passwordRuleNoRepeating, noRepeating),
      ],
    );
  }

  Widget _buildRuleItem(BuildContext context, String text, bool isMet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: isMet
                  ? colorScheme.tertiary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
