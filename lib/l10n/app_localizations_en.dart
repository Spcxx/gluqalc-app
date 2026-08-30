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

  @override
  String get profileSetupTitle => 'Profile Setup';

  @override
  String profileStepIndicator(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get nextButton => 'Next';

  @override
  String get backButton => 'Back';

  @override
  String get finishButton => 'Finish';

  @override
  String get submitButton => 'Submit';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderOther => 'Other';

  @override
  String get birthDateLabel => 'Date of Birth';

  @override
  String get selectDate => 'Select date';

  @override
  String get heightLabel => 'Height';

  @override
  String get weightLabel => 'Weight';

  @override
  String get bodyFatCheckbox => 'I know my body fat percentage';

  @override
  String get bodyFatLabel => 'Body Fat';

  @override
  String get bmrMethodTitle => 'BMR Calculation Method';

  @override
  String get bmrMethodSubtitle =>
      'Choose the formula for your basal metabolic rate.';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get palTitle => 'Lifestyle & Activity (PAL)';

  @override
  String get palSubtitle =>
      'Answer the questions to estimate your physical activity level, or adjust it manually.';

  @override
  String get manualPalSwitch => 'I know my PAL - enter manually';

  @override
  String get quizPalSwitch => 'Back to questionnaire';

  @override
  String get goalTitle => 'Silhouette Goal';

  @override
  String get goalSubtitle =>
      'Calculations based on Dr. Kevin Hall\'s modern metabolic model.';

  @override
  String get goalLose => 'Lose weight';

  @override
  String get goalMaintain => 'Maintain weight';

  @override
  String get goalGain => 'Gain weight';

  @override
  String goalLoseGainQuestion(Object action) {
    return 'How many kilograms do you want to $action in a year?';
  }

  @override
  String get goalActionLose => 'lose';

  @override
  String get goalActionGain => 'gain';

  @override
  String get goalMaintainDesc =>
      'Maintaining weight means zero caloric deficit/surplus.';

  @override
  String get weeklyDistributionTitle => 'Flexible Weekly Schedule';

  @override
  String get weeklyDistributionSubtitle =>
      'Adjust calories for specific days. The weekly sum must equal 0 kcal.';

  @override
  String get weeklyDistributionSwitch => 'Customize specific days';

  @override
  String get weeklySumValid => 'Weekly sum is 0 kcal (perfect!)';

  @override
  String weeklySumInvalid(Object sum) {
    return 'Sum is $sum kcal. Must equal exactly 0.';
  }

  @override
  String get macroTitle => 'Macronutrient Strategy';

  @override
  String get macroSubtitle =>
      'Choose a preset or adjust ratios manually (sum must equal 100%).';

  @override
  String get macroBalanced => 'Balanced';

  @override
  String get macroHighProtein => 'High Protein';

  @override
  String get macroLowCarb => 'Low Carb';

  @override
  String get macroKeto => 'Keto';

  @override
  String get macroCustom => 'Custom';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroFat => 'Fat';

  @override
  String get macroCarbs => 'Carbohydrates';

  @override
  String get macroWarningText =>
      'Warning: Some values exceed standard nutritional recommendations (Carbs 45-65%, Protein 10-20%, Fat 20-35%). Make sure you know what you are doing.';

  @override
  String get macroSumValid => 'Total macros equal 100%';

  @override
  String macroSumInvalid(Object total) {
    return 'Total is $total% (Must equal 100%)';
  }

  @override
  String get insulinSettingsTitle => 'Insulin Parameters';

  @override
  String get insulinSettingsSubtitle =>
      'Key parameters for calculating insulin doses and corrections.';

  @override
  String get insulinDeliveryMethodLabel => 'Insulin Delivery Method';

  @override
  String get insulinPen => 'Pen';

  @override
  String get insulinPump => 'Pump';

  @override
  String get icrTitle => 'Insulin to Carb Ratio (ICR)';

  @override
  String get icrSubtitle =>
      'Configure ICR for hours of the day (0-23). Hour 0 is mandatory.';

  @override
  String get addHourButton => 'Add another hour';

  @override
  String get icrValid => 'Hourly configuration is fully valid.';

  @override
  String get fpuMethodTitle => 'FPU Calculation Method';

  @override
  String get fpuMethodSubtitle =>
      'Choose how insulin for protein and fat is calculated.';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summarySubtitle =>
      'Review your data. You can go back and edit any step.';

  @override
  String get summaryGender => 'Gender';

  @override
  String get summaryBirthDate => 'Date of birth';

  @override
  String get summaryHeightWeight => 'Height & Weight';

  @override
  String get summaryBodyFat => 'Body Fat';

  @override
  String get summaryBmrMethod => 'BMR Method';

  @override
  String get summaryPal => 'PAL Value';

  @override
  String get summaryGoal => 'Caloric Goal';

  @override
  String get summaryWeekly => 'Weekly Schedule';

  @override
  String get summaryMacros => 'Macronutrients';

  @override
  String get summaryInsulinParams => 'ISF / IFP';

  @override
  String get summaryInsulinDelivery => 'Delivery Method';

  @override
  String get summaryIcrHours => 'ICR Hours';

  @override
  String get summaryFpuMethod => 'FPU Method';

  @override
  String get errorHeightRange => 'Height must be between 50 and 300 cm';

  @override
  String get errorWeightRange => 'Weight must be between 20 and 500 kg';

  @override
  String get errorBodyFatRange => 'Body fat must be between 1 and 80%';

  @override
  String get errorIcrEmpty => 'You must add at least hour 0.';

  @override
  String get errorIcrRange => 'Hour must be between 0 and 23.';

  @override
  String get errorIcrValue => 'ICR value must be greater than 0.';

  @override
  String errorIcrDuplicate(Object hour) {
    return 'Hour $hour:00 is duplicated. Each hour can only appear once.';
  }

  @override
  String get errorIcrBaseRequired => 'Hour 0 (0:00) is required as a base.';

  @override
  String get icrConfigValid => 'Hourly configuration is fully valid.';

  @override
  String get deliveryMethodInfoTitle => 'Insulin Delivery Method';

  @override
  String get deliveryMethodInfoDesc =>
      'Choose whether you use multiple daily injections (MDI with insulin pens) or a continuous subcutaneous insulin infusion pump (CSII).';

  @override
  String get katchMcArdleDisabledReason =>
      'Requires body fat percentage to be provided.';

  @override
  String get pankowskaDesc =>
      'Based on Protein-Fat Units (1 PFU = 100 kcal from protein/fat). Reduces the dose by 25–40% and uses an extended bolus over 2–4 hours to prevent late hypoglycemia.';

  @override
  String get sieradzkiDesc =>
      'Increases the standard carbohydrate insulin dose by 30–70% for high-protein and high-fat meals, extending delivery over 4–6 hours.';

  @override
  String get bmrHarrisTitle => 'Harris-Benedict';

  @override
  String get bmrHarrisDesc =>
      'The accuracy of the Harris-Benedict equation is strongly dependent on body composition and ethnicity. Its validity for the US population is lower and less stable than for residents of Europe and the Middle East, for whom this model is more accurate than the newer Mifflin-St Jeor formula.';

  @override
  String get bmrMifflinTitle => 'Mifflin-St Jeor';

  @override
  String get bmrMifflinDesc =>
      'This equation shares similar limitations and issues with the Harris-Benedict method. It is most accurate for the US population and less sensitive to body weight variations. For individuals of other origins, it is significantly less precise and tends to underestimate caloric requirements.';

  @override
  String get bmrKatchTitle => 'Katch-McArdle';

  @override
  String get bmrKatchDesc =>
      'Unlike the previously described equations, the Katch-McArdle formula does not account for gender, height, or age. It is the best calculation method for athletes, muscular individuals, and physically active people.';

  @override
  String get bmrOwenTitle => 'Owen';

  @override
  String get bmrOwenDesc =>
      'The Owen equation shows the highest accuracy for obese Europeans, while being much less accurate for individuals with normal body weight. For US residents, the Mifflin-St Jeor formula remains the most precise.';

  @override
  String get palQ1Title => '1. Occupational activity and daily routine profile';

  @override
  String get palQ1Opt0Title => 'Sedentary restriction';

  @override
  String get palQ1Opt0Desc =>
      'Bedridden or extremely limited physical mobility.';

  @override
  String get palQ1Opt1Title => 'Office and desk work';

  @override
  String get palQ1Opt1Desc => 'Primarily seated work, studying, or driving.';

  @override
  String get palQ1Opt2Title => 'Light standing work';

  @override
  String get palQ1Opt2Desc =>
      'Standing occupation, retail assistance, teaching.';

  @override
  String get palQ1Opt3Title => 'Moderate physical work';

  @override
  String get palQ1Opt3Desc => 'Hospitality, warehousing, light manual labor.';

  @override
  String get palQ1Opt4Title => 'Heavy physical labor';

  @override
  String get palQ1Opt4Desc =>
      'Construction, heavy agriculture, intensive manual labor.';

  @override
  String get palQ2Title => '2. Non-exercise daily movement and home activity';

  @override
  String get palQ2Opt0Title => 'Minimal movement';

  @override
  String get palQ2Opt0Desc => 'Passive resting, no household duties.';

  @override
  String get palQ2Opt1Title => 'Light movement';

  @override
  String get palQ2Opt1Desc => 'Basic cleaning, cooking, short movement.';

  @override
  String get palQ2Opt2Title => 'Moderate movement';

  @override
  String get palQ2Opt2Desc =>
      'Daily dog walking, family care, regular errands.';

  @override
  String get palQ2Opt3Title => 'High movement';

  @override
  String get palQ2Opt3Desc => 'Intensive home maintenance, long daily walks.';

  @override
  String get palQ3Title => '3. Frequency of planned physical workouts';

  @override
  String get palQ3Opt0Title => 'No structured workouts';

  @override
  String get palQ3Opt0Desc => 'No planned physical training routines.';

  @override
  String get palQ3Opt1Title => 'Occasional training';

  @override
  String get palQ3Opt1Desc => '1 to 2 light workouts per week.';

  @override
  String get palQ3Opt2Title => 'Regular training';

  @override
  String get palQ3Opt2Desc => '3 to 4 structured sessions per week.';

  @override
  String get palQ3Opt3Title => 'Frequent training';

  @override
  String get palQ3Opt3Desc => '5 or more training sessions per week.';

  @override
  String get palQ4Title => '4. Average intensity of structured training';

  @override
  String get palQ4Opt0Title => 'Low intensity';

  @override
  String get palQ4Opt0Desc =>
      'Mobility, stretching, gentle yoga, leisurely walks.';

  @override
  String get palQ4Opt1Title => 'Moderate intensity';

  @override
  String get palQ4Opt1Desc =>
      'Standard aerobic training, moderate gym workouts.';

  @override
  String get palQ4Opt2Title => 'High intensity';

  @override
  String get palQ4Opt2Desc =>
      'Crossfit, heavy weightlifting, intense interval training.';

  @override
  String get caloricTargetLabel => 'Caloric target:';

  @override
  String get caloricTargetMaintain => 'Maintain (0 kcal)';

  @override
  String caloricTargetValue(String value) {
    return '$value kcal / day';
  }

  @override
  String get weeklyStandardDistribution =>
      'Standard distribution across all days.';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get macroProteinNorm => 'Standard: 10–35%';

  @override
  String get macroFatNorm => 'Standard: 20–35%';

  @override
  String get macroCarbsNorm => 'Standard: 45–65%';

  @override
  String macroOutOfRange(String range) {
    return 'Out of range ($range)';
  }

  @override
  String get isfLabel => 'Insulin Sensitivity Factor (ISF)';

  @override
  String get isfSuffix => 'mg/dL / U';

  @override
  String get isfInfoTitle => 'ISF (Insulin Sensitivity Factor)';

  @override
  String get isfInfoDesc =>
      'Specifies how many mg/dL your blood glucose drops after taking 1 unit of rapid-acting insulin.';

  @override
  String get ifpLabel => 'Insulin Fat-Protein Ratio (IFP)';

  @override
  String get ifpSuffix => 'U / FPU';

  @override
  String get ifpInfoTitle => 'IFP / FPU Ratio';

  @override
  String get ifpInfoDesc =>
      'Specifies how many units of insulin are needed for 1 FPU (Fat-Protein Unit), which corresponds to every 100 kcal coming from dietary fats and proteins.';

  @override
  String get icrInfoTitle => 'ICR (Insulin to Carb Ratio)';

  @override
  String get icrInfoDesc =>
      'Defines how many grams of carbohydrates are covered by 1 unit of insulin for a given hour. Hour 0 (0:00) is mandatory as base.';

  @override
  String get hourLabel => 'Hour';

  @override
  String get icrValueLabel => 'ICR (g/U)';

  @override
  String get pankowskaTitle => 'Pańkowska Method (Warsaw Method)';

  @override
  String get sieradzkiTitle => 'Sieradzki Method (Percentage Method)';

  @override
  String get notSet => 'Not set';

  @override
  String get notProvided => 'Not provided';

  @override
  String summaryGoalLose(int diff) {
    return 'Lose weight ($diff kcal deficit)';
  }

  @override
  String summaryGoalGain(int diff) {
    return 'Gain weight (+$diff kcal surplus)';
  }

  @override
  String get summaryGoalMaintain => 'Maintain weight (0 kcal)';

  @override
  String get summaryWeeklyCustom => 'Custom';

  @override
  String get summaryWeeklyUniform => 'Uniform';

  @override
  String summaryIntervals(int count) {
    return '$count intervals';
  }

  @override
  String get readyToProceed => 'Ready to proceed.';

  @override
  String get palMultiplierLabel => 'PAL Multiplier';

  @override
  String get errorTitle => 'Error';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get okButton => 'OK';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get backToFormButton => 'Back';

  @override
  String get drawerProfile => 'Profile';

  @override
  String get drawerExport => 'Export data';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerAbout => 'About';

  @override
  String get drawerLogout => 'Log out';

  @override
  String get macroKcal => 'Kcal';

  @override
  String appVersionLabel(String version) {
    return 'GluQalc v$version';
  }

  @override
  String kcalRemaining(int kcal) {
    return '$kcal kcal left';
  }

  @override
  String get errorLoadingProfile => 'Failed to load profile.';

  @override
  String get tooltipOnline => 'Online';

  @override
  String get tooltipOffline => 'Offline';

  @override
  String get madeByLabel => 'Made by Szymon Rózga';

  @override
  String get tooltipApiRepo => 'API';

  @override
  String get tooltipFrontendRepo => 'Frontend';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get profileAccountSettingsTitle => 'Account settings';

  @override
  String get profileEditButton => 'Edit';

  @override
  String get profileChangeEmailButton => 'Change email';

  @override
  String get profileChangePasswordButton => 'Change password';

  @override
  String get profileDeleteAccountButton => 'Delete account';

  @override
  String get profileActiveSessionsTitle => 'Active sessions';

  @override
  String get profileSessionCurrent => 'Current device';

  @override
  String get profileSessionRevoke => 'Revoke';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get profileChangeEmailDialogSubtitle =>
      'Enter your current password and the new email address.';

  @override
  String get profileChangeEmailCodeSubtitle =>
      'Enter the 6-digit verification code sent to your new email.';

  @override
  String get errorInvalidPassword => 'Invalid current password.';

  @override
  String get emailChangedSuccessfully => 'Email address successfully changed!';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get profileChangePasswordDialogSubtitle =>
      'Enter and confirm your new password.';

  @override
  String get profileChangePasswordCodeSubtitle =>
      'Enter the 6-digit verification code sent to your email.';

  @override
  String get passwordChangedSuccessfully =>
      'Password successfully changed! Please log in again.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get profileDeleteAccountDialogTitle => 'Delete account';

  @override
  String get profileDeleteAccountWarning =>
      'Are you sure you want to delete your account? This action is permanent and cannot be undone.';

  @override
  String get profileDeleteAccountCodeSubtitle =>
      'Enter the 6-digit verification code sent to your email to permanently delete your account.';

  @override
  String get accountDeletedSuccessfully =>
      'Your account has been successfully deleted.';

  @override
  String get requestDeleteButton => 'Request deletion';

  @override
  String get confirmDeleteButton => 'Permanently delete';

  @override
  String get deviceWeb => 'Web Browser';

  @override
  String get deviceAndroid => 'Android Device';

  @override
  String get deviceIos => 'iOS Device';

  @override
  String get deviceWindows => 'Windows PC';

  @override
  String get deviceLinux => 'Linux Native App';

  @override
  String get deviceMac => 'Mac / MacBook';

  @override
  String get deviceUnknown => 'Unknown Device';

  @override
  String get lastActive => 'Last active';

  @override
  String get errorSessionRevoke => 'Failed to revoke session';

  @override
  String get warningHighDeficitYellow =>
      'This is a fast reduction pace. Ensure you get enough nutrients.';

  @override
  String get warningExtremeDeficitRed =>
      'Extreme caloric deficit! This can lead to muscle loss and health issues. Consider a more moderate pace.';

  @override
  String get forgotPasswordButton => 'Forgot password?';

  @override
  String get forgotPasswordDialogSubtitle =>
      'Enter your email address to receive a password reset code.';

  @override
  String get forgotPasswordCodeSubtitle =>
      'Enter the 6-digit verification code sent to your email and set a new password.';

  @override
  String get aboutDescription =>
      'GluQalc is an application supporting the monitoring of diet, macronutrients, as well as glycemic and insulin parameters.';

  @override
  String get aboutAuthor => 'Author';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutFrontendRepo => 'Frontend Repository';

  @override
  String get aboutBackendRepo => 'API Repository';

  @override
  String get aboutTos => 'Terms of Service (ToS)';

  @override
  String get aboutPrivacy => 'Privacy Policy';

  @override
  String get aboutDisclaimer => 'Medical Disclaimer';

  @override
  String get errorOpenUrl => 'Could not open URL';

  @override
  String get exportTitle => 'Export data';

  @override
  String get exportDescription =>
      'Generate a detailed CSV report with your entries, macronutrients, and insulin doses for the selected period.';

  @override
  String get exportSelectDates => 'Select date range';

  @override
  String get exportButton => 'Export to CSV';

  @override
  String get exportLoading =>
      'Generating file... This might take a few seconds.';

  @override
  String get exportSuccess => 'CSV file successfully generated!';

  @override
  String get errorRateLimit =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorNoProfile => 'User profile missing.';
}
