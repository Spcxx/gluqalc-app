import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/features/auth/data/repositories/auth_repository.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/verify_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    FocusScope.of(context).unfocus();
    unawaited(
      ref
          .read(verifyControllerProvider.notifier)
          .verifyCode(
            code: _codeController.text.trim(),
            l10n: l10n,
          ),
    );
  }

  String _mapDioErrorToL10n(DioException e, AppLocalizations l10n) {
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

    if (rawServerMessage != null && rawServerMessage.isNotEmpty) {
      final msg = rawServerMessage.toLowerCase();

      if (msg.contains('invalid email or password')) {
        return l10n.errorInvalidCredentials;
      }
      if (msg.contains('account is already verified')) {
        return l10n.errorConflict;
      }
      if (msg.contains('new email must be different')) {
        return l10n.errorConflict;
      }
      if (msg.contains('email is already taken') ||
          msg.contains('already exists')) {
        return l10n.errorConflict;
      }
      if (msg.contains('password must be between')) {
        return l10n.errorPasswordLength;
      }
      if (msg.contains('password is too common')) {
        return l10n.errorPasswordTooCommon;
      }
      if (msg.contains('too many repeating characters')) {
        return l10n.errorPasswordRepeatingChars;
      }
      if (msg.contains('appeared in a data breach')) {
        return l10n.errorPasswordPwned;
      }
    }

    switch (statusCode) {
      case 400:
        return l10n.errorValidationError;
      case 401:
        return l10n.errorUnauthorized;
      case 409:
        return l10n.errorConflict;
      case 429:
        return l10n.errorTooManyRequests;
      case 500:
      case 502:
      case 503:
        return l10n.errorServerError;
      default:
        if (rawServerMessage != null && rawServerMessage.isNotEmpty) {
          return rawServerMessage;
        }
        return l10n.errorUnknown(statusCode?.toString() ?? 'no connection');
    }
  }

  void _showChangeEmailDialog(BuildContext context, AppLocalizations l10n) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => _ChangeEmailDialog(
          l10n: l10n,
          mapError: _mapDioErrorToL10n,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(verifyControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        data: (_) {
          if (prev is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.verifyAccountSuccess),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/auth');
          }
        },
      );
    });

    final verifyState = ref.watch(verifyControllerProvider);
    final isLoading = verifyState.isLoading;
    final isFormValid = _codeController.text.trim().length == 6;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Assets.images.appLogo.image(height: 100),
                  const SizedBox(height: 32),
                  Text(
                    l10n.verifyScreenTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.verifyScreenSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),

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
                    onFieldSubmitted: (_) {
                      if (isFormValid && !isLoading) _submit(l10n);
                    },
                  ),

                  const SizedBox(height: 24),
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
                            l10n.verifyButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => _showChangeEmailDialog(context, l10n),
                    child: Text(l10n.changeEmailButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeEmailDialog extends ConsumerStatefulWidget {
  const _ChangeEmailDialog({
    required this.l10n,
    required this.mapError,
  });

  final AppLocalizations l10n;
  final String Function(DioException, AppLocalizations) mapError;

  @override
  ConsumerState<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends ConsumerState<_ChangeEmailDialog> {
  final _oldEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isDialogLoading = false;

  @override
  void dispose() {
    _oldEmailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.changeEmailDialogTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.l10n.changeEmailDialogSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: widget.l10n.currentEmailLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? widget.l10n.errorFieldRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.l10n.currentPasswordLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? widget.l10n.errorPasswordRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: widget.l10n.newEmailLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? widget.l10n.errorFieldRequired
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDialogLoading ? null : () => Navigator.pop(context),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
        FilledButton(
          onPressed: _isDialogLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isDialogLoading = true);

                  try {
                    final repo = ref.read(authRepositoryProvider);
                    await repo.changeUnverifiedEmail(
                      oldEmail: _oldEmailController.text.trim(),
                      password: _passwordController.text,
                      newEmail: _newEmailController.text.trim(),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.l10n.changeEmailSuccess),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    final errorMsg = widget.mapError(e, widget.l10n);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } finally {
                    if (context.mounted) {
                      setState(() => _isDialogLoading = false);
                    }
                  }
                },
          child: _isDialogLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.l10n.verifyButton,
                ),
        ),
      ],
    );
  }
}
