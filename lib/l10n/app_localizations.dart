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

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Setup'**
  String get profileSetupTitle;

  /// No description provided for @profileStepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String profileStepIndicator(Object current, Object total);

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDateLabel;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @bodyFatCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I know my body fat percentage'**
  String get bodyFatCheckbox;

  /// No description provided for @bodyFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get bodyFatLabel;

  /// No description provided for @bmrMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'BMR Calculation Method'**
  String get bmrMethodTitle;

  /// No description provided for @bmrMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the formula for your basal metabolic rate.'**
  String get bmrMethodSubtitle;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @palTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Activity (PAL)'**
  String get palTitle;

  /// No description provided for @palSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer the questions to estimate your physical activity level, or adjust it manually.'**
  String get palSubtitle;

  /// No description provided for @manualPalSwitch.
  ///
  /// In en, this message translates to:
  /// **'I know my PAL - enter manually'**
  String get manualPalSwitch;

  /// No description provided for @quizPalSwitch.
  ///
  /// In en, this message translates to:
  /// **'Back to questionnaire'**
  String get quizPalSwitch;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Silhouette Goal'**
  String get goalTitle;

  /// No description provided for @goalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculations based on Dr. Kevin Hall\'s modern metabolic model.'**
  String get goalSubtitle;

  /// No description provided for @goalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalLose;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get goalMaintain;

  /// No description provided for @goalGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get goalGain;

  /// No description provided for @goalLoseGainQuestion.
  ///
  /// In en, this message translates to:
  /// **'How many kilograms do you want to {action} in a year?'**
  String goalLoseGainQuestion(Object action);

  /// No description provided for @goalActionLose.
  ///
  /// In en, this message translates to:
  /// **'lose'**
  String get goalActionLose;

  /// No description provided for @goalActionGain.
  ///
  /// In en, this message translates to:
  /// **'gain'**
  String get goalActionGain;

  /// No description provided for @goalMaintainDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintaining weight means zero caloric deficit/surplus.'**
  String get goalMaintainDesc;

  /// No description provided for @weeklyDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Flexible Weekly Schedule'**
  String get weeklyDistributionTitle;

  /// No description provided for @weeklyDistributionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust calories for specific days. The weekly sum must equal 0 kcal.'**
  String get weeklyDistributionSubtitle;

  /// No description provided for @weeklyDistributionSwitch.
  ///
  /// In en, this message translates to:
  /// **'Customize specific days'**
  String get weeklyDistributionSwitch;

  /// No description provided for @weeklySumValid.
  ///
  /// In en, this message translates to:
  /// **'Weekly sum is 0 kcal (perfect!)'**
  String get weeklySumValid;

  /// No description provided for @weeklySumInvalid.
  ///
  /// In en, this message translates to:
  /// **'Sum is {sum} kcal. Must equal exactly 0.'**
  String weeklySumInvalid(Object sum);

  /// No description provided for @macroTitle.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient Strategy'**
  String get macroTitle;

  /// No description provided for @macroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset or adjust ratios manually (sum must equal 100%).'**
  String get macroSubtitle;

  /// No description provided for @macroBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get macroBalanced;

  /// No description provided for @macroHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get macroHighProtein;

  /// No description provided for @macroLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get macroLowCarb;

  /// No description provided for @macroKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get macroKeto;

  /// No description provided for @macroCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get macroCustom;

  /// No description provided for @macroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get macroFat;

  /// No description provided for @macroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get macroCarbs;

  /// No description provided for @macroWarningText.
  ///
  /// In en, this message translates to:
  /// **'Warning: Some values exceed standard nutritional recommendations (Carbs 45-65%, Protein 10-20%, Fat 20-35%). Make sure you know what you are doing.'**
  String get macroWarningText;

  /// No description provided for @macroSumValid.
  ///
  /// In en, this message translates to:
  /// **'Total macros equal 100%'**
  String get macroSumValid;

  /// No description provided for @macroSumInvalid.
  ///
  /// In en, this message translates to:
  /// **'Total is {total}% (Must equal 100%)'**
  String macroSumInvalid(Object total);

  /// No description provided for @insulinSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insulin Parameters'**
  String get insulinSettingsTitle;

  /// No description provided for @insulinSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key parameters for calculating insulin doses and corrections.'**
  String get insulinSettingsSubtitle;

  /// No description provided for @insulinDeliveryMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Insulin Delivery Method'**
  String get insulinDeliveryMethodLabel;

  /// No description provided for @insulinPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get insulinPen;

  /// No description provided for @insulinPump.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get insulinPump;

  /// No description provided for @icrTitle.
  ///
  /// In en, this message translates to:
  /// **'Insulin to Carb Ratio (ICR)'**
  String get icrTitle;

  /// No description provided for @icrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure ICR for hours of the day (0-23). Hour 0 is mandatory.'**
  String get icrSubtitle;

  /// No description provided for @addHourButton.
  ///
  /// In en, this message translates to:
  /// **'Add another hour'**
  String get addHourButton;

  /// No description provided for @icrValid.
  ///
  /// In en, this message translates to:
  /// **'Hourly configuration is fully valid.'**
  String get icrValid;

  /// No description provided for @fpuMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'FPU Calculation Method'**
  String get fpuMethodTitle;

  /// No description provided for @fpuMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how insulin for protein and fat is calculated.'**
  String get fpuMethodSubtitle;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @summarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your data. You can go back and edit any step.'**
  String get summarySubtitle;

  /// No description provided for @summaryGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get summaryGender;

  /// No description provided for @summaryBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get summaryBirthDate;

  /// No description provided for @summaryHeightWeight.
  ///
  /// In en, this message translates to:
  /// **'Height & Weight'**
  String get summaryHeightWeight;

  /// No description provided for @summaryBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get summaryBodyFat;

  /// No description provided for @summaryBmrMethod.
  ///
  /// In en, this message translates to:
  /// **'BMR Method'**
  String get summaryBmrMethod;

  /// No description provided for @summaryPal.
  ///
  /// In en, this message translates to:
  /// **'PAL Value'**
  String get summaryPal;

  /// No description provided for @summaryGoal.
  ///
  /// In en, this message translates to:
  /// **'Caloric Goal'**
  String get summaryGoal;

  /// No description provided for @summaryWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get summaryWeekly;

  /// No description provided for @summaryMacros.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get summaryMacros;

  /// No description provided for @summaryInsulinParams.
  ///
  /// In en, this message translates to:
  /// **'ISF / IFP'**
  String get summaryInsulinParams;

  /// No description provided for @summaryInsulinDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get summaryInsulinDelivery;

  /// No description provided for @summaryIcrHours.
  ///
  /// In en, this message translates to:
  /// **'ICR Hours'**
  String get summaryIcrHours;

  /// No description provided for @summaryFpuMethod.
  ///
  /// In en, this message translates to:
  /// **'FPU Method'**
  String get summaryFpuMethod;

  /// No description provided for @errorHeightRange.
  ///
  /// In en, this message translates to:
  /// **'Height must be between 50 and 300 cm'**
  String get errorHeightRange;

  /// No description provided for @errorWeightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 20 and 500 kg'**
  String get errorWeightRange;

  /// No description provided for @errorBodyFatRange.
  ///
  /// In en, this message translates to:
  /// **'Body fat must be between 1 and 80%'**
  String get errorBodyFatRange;

  /// No description provided for @errorIcrEmpty.
  ///
  /// In en, this message translates to:
  /// **'You must add at least hour 0.'**
  String get errorIcrEmpty;

  /// No description provided for @errorIcrRange.
  ///
  /// In en, this message translates to:
  /// **'Hour must be between 0 and 23.'**
  String get errorIcrRange;

  /// No description provided for @errorIcrValue.
  ///
  /// In en, this message translates to:
  /// **'ICR value must be greater than 0.'**
  String get errorIcrValue;

  /// No description provided for @errorIcrDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Hour {hour}:00 is duplicated. Each hour can only appear once.'**
  String errorIcrDuplicate(Object hour);

  /// No description provided for @errorIcrBaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Hour 0 (0:00) is required as a base.'**
  String get errorIcrBaseRequired;

  /// No description provided for @icrConfigValid.
  ///
  /// In en, this message translates to:
  /// **'Hourly configuration is fully valid.'**
  String get icrConfigValid;

  /// No description provided for @deliveryMethodInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Insulin Delivery Method'**
  String get deliveryMethodInfoTitle;

  /// No description provided for @deliveryMethodInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose whether you use multiple daily injections (MDI with insulin pens) or a continuous subcutaneous insulin infusion pump (CSII).'**
  String get deliveryMethodInfoDesc;

  /// No description provided for @katchMcArdleDisabledReason.
  ///
  /// In en, this message translates to:
  /// **'Requires body fat percentage to be provided.'**
  String get katchMcArdleDisabledReason;

  /// No description provided for @pankowskaDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on Protein-Fat Units (1 PFU = 100 kcal from protein/fat). Reduces the dose by 25–40% and uses an extended bolus over 2–4 hours to prevent late hypoglycemia.'**
  String get pankowskaDesc;

  /// No description provided for @sieradzkiDesc.
  ///
  /// In en, this message translates to:
  /// **'Increases the standard carbohydrate insulin dose by 30–70% for high-protein and high-fat meals, extending delivery over 4–6 hours.'**
  String get sieradzkiDesc;

  /// No description provided for @bmrHarrisTitle.
  ///
  /// In en, this message translates to:
  /// **'Harris-Benedict'**
  String get bmrHarrisTitle;

  /// No description provided for @bmrHarrisDesc.
  ///
  /// In en, this message translates to:
  /// **'The accuracy of the Harris-Benedict equation is strongly dependent on body composition and ethnicity. Its validity for the US population is lower and less stable than for residents of Europe and the Middle East, for whom this model is more accurate than the newer Mifflin-St Jeor formula.'**
  String get bmrHarrisDesc;

  /// No description provided for @bmrMifflinTitle.
  ///
  /// In en, this message translates to:
  /// **'Mifflin-St Jeor'**
  String get bmrMifflinTitle;

  /// No description provided for @bmrMifflinDesc.
  ///
  /// In en, this message translates to:
  /// **'This equation shares similar limitations and issues with the Harris-Benedict method. It is most accurate for the US population and less sensitive to body weight variations. For individuals of other origins, it is significantly less precise and tends to underestimate caloric requirements.'**
  String get bmrMifflinDesc;

  /// No description provided for @bmrKatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Katch-McArdle'**
  String get bmrKatchTitle;

  /// No description provided for @bmrKatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlike the previously described equations, the Katch-McArdle formula does not account for gender, height, or age. It is the best calculation method for athletes, muscular individuals, and physically active people.'**
  String get bmrKatchDesc;

  /// No description provided for @bmrOwenTitle.
  ///
  /// In en, this message translates to:
  /// **'Owen'**
  String get bmrOwenTitle;

  /// No description provided for @bmrOwenDesc.
  ///
  /// In en, this message translates to:
  /// **'The Owen equation shows the highest accuracy for obese Europeans, while being much less accurate for individuals with normal body weight. For US residents, the Mifflin-St Jeor formula remains the most precise.'**
  String get bmrOwenDesc;

  /// No description provided for @palQ1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Occupational activity and daily routine profile'**
  String get palQ1Title;

  /// No description provided for @palQ1Opt0Title.
  ///
  /// In en, this message translates to:
  /// **'Sedentary restriction'**
  String get palQ1Opt0Title;

  /// No description provided for @palQ1Opt0Desc.
  ///
  /// In en, this message translates to:
  /// **'Bedridden or extremely limited physical mobility.'**
  String get palQ1Opt0Desc;

  /// No description provided for @palQ1Opt1Title.
  ///
  /// In en, this message translates to:
  /// **'Office and desk work'**
  String get palQ1Opt1Title;

  /// No description provided for @palQ1Opt1Desc.
  ///
  /// In en, this message translates to:
  /// **'Primarily seated work, studying, or driving.'**
  String get palQ1Opt1Desc;

  /// No description provided for @palQ1Opt2Title.
  ///
  /// In en, this message translates to:
  /// **'Light standing work'**
  String get palQ1Opt2Title;

  /// No description provided for @palQ1Opt2Desc.
  ///
  /// In en, this message translates to:
  /// **'Standing occupation, retail assistance, teaching.'**
  String get palQ1Opt2Desc;

  /// No description provided for @palQ1Opt3Title.
  ///
  /// In en, this message translates to:
  /// **'Moderate physical work'**
  String get palQ1Opt3Title;

  /// No description provided for @palQ1Opt3Desc.
  ///
  /// In en, this message translates to:
  /// **'Hospitality, warehousing, light manual labor.'**
  String get palQ1Opt3Desc;

  /// No description provided for @palQ1Opt4Title.
  ///
  /// In en, this message translates to:
  /// **'Heavy physical labor'**
  String get palQ1Opt4Title;

  /// No description provided for @palQ1Opt4Desc.
  ///
  /// In en, this message translates to:
  /// **'Construction, heavy agriculture, intensive manual labor.'**
  String get palQ1Opt4Desc;

  /// No description provided for @palQ2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Non-exercise daily movement and home activity'**
  String get palQ2Title;

  /// No description provided for @palQ2Opt0Title.
  ///
  /// In en, this message translates to:
  /// **'Minimal movement'**
  String get palQ2Opt0Title;

  /// No description provided for @palQ2Opt0Desc.
  ///
  /// In en, this message translates to:
  /// **'Passive resting, no household duties.'**
  String get palQ2Opt0Desc;

  /// No description provided for @palQ2Opt1Title.
  ///
  /// In en, this message translates to:
  /// **'Light movement'**
  String get palQ2Opt1Title;

  /// No description provided for @palQ2Opt1Desc.
  ///
  /// In en, this message translates to:
  /// **'Basic cleaning, cooking, short movement.'**
  String get palQ2Opt1Desc;

  /// No description provided for @palQ2Opt2Title.
  ///
  /// In en, this message translates to:
  /// **'Moderate movement'**
  String get palQ2Opt2Title;

  /// No description provided for @palQ2Opt2Desc.
  ///
  /// In en, this message translates to:
  /// **'Daily dog walking, family care, regular errands.'**
  String get palQ2Opt2Desc;

  /// No description provided for @palQ2Opt3Title.
  ///
  /// In en, this message translates to:
  /// **'High movement'**
  String get palQ2Opt3Title;

  /// No description provided for @palQ2Opt3Desc.
  ///
  /// In en, this message translates to:
  /// **'Intensive home maintenance, long daily walks.'**
  String get palQ2Opt3Desc;

  /// No description provided for @palQ3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Frequency of planned physical workouts'**
  String get palQ3Title;

  /// No description provided for @palQ3Opt0Title.
  ///
  /// In en, this message translates to:
  /// **'No structured workouts'**
  String get palQ3Opt0Title;

  /// No description provided for @palQ3Opt0Desc.
  ///
  /// In en, this message translates to:
  /// **'No planned physical training routines.'**
  String get palQ3Opt0Desc;

  /// No description provided for @palQ3Opt1Title.
  ///
  /// In en, this message translates to:
  /// **'Occasional training'**
  String get palQ3Opt1Title;

  /// No description provided for @palQ3Opt1Desc.
  ///
  /// In en, this message translates to:
  /// **'1 to 2 light workouts per week.'**
  String get palQ3Opt1Desc;

  /// No description provided for @palQ3Opt2Title.
  ///
  /// In en, this message translates to:
  /// **'Regular training'**
  String get palQ3Opt2Title;

  /// No description provided for @palQ3Opt2Desc.
  ///
  /// In en, this message translates to:
  /// **'3 to 4 structured sessions per week.'**
  String get palQ3Opt2Desc;

  /// No description provided for @palQ3Opt3Title.
  ///
  /// In en, this message translates to:
  /// **'Frequent training'**
  String get palQ3Opt3Title;

  /// No description provided for @palQ3Opt3Desc.
  ///
  /// In en, this message translates to:
  /// **'5 or more training sessions per week.'**
  String get palQ3Opt3Desc;

  /// No description provided for @palQ4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Average intensity of structured training'**
  String get palQ4Title;

  /// No description provided for @palQ4Opt0Title.
  ///
  /// In en, this message translates to:
  /// **'Low intensity'**
  String get palQ4Opt0Title;

  /// No description provided for @palQ4Opt0Desc.
  ///
  /// In en, this message translates to:
  /// **'Mobility, stretching, gentle yoga, leisurely walks.'**
  String get palQ4Opt0Desc;

  /// No description provided for @palQ4Opt1Title.
  ///
  /// In en, this message translates to:
  /// **'Moderate intensity'**
  String get palQ4Opt1Title;

  /// No description provided for @palQ4Opt1Desc.
  ///
  /// In en, this message translates to:
  /// **'Standard aerobic training, moderate gym workouts.'**
  String get palQ4Opt1Desc;

  /// No description provided for @palQ4Opt2Title.
  ///
  /// In en, this message translates to:
  /// **'High intensity'**
  String get palQ4Opt2Title;

  /// No description provided for @palQ4Opt2Desc.
  ///
  /// In en, this message translates to:
  /// **'Crossfit, heavy weightlifting, intense interval training.'**
  String get palQ4Opt2Desc;

  /// No description provided for @caloricTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Caloric target:'**
  String get caloricTargetLabel;

  /// No description provided for @caloricTargetMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain (0 kcal)'**
  String get caloricTargetMaintain;

  /// No description provided for @caloricTargetValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal / day'**
  String caloricTargetValue(String value);

  /// No description provided for @weeklyStandardDistribution.
  ///
  /// In en, this message translates to:
  /// **'Standard distribution across all days.'**
  String get weeklyStandardDistribution;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @macroProteinNorm.
  ///
  /// In en, this message translates to:
  /// **'Standard: 10–35%'**
  String get macroProteinNorm;

  /// No description provided for @macroFatNorm.
  ///
  /// In en, this message translates to:
  /// **'Standard: 20–35%'**
  String get macroFatNorm;

  /// No description provided for @macroCarbsNorm.
  ///
  /// In en, this message translates to:
  /// **'Standard: 45–65%'**
  String get macroCarbsNorm;

  /// No description provided for @macroOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Out of range ({range})'**
  String macroOutOfRange(String range);

  /// No description provided for @isfLabel.
  ///
  /// In en, this message translates to:
  /// **'Insulin Sensitivity Factor (ISF)'**
  String get isfLabel;

  /// No description provided for @isfSuffix.
  ///
  /// In en, this message translates to:
  /// **'mg/dL / U'**
  String get isfSuffix;

  /// No description provided for @isfInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'ISF (Insulin Sensitivity Factor)'**
  String get isfInfoTitle;

  /// No description provided for @isfInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Specifies how many mg/dL your blood glucose drops after taking 1 unit of rapid-acting insulin.'**
  String get isfInfoDesc;

  /// No description provided for @ifpLabel.
  ///
  /// In en, this message translates to:
  /// **'Insulin Fat-Protein Ratio (IFP)'**
  String get ifpLabel;

  /// No description provided for @ifpSuffix.
  ///
  /// In en, this message translates to:
  /// **'U / FPU'**
  String get ifpSuffix;

  /// No description provided for @ifpInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'IFP / FPU Ratio'**
  String get ifpInfoTitle;

  /// No description provided for @ifpInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Specifies how many units of insulin are needed for 1 FPU (Fat-Protein Unit), which corresponds to every 100 kcal coming from dietary fats and proteins.'**
  String get ifpInfoDesc;

  /// No description provided for @icrInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'ICR (Insulin to Carb Ratio)'**
  String get icrInfoTitle;

  /// No description provided for @icrInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Defines how many grams of carbohydrates are covered by 1 unit of insulin for a given hour. Hour 0 (0:00) is mandatory as base.'**
  String get icrInfoDesc;

  /// No description provided for @hourLabel.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hourLabel;

  /// No description provided for @icrValueLabel.
  ///
  /// In en, this message translates to:
  /// **'ICR (g/U)'**
  String get icrValueLabel;

  /// No description provided for @pankowskaTitle.
  ///
  /// In en, this message translates to:
  /// **'Pańkowska Method (Warsaw Method)'**
  String get pankowskaTitle;

  /// No description provided for @sieradzkiTitle.
  ///
  /// In en, this message translates to:
  /// **'Sieradzki Method (Percentage Method)'**
  String get sieradzkiTitle;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @summaryGoalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight ({diff} kcal deficit)'**
  String summaryGoalLose(int diff);

  /// No description provided for @summaryGoalGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight (+{diff} kcal surplus)'**
  String summaryGoalGain(int diff);

  /// No description provided for @summaryGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight (0 kcal)'**
  String get summaryGoalMaintain;

  /// No description provided for @summaryWeeklyCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get summaryWeeklyCustom;

  /// No description provided for @summaryWeeklyUniform.
  ///
  /// In en, this message translates to:
  /// **'Uniform'**
  String get summaryWeeklyUniform;

  /// No description provided for @summaryIntervals.
  ///
  /// In en, this message translates to:
  /// **'{count} intervals'**
  String summaryIntervals(int count);

  /// No description provided for @readyToProceed.
  ///
  /// In en, this message translates to:
  /// **'Ready to proceed.'**
  String get readyToProceed;

  /// No description provided for @palMultiplierLabel.
  ///
  /// In en, this message translates to:
  /// **'PAL Multiplier'**
  String get palMultiplierLabel;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @backToFormButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backToFormButton;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @drawerExport.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get drawerExport;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAbout;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get drawerLogout;

  /// No description provided for @macroKcal.
  ///
  /// In en, this message translates to:
  /// **'Kcal'**
  String get macroKcal;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'GluQalc v{version}'**
  String appVersionLabel(String version);

  /// No description provided for @kcalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal left'**
  String kcalRemaining(int kcal);

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile.'**
  String get errorLoadingProfile;

  /// No description provided for @tooltipOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get tooltipOnline;

  /// No description provided for @tooltipOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get tooltipOffline;

  /// No description provided for @madeByLabel.
  ///
  /// In en, this message translates to:
  /// **'Made by Szymon Rózga'**
  String get madeByLabel;

  /// No description provided for @tooltipApiRepo.
  ///
  /// In en, this message translates to:
  /// **'API'**
  String get tooltipApiRepo;

  /// No description provided for @tooltipFrontendRepo.
  ///
  /// In en, this message translates to:
  /// **'Frontend'**
  String get tooltipFrontendRepo;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @profileAccountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get profileAccountSettingsTitle;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEditButton;

  /// No description provided for @profileChangeEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get profileChangeEmailButton;

  /// No description provided for @profileChangePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePasswordButton;

  /// No description provided for @profileDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountButton;

  /// No description provided for @profileActiveSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get profileActiveSessionsTitle;

  /// No description provided for @profileSessionCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current device'**
  String get profileSessionCurrent;

  /// No description provided for @profileSessionRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get profileSessionRevoke;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @profileChangeEmailDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and the new email address.'**
  String get profileChangeEmailDialogSubtitle;

  /// No description provided for @profileChangeEmailCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your new email.'**
  String get profileChangeEmailCodeSubtitle;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid current password.'**
  String get errorInvalidPassword;

  /// No description provided for @emailChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email address successfully changed!'**
  String get emailChangedSuccessfully;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @profileChangePasswordDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter and confirm your new password.'**
  String get profileChangePasswordDialogSubtitle;

  /// No description provided for @profileChangePasswordCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your email.'**
  String get profileChangePasswordCodeSubtitle;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed! Please log in again.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @profileDeleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountDialogTitle;

  /// No description provided for @profileDeleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone.'**
  String get profileDeleteAccountWarning;

  /// No description provided for @profileDeleteAccountCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your email to permanently delete your account.'**
  String get profileDeleteAccountCodeSubtitle;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted.'**
  String get accountDeletedSuccessfully;

  /// No description provided for @requestDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Request deletion'**
  String get requestDeleteButton;

  /// No description provided for @confirmDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get confirmDeleteButton;

  /// No description provided for @deviceWeb.
  ///
  /// In en, this message translates to:
  /// **'Web Browser'**
  String get deviceWeb;

  /// No description provided for @deviceAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android Device'**
  String get deviceAndroid;

  /// No description provided for @deviceIos.
  ///
  /// In en, this message translates to:
  /// **'iOS Device'**
  String get deviceIos;

  /// No description provided for @deviceWindows.
  ///
  /// In en, this message translates to:
  /// **'Windows PC'**
  String get deviceWindows;

  /// No description provided for @deviceLinux.
  ///
  /// In en, this message translates to:
  /// **'Linux Native App'**
  String get deviceLinux;

  /// No description provided for @deviceMac.
  ///
  /// In en, this message translates to:
  /// **'Mac / MacBook'**
  String get deviceMac;

  /// No description provided for @deviceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get deviceUnknown;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get lastActive;

  /// No description provided for @errorSessionRevoke.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke session'**
  String get errorSessionRevoke;

  /// No description provided for @warningHighDeficitYellow.
  ///
  /// In en, this message translates to:
  /// **'This is a fast reduction pace. Ensure you get enough nutrients.'**
  String get warningHighDeficitYellow;

  /// No description provided for @warningExtremeDeficitRed.
  ///
  /// In en, this message translates to:
  /// **'Extreme caloric deficit! This can lead to muscle loss and health issues. Consider a more moderate pace.'**
  String get warningExtremeDeficitRed;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a password reset code.'**
  String get forgotPasswordDialogSubtitle;

  /// No description provided for @forgotPasswordCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your email and set a new password.'**
  String get forgotPasswordCodeSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'GluQalc is an application supporting the monitoring of diet, macronutrients, as well as glycemic and insulin parameters.'**
  String get aboutDescription;

  /// No description provided for @aboutAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutAuthor;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContact;

  /// No description provided for @aboutFrontendRepo.
  ///
  /// In en, this message translates to:
  /// **'Frontend Repository'**
  String get aboutFrontendRepo;

  /// No description provided for @aboutBackendRepo.
  ///
  /// In en, this message translates to:
  /// **'API Repository'**
  String get aboutBackendRepo;

  /// No description provided for @aboutTos.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service (ToS)'**
  String get aboutTos;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get aboutDisclaimer;

  /// No description provided for @errorOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL'**
  String get errorOpenUrl;
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
