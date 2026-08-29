import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/widgets/password_rules_widget.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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
        data: (_) {
          if (prev is AsyncLoading) {
            if (_isLogin) {
              context.go('/home');
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
                    const SizedBox(height: 16),
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
