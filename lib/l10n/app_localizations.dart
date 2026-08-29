import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GluQalc'**
  String get appTitle;

  /// No description provided for @snackbarOffline.
  ///
  /// In en, this message translates to:
  /// **'Internet connection lost.'**
  String get snackbarOffline;

  /// No description provided for @snackbarOnline.
  ///
  /// In en, this message translates to:
  /// **'Internet connection restored.'**
  String get snackbarOnline;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternetConnection;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @homeTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTabLabel;

  /// No description provided for @settingsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTabLabel;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccess;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created!'**
  String get signupSuccess;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signupButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountPrompt;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @passwordRuleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get passwordRuleMinLength;

  /// No description provided for @passwordRuleUpper.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get passwordRuleUpper;

  /// No description provided for @passwordRuleLower.
  ///
  /// In en, this message translates to:
  /// **'At least 1 lowercase letter'**
  String get passwordRuleLower;

  /// No description provided for @passwordRuleDigit.
  ///
  /// In en, this message translates to:
  /// **'At least 1 digit'**
  String get passwordRuleDigit;

  /// No description provided for @passwordRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'At least 1 special character'**
  String get passwordRuleSpecial;

  /// No description provided for @passwordRuleNoRepeating.
  ///
  /// In en, this message translates to:
  /// **'No 3 repeating characters'**
  String get passwordRuleNoRepeating;

  /// No description provided for @verifyAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account verified successfully! You can now log in.'**
  String get verifyAccountSuccess;

  /// No description provided for @verifyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get verifyScreenTitle;

  /// No description provided for @verifyScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We have sent a confirmation code to your email address.'**
  String get verifyScreenSubtitle;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifyButton;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorExternalProvider.
  ///
  /// In en, this message translates to:
  /// **'This account was registered via a different provider. Please use that method.'**
  String get errorExternalProvider;

  /// No description provided for @errorAccountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your account is not verified yet.'**
  String get errorAccountNotVerified;

  /// No description provided for @errorAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Your account has been locked for security reasons.'**
  String get errorAccountLocked;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get errorUserNotFound;

  /// No description provided for @errorPasswordTooCommon.
  ///
  /// In en, this message translates to:
  /// **'This password is too common. Please choose a stronger one.'**
  String get errorPasswordTooCommon;

  /// No description provided for @errorPasswordRepeatingChars.
  ///
  /// In en, this message translates to:
  /// **'Password contains too many repeating characters.'**
  String get errorPasswordRepeatingChars;

  /// No description provided for @errorPasswordPwned.
  ///
  /// In en, this message translates to:
  /// **'This password has appeared in a data breach. For your safety, please use a different one.'**
  String get errorPasswordPwned;

  /// No description provided for @errorPasswordAlreadySet.
  ///
  /// In en, this message translates to:
  /// **'A password has already been set for this account.'**
  String get errorPasswordAlreadySet;

  /// No description provided for @errorGoogleAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Google authentication failed. Please try again.'**
  String get errorGoogleAuthFailed;

  /// No description provided for @errorGoogleEmailMismatch.
  ///
  /// In en, this message translates to:
  /// **'The Google email address does not match your profile email.'**
  String get errorGoogleEmailMismatch;

  /// No description provided for @errorGoogleAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This Google account is already linked.'**
  String get errorGoogleAlreadyLinked;

  /// No description provided for @errorValidationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error. Please check the entered information.'**
  String get errorValidationError;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired or invalid credentials provided.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists.'**
  String get errorConflict;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorServerError.
  ///
  /// In en, this message translates to:
  /// **'Server problem. Try again later.'**
  String get errorServerError;

  /// No description provided for @errorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be between 8 and 255 characters.'**
  String get errorPasswordLength;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred (Code: {code}).'**
  String errorUnknown(Object code);

  /// No description provided for @errorInvalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code.'**
  String get errorInvalidVerificationCode;

  /// No description provided for @errorEmailAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This email address is already taken.'**
  String get errorEmailAlreadyTaken;

  /// No description provided for @errorEmailSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'The new email must be different from the current one.'**
  String get errorEmailSameAsCurrent;

  /// No description provided for @changeEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Wrong email?'**
  String get changeEmailButton;

  /// No description provided for @changeEmailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Email Address'**
  String get changeEmailDialogTitle;

  /// No description provided for @changeEmailDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current email, password, and the correct email address.'**
  String get changeEmailDialogSubtitle;

  /// No description provided for @newEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New email address'**
  String get newEmailLabel;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @currentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Current email address'**
  String get currentEmailLabel;

  /// No description provided for @changeEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email address updated. A new verification code has been sent.'**
  String get changeEmailSuccess;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get errorEmailRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordNotMet.
  ///
  /// In en, this message translates to:
  /// **'Password does not meet all security rules.'**
  String get errorPasswordNotMet;

  /// No description provided for @errorFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorFieldRequired;

  /// No description provided for @errorRequiredConsent.
  ///
  /// In en, this message translates to:
  /// **'You must accept required consents to use the app.'**
  String get errorRequiredConsent;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consentTitle;

  /// No description provided for @consentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get consentVersionLabel;

  /// No description provided for @consentRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'This consent is required'**
  String get consentRequiredLabel;

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @declineButton.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineButton;

  /// No description provided for @errorLoadingConsents.
  ///
  /// In en, this message translates to:
  /// **'Error loading consents'**
  String get errorLoadingConsents;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
