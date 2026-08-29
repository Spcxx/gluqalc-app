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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
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
    final l10n = AppLocalizations.of(context)!;
    final consentsAsync = ref.watch(consentControllerProvider);

    return consentsAsync.when(
      data: (consents) {
        if (consents.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_currentIndex >= consents.length) {
          _currentIndex = consents.length - 1;
        }

        final consent = consents[_currentIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${l10n.consentTitle} ${_currentIndex + 1} / ${consents.length}',
            ),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / consents.length,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.consentVersionLabel}: ${consent.version}',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          consent.description,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (consent.required)
                    Text(
                      l10n.consentRequiredLabel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleAccept(consents, l10n),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.acceptButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleDecline(consents, l10n),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      l10n.declineButton,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.errorTitle),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingConsents,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(consentControllerProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.tryAgainButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
