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
  final Set<String> _acceptedIds = {};
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

  Future<void> _handleAccept(List<ConsentResponse> consents) async {
    final allRequiredAccepted = consents
        .where((c) => c.required)
        .every((c) => _acceptedIds.contains(c.id));

    if (!allRequiredAccepted) {
      _showError(AppLocalizations.of(context)!.errorRequiredConsent);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(consentControllerProvider.notifier)
          .acceptConsents(_acceptedIds.toList());

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

        final allRequiredAccepted = consents
            .where((c) => c.required)
            .every((c) => _acceptedIds.contains(c.id));

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              l10n.consentTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authStateControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/auth');
                },
              ),
            ],
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
                        itemCount: consents.length,
                        itemBuilder: (context, index) {
                          final consent = consents[index];
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
                                          style: textTheme.titleMedium
                                              ?.copyWith(
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.consentRequiredLabel,
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onErrorContainer,
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
                                    value: _acceptedIds.contains(consent.id),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _acceptedIds.add(consent.id);
                                        } else {
                                          _acceptedIds.remove(consent.id);
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
                        onPressed: _isSubmitting || !allRequiredAccepted
                            ? null
                            : () => _handleAccept(consents),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
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
                    ),
                  ],
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
          title: Text(l10n.errorTitle),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorLoadingConsents),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(consentControllerProvider),
                child: Text(l10n.tryAgainButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
