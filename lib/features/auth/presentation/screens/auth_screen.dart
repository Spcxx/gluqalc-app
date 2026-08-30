import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_controller.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          final errorMessage = error.toString().replaceAll('Exception: ', '');

          if (errorMessage.contains('ACCOUNT_NOT_VERIFIED')) {
            context.go('/verify');
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
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
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next == AppConnectionState.online &&
          prev == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOnline),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final netState = ref.watch(connectivityServiceProvider);
    if (netState == AppConnectionState.loading ||
        netState == AppConnectionState.offlineStartup) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
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
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
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
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
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
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? l10n.loginButton : l10n.signupButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _currentPassword = '';
                                _passwordController.clear();
                                _formKey.currentState?.reset();
                              });
                            },
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
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
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
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rulesWidget = PasswordRulesWidget(
      password: _newPasswordController.text,
    );
    final isCodeValid = _codeController.text.trim().length == 6;

    final emailValid = _emailRegex.hasMatch(_emailController.text.trim());
    final canSubmitStep1 = emailValid;
    final canSubmitStep2 = isCodeValid && rulesWidget.isValid;

    return AlertDialog(
      title: Text(widget.l10n.forgotPasswordButton),
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
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              if (!_isCodeSent) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: widget.l10n.emailLabel,
                    border: const OutlineInputBorder(),
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
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      letterSpacing: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: widget.l10n.newPasswordLabel,
                    border: const OutlineInputBorder(),
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
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed:
              _isLoading ||
                  (!_isCodeSent && !canSubmitStep1) ||
                  (_isCodeSent && !canSubmitStep2)
              ? null
              : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
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
