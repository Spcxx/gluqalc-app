import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/features/auth/data/models/consent_response.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/consent_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/widgets/password_rules_widget.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

String _mapDioError(
  DioException e,
  AppLocalizations l10n, {
  bool isSecondStep = false,
}) {
  final data = e.response?.data;
  final statusCode = e.response?.statusCode;
  String? rawServerMessage;

  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'];
    if (message is String) {
      rawServerMessage = message;
    } else if (message is Map) {
      rawServerMessage = message.values.join(' ');
    } else if (data.containsKey('errors')) {
      rawServerMessage = data['errors'].toString();
    }
  }

  if (rawServerMessage != null) {
    final msg = rawServerMessage.toLowerCase();
    if (msg.contains('invalid current password') ||
        msg.contains('invalid email or password')) {
      return l10n.errorInvalidPassword;
    }
    if (msg.contains('email is already taken')) {
      return l10n.errorEmailAlreadyTaken;
    }
    if (msg.contains('external providers')) {
      return l10n.errorExternalProvider;
    }
    if (msg.contains('invalid token') ||
        msg.contains('invalid code') ||
        msg.contains('does not match') ||
        msg.contains('mismatch')) {
      return l10n.errorInvalidVerificationCode;
    }
    if (msg.contains('too common')) return l10n.errorPasswordTooCommon;
    if (msg.contains('repeating characters')) {
      return l10n.errorPasswordRepeatingChars;
    }
    if (msg.contains('breach')) return l10n.errorPasswordPwned;
  }

  switch (statusCode) {
    case 400:
      return rawServerMessage != null && rawServerMessage.isNotEmpty
          ? '${l10n.errorValidationError}\n$rawServerMessage'
          : l10n.errorValidationError;
    case 401:
      return isSecondStep
          ? l10n.errorInvalidVerificationCode
          : l10n.errorInvalidPassword;
    case 404:
      return l10n.errorUserNotFound;
    case 409:
      return l10n.errorConflict;
    case 429:
      return l10n.errorTooManyRequests;
    case 500:
    case 502:
    case 503:
      return l10n.errorServerError;
    default:
      return l10n.errorUnknown(statusCode?.toString() ?? 'no connection');
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  String _currentPassword = '';

  bool _isFetchingConsents = false;
  List<ConsentResponse>? _registrationConsents;
  final Set<String> _acceptedConsentIds = {};
  bool _consentsAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchConsents() async {
    setState(() => _isFetchingConsents = true);
    try {
      final consents = await ref
          .read(consentControllerProvider.notifier)
          .getAllConsents();
      if (mounted) {
        setState(() {
          _registrationConsents = consents;
          _isFetchingConsents = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _isFetchingConsents = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _submit(AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    unawaited(
      ref
          .read(authControllerProvider.notifier)
          .submitForm(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            isLogin: _isLogin,
            l10n: l10n,
            acceptedConsents: _acceptedConsentIds.toList(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) async {
      await next.whenOrNull(
        error: (error, stackTrace) {
          final errorMessage = error.toString().replaceAll('Exception: ', '');

          if (errorMessage.contains('ACCOUNT_NOT_VERIFIED')) {
            context.go('/verify');
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        data: (_) async {
          if (prev is AsyncLoading) {
            if (_isLogin) {
              context.go('/consents');
            } else {
              context.go('/verify');
            }
          }
        },
      );
    });

    ref.listen<AppConnectionState>(connectivityServiceProvider, (prev, next) {
      if (next == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOffline),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (next == AppConnectionState.online &&
          prev == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOnline),
            backgroundColor: colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });

    final netState = ref.watch(connectivityServiceProvider);
    if (netState == AppConnectionState.loading ||
        netState == AppConnectionState.offlineStartup ||
        _isFetchingConsents) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ),
      );
    }

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    final rulesWidget = PasswordRulesWidget(password: _currentPassword);
    final trimmedEmail = _emailController.text.trim();
    final isValidEmail = _emailRegex.hasMatch(trimmedEmail);
    final isFormValid = isValidEmail && (_isLogin || rulesWidget.isValid);

    if (!_isLogin && !_consentsAccepted && _registrationConsents != null) {
      return _buildConsentList(context, l10n);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Assets.images.appLogo.image(
                        height: 100,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l10n.emailLabel,
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.2),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.errorEmailRequired;
                          }
                          if (!_emailRegex.hasMatch(value)) {
                            return l10n.errorInvalidEmail;
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        autofillHints: [
                          if (_isLogin)
                            AutofillHints.password
                          else
                            AutofillHints.newPassword,
                        ],
                        onFieldSubmitted: (_) {
                          if (isFormValid && !isLoading) _submit(l10n);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.passwordLabel,
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.2),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.errorPasswordRequired;
                          }
                          if (!_isLogin && !rulesWidget.isValid) {
                            return l10n.errorPasswordNotMet;
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _currentPassword = val;
                          });
                        },
                      ),
                      if (_isLogin) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      await showDialog<void>(
                                        context: context,
                                        builder: (ctx) => _ForgotPasswordDialog(
                                          l10n: l10n,
                                          initialEmail: _emailController.text
                                              .trim(),
                                        ),
                                      );
                                    },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(l10n.forgotPasswordButton),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                      ],
                      if (!_isLogin) ...[
                        rulesWidget,
                        const SizedBox(height: 24),
                      ],
                      FilledButton(
                        onPressed: (isFormValid && !isLoading)
                            ? () => _submit(l10n)
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                _isLogin ? l10n.loginButton : l10n.signupButton,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_isLogin) {
                                  await _fetchConsents();
                                  if (mounted) {
                                    setState(() {
                                      _isLogin = false;
                                      _consentsAccepted = false;
                                      _currentPassword = '';
                                      _passwordController.clear();
                                      _formKey.currentState?.reset();
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _isLogin = true;
                                    _consentsAccepted = false;
                                    _currentPassword = '';
                                    _passwordController.clear();
                                    _formKey.currentState?.reset();
                                  });
                                }
                              },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _isLogin
                              ? l10n.noAccountPrompt
                              : l10n.alreadyHaveAccountPrompt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsentList(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final allRequiredAccepted = _registrationConsents!
        .where((c) => c.required)
        .every((c) => _acceptedConsentIds.contains(c.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consentTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isLogin = true;
              _registrationConsents = null;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _registrationConsents!.length,
                    itemBuilder: (context, index) {
                      final consent = _registrationConsents![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      consent.code.replaceAll('_', ' '),
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (consent.required)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l10n.consentRequiredLabel,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                consent.description,
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                value: _acceptedConsentIds.contains(consent.id),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _acceptedConsentIds.add(consent.id);
                                    } else {
                                      _acceptedConsentIds.remove(consent.id);
                                    }
                                  });
                                },
                                title: Text(l10n.acceptButton),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: FilledButton(
                    onPressed: allRequiredAccepted
                        ? () {
                            setState(() {
                              _consentsAccepted = true;
                            });
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.continueButton,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({required this.l10n, required this.initialEmail});
  final AppLocalizations l10n;
  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final colorScheme = Theme.of(context).colorScheme;

    final passwordRules = PasswordRulesWidget(
      password: _newPasswordController.text,
    );
    if (_isCodeSent && !passwordRules.isValid) return;

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);

    try {
      if (!_isCodeSent) {
        await repo.requestPasswordReset(email: _emailController.text.trim());
        if (mounted) setState(() => _isCodeSent = true);
      } else {
        await repo.confirmPasswordReset(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.l10n.passwordChangedSuccessfully),
              backgroundColor: colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mapDioError(e, widget.l10n, isSecondStep: _isCodeSent),
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final rulesWidget = PasswordRulesWidget(
      password: _newPasswordController.text,
    );
    final isCodeValid = _codeController.text.trim().length == 6;

    final emailValid = _emailRegex.hasMatch(_emailController.text.trim());
    final canSubmitStep1 = emailValid;
    final canSubmitStep2 = isCodeValid && rulesWidget.isValid;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.l10n.forgotPasswordButton,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isCodeSent
                    ? widget.l10n.forgotPasswordCodeSubtitle
                    : widget.l10n.forgotPasswordDialogSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (!_isCodeSent) ...[
                TextFormField(
                  controller: _emailController,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: widget.l10n.emailLabel,
                    labelStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.2,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return widget.l10n.errorEmailRequired;
                    }
                    if (!_emailRegex.hasMatch(v.trim())) {
                      return widget.l10n.errorInvalidEmail;
                    }
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      letterSpacing: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.2,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return widget.l10n.errorInvalidVerificationCode;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isPasswordVisible,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: widget.l10n.newPasswordLabel,
                    labelStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.2,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v == null || v.isEmpty
                      ? widget.l10n.errorFieldRequired
                      : null,
                ),
                const SizedBox(height: 12),
                rulesWidget,
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed:
              _isLoading ||
                  (!_isCodeSent && !canSubmitStep1) ||
                  (_isCodeSent && !canSubmitStep2)
              ? null
              : _submit,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  _isCodeSent
                      ? widget.l10n.verifyButton
                      : widget.l10n.sendCodeButton,
                ),
        ),
      ],
    );
  }
}
