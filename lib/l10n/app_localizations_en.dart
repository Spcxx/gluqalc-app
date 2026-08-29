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

  @override
  String get loginSuccess => 'Logged in successfully!';

  @override
  String get signupSuccess => 'Account created!';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Log in';

  @override
  String get signupButton => 'Sign up';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account? Log in';

  @override
  String get passwordRuleMinLength => 'Minimum 8 characters';

  @override
  String get passwordRuleUpper => 'At least 1 uppercase letter';

  @override
  String get passwordRuleLower => 'At least 1 lowercase letter';

  @override
  String get passwordRuleDigit => 'At least 1 digit';

  @override
  String get passwordRuleSpecial => 'At least 1 special character';

  @override
  String get passwordRuleNoRepeating => 'No 3 repeating characters';

  @override
  String get verifyAccountSuccess =>
      'Account verified successfully! You can now log in.';

  @override
  String get verifyScreenTitle => 'Enter verification code';

  @override
  String get verifyScreenSubtitle =>
      'We have sent a confirmation code to your email address.';

  @override
  String get verifyButton => 'Confirm';

  @override
  String get errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get errorExternalProvider =>
      'This account was registered via a different provider. Please use that method.';

  @override
  String get errorAccountNotVerified => 'Your account is not verified yet.';

  @override
  String get errorAccountLocked =>
      'Your account has been locked for security reasons.';

  @override
  String get errorUserNotFound => 'User not found.';

  @override
  String get errorPasswordTooCommon =>
      'This password is too common. Please choose a stronger one.';

  @override
  String get errorPasswordRepeatingChars =>
      'Password contains too many repeating characters.';

  @override
  String get errorPasswordPwned =>
      'This password has appeared in a data breach. For your safety, please use a different one.';

  @override
  String get errorPasswordAlreadySet =>
      'A password has already been set for this account.';

  @override
  String get errorGoogleAuthFailed =>
      'Google authentication failed. Please try again.';

  @override
  String get errorGoogleEmailMismatch =>
      'The Google email address does not match your profile email.';

  @override
  String get errorGoogleAlreadyLinked =>
      'This Google account is already linked.';

  @override
  String get errorValidationError =>
      'Validation error. Please check the entered information.';

  @override
  String get errorUnauthorized =>
      'Session expired or invalid credentials provided.';

  @override
  String get errorForbidden =>
      'You do not have permission to perform this action.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get errorConflict =>
      'An account with this email address already exists.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please wait and try again.';

  @override
  String get errorServerError => 'Server problem. Try again later.';

  @override
  String get errorPasswordLength =>
      'Password must be between 8 and 255 characters.';

  @override
  String errorUnknown(Object code) {
    return 'An unknown error occurred (Code: $code).';
  }

  @override
  String get errorInvalidVerificationCode =>
      'Invalid or expired verification code.';

  @override
  String get errorEmailAlreadyTaken => 'This email address is already taken.';

  @override
  String get errorEmailSameAsCurrent =>
      'The new email must be different from the current one.';

  @override
  String get changeEmailButton => 'Wrong email?';

  @override
  String get changeEmailDialogTitle => 'Change Email Address';

  @override
  String get changeEmailDialogSubtitle =>
      'Enter your current email, password, and the correct email address.';

  @override
  String get newEmailLabel => 'New email address';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get currentEmailLabel => 'Current email address';

  @override
  String get changeEmailSuccess =>
      'Email address updated. A new verification code has been sent.';

  @override
  String get errorEmailRequired => 'Email is required.';

  @override
  String get errorInvalidEmail => 'Invalid email format.';

  @override
  String get errorPasswordRequired => 'Password is required.';

  @override
  String get errorPasswordNotMet =>
      'Password does not meet all security rules.';

  @override
  String get errorFieldRequired => 'This field is required.';

  @override
  String get errorRequiredConsent =>
      'You must accept required consents to use the app.';

  @override
  String get consentTitle => 'Consent';

  @override
  String get consentVersionLabel => 'Version';

  @override
  String get consentRequiredLabel => 'This consent is required';

  @override
  String get acceptButton => 'Accept';

  @override
  String get declineButton => 'Decline';

  @override
  String get errorLoadingConsents => 'Error loading consents';
}
