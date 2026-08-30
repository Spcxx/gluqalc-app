import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/config/app_config.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/presentation/widgets/app_drawer.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final uri = Uri.parse(urlString);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showErrorSnackBar(context, l10n);
      }
    } on Object catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, l10n);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.errorOpenUrl),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final versionAsync = ref.watch(appVersionProvider);

    final Widget githubIcon = Assets.icons.githubBlack.svg(
      height: 24,
      width: 24,
      colorFilter: ColorFilter.mode(
        colorScheme.onSurface.withValues(alpha: 0.7),
        BlendMode.srcIn,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          l10n.drawerAbout,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Assets.images.appLogo.image(
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            versionAsync.when(
              data: (version) => Text(
                'v$version',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              loading: () => const SizedBox(height: 17),
              error: (_, _) => const SizedBox(height: 17),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.aboutDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(l10n.aboutAuthor),
                    subtitle: const Text('Szymon Rózga'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(l10n.aboutContact),
                    subtitle: const Text(AppConfig.contactEmail),
                    onTap: () =>
                        _launchUrl(context, 'mailto:${AppConfig.contactEmail}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: githubIcon,
                    title: Text(l10n.aboutFrontendRepo),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _launchUrl(context, AppConfig.githubAppUrl),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: githubIcon,
                    title: Text(l10n.aboutBackendRepo),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _launchUrl(context, AppConfig.githubApiUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.aboutTos),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _launchUrl(context, AppConfig.tosUrl),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l10n.aboutPrivacy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _launchUrl(context, AppConfig.privacyUrl),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.medical_information_outlined),
                    title: Text(l10n.aboutDisclaimer),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _launchUrl(context, AppConfig.disclaimerUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
