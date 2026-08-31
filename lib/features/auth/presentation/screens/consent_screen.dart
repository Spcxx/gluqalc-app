import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/auth/data/models/consent_response.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/consent_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  int _currentIndex = 0;
  final List<String> _collectedAcceptedIds = [];

  bool _isSubmitting = false;

  void _showError(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleAccept(
    List<ConsentResponse> consents,
    AppLocalizations l10n,
  ) async {
    final currentConsent = consents[_currentIndex];
    _collectedAcceptedIds.add(currentConsent.id);

    if (_currentIndex < consents.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() => _isSubmitting = true);
      try {
        await ref
            .read(consentControllerProvider.notifier)
            .acceptConsents(_collectedAcceptedIds);

        if (mounted) {
          context.go('/home');
        }
      } on Object catch (e) {
        if (mounted) {
          _showError(e.toString());
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  Future<void> _handleDecline(
    List<ConsentResponse> consents,
    AppLocalizations l10n,
  ) async {
    final currentConsent = consents[_currentIndex];

    if (currentConsent.required) {
      _showError(l10n.errorRequiredConsent);

      setState(() => _isSubmitting = true);
      await ref.read(authStateControllerProvider.notifier).logout();
      if (mounted) {
        context.go('/auth');
      }
    } else {
      if (_currentIndex < consents.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        setState(() => _isSubmitting = true);
        try {
          await ref
              .read(consentControllerProvider.notifier)
              .acceptConsents(_collectedAcceptedIds);

          if (mounted) {
            context.go('/home');
          }
        } on Object catch (e) {
          if (mounted) {
            _showError(e.toString());
            setState(() => _isSubmitting = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final consentsAsync = ref.watch(consentControllerProvider);

    return consentsAsync.when(
      data: (consents) {
        if (consents.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home');
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        if (_currentIndex >= consents.length) {
          _currentIndex = consents.length - 1;
        }

        final consent = consents[_currentIndex];

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '${l10n.consentTitle} ${_currentIndex + 1} / ${consents.length}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / consents.length,
                          minHeight: 6,
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.consentVersionLabel}: ${consent.version}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Text(
                                consent.description,
                                style: textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (consent.required)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            l10n.consentRequiredLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleAccept(consents, l10n),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                l10n.acceptButton,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleDecline(consents, l10n),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          l10n.declineButton,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            l10n.errorTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logoutTooltip,
              onPressed: () async {
                await ref.read(authStateControllerProvider.notifier).logout();
              },
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingConsents,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(consentControllerProvider);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      l10n.tryAgainButton,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
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
