// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GluQalc';

  @override
  String get snackbarOffline => 'Internet connection lost.';

  @override
  String get snackbarOnline => 'Internet connection restored.';

  @override
  String get noInternetConnection => 'No internet connection.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get homeTabLabel => 'Home';

  @override
  String get settingsTabLabel => 'Settings';
}
