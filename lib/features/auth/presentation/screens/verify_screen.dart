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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(verifyControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        data: (_) {
          if (prev is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.verifyAccountSuccess),
                backgroundColor: colorScheme.tertiary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
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
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.verifyScreenSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                              l10n.verifyButton,
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
                          : () => _showChangeEmailDialog(context, l10n),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(l10n.changeEmailButton),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.l10n.changeEmailDialogTitle,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.l10n.changeEmailDialogSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldEmailController,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: widget.l10n.currentEmailLabel,
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
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                validator: (v) => v == null || v.isEmpty
                    ? widget.l10n.errorFieldRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: widget.l10n.currentPasswordLabel,
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
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                validator: (v) => v == null || v.isEmpty
                    ? widget.l10n.errorPasswordRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: widget.l10n.newEmailLabel,
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
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
                          backgroundColor: colorScheme.tertiary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  } on DioException catch (e) {
                    final errorMsg = widget.mapError(e, widget.l10n);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  } finally {
                    if (context.mounted) {
                      setState(() => _isDialogLoading = false);
                    }
                  }
                },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isDialogLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
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
