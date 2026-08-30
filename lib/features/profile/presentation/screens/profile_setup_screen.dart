import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:gluqalc_app/features/profile/data/models/profile_models.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_10_summary_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_1_basics_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_2_bmr_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_3_pal_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_4_goal_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_5_weekly_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_6_macro_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_7_diabetic_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_8_icr_widget.dart';
import 'package:gluqalc_app/features/profile/presentation/screens/steps/step_9_fpu_widget.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

enum GenderEnum { female, male, other }

enum BmrMethodEnum { harrisBenedict, mifflinStJeor, katchMcArdle, owen }

enum GoalTypeEnum { lose, maintain, gain }

enum InsulinDeliveryEnum { pen, pump }

enum CombinedInsulinEnum { pankowska, sieradzki }

enum MacroPresetEnum { balanced, highProtein, lowCarb, keto, custom }

enum WeekDayEnum {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({this.isEditing = false, super.key});
  final bool isEditing;

  @override
  ConsumerState<ProfileSetupScreen> createState() => ProfileSetupScreenState();
}

class ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyDiabetic = GlobalKey<FormState>();

  int currentStep = 0;
  static const int totalSteps = 10;

  // data
  GenderEnum? selectedGender;
  DateTime? selectedBirthDate;
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool knowsBodyFat = false;
  final TextEditingController bodyFatController = TextEditingController();

  BmrMethodEnum? selectedBmrMethod;

  int? q1Answer;
  int? q2Answer;
  int? q3Answer;
  int? q4Answer;
  double palValue = 1.4;
  bool isManualPal = false;

  GoalTypeEnum? goalType;
  double weightChangeTargetKg = 5;
  int kcalGoalDifference = 0;

  bool enableWeeklyDistribution = false;
  final Map<WeekDayEnum, TextEditingController> dayControllers = {
    WeekDayEnum.monday: TextEditingController(text: '0'),
    WeekDayEnum.tuesday: TextEditingController(text: '0'),
    WeekDayEnum.wednesday: TextEditingController(text: '0'),
    WeekDayEnum.thursday: TextEditingController(text: '0'),
    WeekDayEnum.friday: TextEditingController(text: '0'),
    WeekDayEnum.saturday: TextEditingController(text: '0'),
    WeekDayEnum.sunday: TextEditingController(text: '0'),
  };

  MacroPresetEnum macroPreset = MacroPresetEnum.balanced;
  double proteinPercent = 30;
  double fatPercent = 25;
  double carbPercent = 45;

  final TextEditingController isfController = TextEditingController();
  final TextEditingController ifpController = TextEditingController();
  InsulinDeliveryEnum insulinDeliveryMethod = InsulinDeliveryEnum.pen;

  final List<HourIcrItem> hourIcrItems = [
    HourIcrItem(hour: 0, icrValue: 1),
  ];

  CombinedInsulinEnum combinedInsulinMethod = CombinedInsulinEnum.pankowska;

  @override
  void initState() {
    super.initState();
    for (final controller in dayControllers.values) {
      controller.addListener(_onWeeklyDistributionChanged);
    }

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profile = ref.read(profileControllerProvider).value;
        if (profile != null) _prefillData(profile);
      });
    }
  }

  void _prefillData(ProfileResponse profile) {
    setState(() {
      if (profile.gender == 'FEMALE') selectedGender = GenderEnum.female;
      if (profile.gender == 'MALE') selectedGender = GenderEnum.male;
      if (profile.gender == 'OTHER') selectedGender = GenderEnum.other;

      if (profile.birthDate != null) {
        selectedBirthDate = DateTime.tryParse(profile.birthDate!);
      }
      heightController.text = profile.heightInCm?.toString() ?? '';
      weightController.text = profile.weightInKg?.toString() ?? '';
      if (profile.bodyFatPercentage != null) {
        knowsBodyFat = true;
        bodyFatController.text = profile.bodyFatPercentage.toString();
      }

      if (profile.bmrMethod == 'HARRIS_BENEDICT') {
        selectedBmrMethod = BmrMethodEnum.harrisBenedict;
      }
      if (profile.bmrMethod == 'MIFFLIN_ST_JEOR') {
        selectedBmrMethod = BmrMethodEnum.mifflinStJeor;
      }
      if (profile.bmrMethod == 'KATCH_MCARDLE') {
        selectedBmrMethod = BmrMethodEnum.katchMcArdle;
      }
      if (profile.bmrMethod == 'OWEN') selectedBmrMethod = BmrMethodEnum.owen;

      palValue = profile.physicalActivityLevel ?? 1.4;
      isManualPal = true;

      if (profile.kcalGoalDifference != null) {
        kcalGoalDifference = profile.kcalGoalDifference!;
        if (kcalGoalDifference < 0) {
          goalType = GoalTypeEnum.lose;
          weightChangeTargetKg = (kcalGoalDifference.abs() / 48)
              .roundToDouble()
              .clamp(0.5, 30.0);
        } else if (kcalGoalDifference > 0) {
          goalType = GoalTypeEnum.gain;
          weightChangeTargetKg = (kcalGoalDifference / 48)
              .roundToDouble()
              .clamp(0.5, 30.0);
        } else {
          goalType = GoalTypeEnum.maintain;
        }
      }

      if (profile.weeklyKcalDistribution != null &&
          profile.weeklyKcalDistribution!.isNotEmpty) {
        enableWeeklyDistribution = true;
        profile.weeklyKcalDistribution!.forEach((dayStr, kcal) {
          final dayEnum = WeekDayEnum.values.firstWhere(
            (e) => e.name.toUpperCase() == dayStr,
            orElse: () => WeekDayEnum.monday,
          );
          dayControllers[dayEnum]?.text = kcal.toString();
        });
      }

      if (profile.macroStrategy != null) {
        macroPreset = MacroPresetEnum.custom;
        proteinPercent = (profile.macroStrategy!['PROTEIN'] ?? 0.3) * 100;
        fatPercent = (profile.macroStrategy!['FAT'] ?? 0.25) * 100;
        carbPercent = (profile.macroStrategy!['CARBOHYDRATE'] ?? 0.45) * 100;
      }

      isfController.text = profile.insulinSensitivityFactor?.toString() ?? '';
      ifpController.text = profile.insulinFatProteinRatio?.toString() ?? '';

      if (profile.insulinDeliveryMethod == 'PUMP') {
        insulinDeliveryMethod = InsulinDeliveryEnum.pump;
      } else {
        insulinDeliveryMethod = InsulinDeliveryEnum.pen;
      }

      if (profile.combinedInsulinCalculationMethod == 'SIERADZKI') {
        combinedInsulinMethod = CombinedInsulinEnum.sieradzki;
      } else {
        combinedInsulinMethod = CombinedInsulinEnum.pankowska;
      }

      if (profile.hourlyCarbRatio != null &&
          profile.hourlyCarbRatio!.isNotEmpty) {
        hourIcrItems.clear();
        profile.hourlyCarbRatio!.forEach((hourStr, icr) {
          hourIcrItems.add(
            HourIcrItem(hour: int.parse(hourStr), icrValue: icr),
          );
        });
        hourIcrItems.sort((a, b) => a.hour.compareTo(b.hour));
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    heightController.dispose();
    weightController.dispose();
    bodyFatController.dispose();
    isfController.dispose();
    ifpController.dispose();
    for (final controller in dayControllers.values) {
      controller
        ..removeListener(_onWeeklyDistributionChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onWeeklyDistributionChanged() => setState(() {});

  int getWeeklySum() {
    var sum = 0;
    for (final controller in dayControllers.values) {
      sum += int.tryParse(controller.text) ?? 0;
    }
    return sum;
  }

  String? validateHourlyIcr(AppLocalizations l10n) {
    if (hourIcrItems.isEmpty) return l10n.errorIcrEmpty;
    final checkedHours = <int>{};
    var hasHourZero = false;

    for (final item in hourIcrItems) {
      if (item.hour < 0 || item.hour > 23) return l10n.errorIcrRange;
      if (item.icrValue <= 0) return l10n.errorIcrValue;
      if (item.hour == 0) hasHourZero = true;
      if (checkedHours.contains(item.hour)) {
        return l10n.errorIcrDuplicate(item.hour);
      }
      checkedHours.add(item.hour);
    }
    if (!hasHourZero) return l10n.errorIcrBaseRequired;
    return null;
  }

  void nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      if (currentStep < totalSteps - 1) currentStep++;
    });
  }

  void prevStep() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      if (currentStep > 0) currentStep--;
    });
  }

  BmrMethodEnum getRecommendedBmrMethod() {
    if (knowsBodyFat && bodyFatController.text.isNotEmpty) {
      return BmrMethodEnum.katchMcArdle;
    }
    final h =
        double.tryParse(heightController.text.replaceAll(',', '.')) ?? 170;
    final w = double.tryParse(weightController.text.replaceAll(',', '.')) ?? 70;
    final bmi = w / ((h / 100) * (h / 100));
    if (bmi >= 30) return BmrMethodEnum.owen;
    return BmrMethodEnum.harrisBenedict;
  }

  void showInfoDialog(String title, String description) {
    final l10n = AppLocalizations.of(context)!;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.okButton),
            ),
          ],
        ),
      ),
    );
  }

  String _bmrMethodToString(BmrMethodEnum method) {
    switch (method) {
      case BmrMethodEnum.harrisBenedict:
        return 'HARRIS_BENEDICT';
      case BmrMethodEnum.mifflinStJeor:
        return 'MIFFLIN_ST_JEOR';
      case BmrMethodEnum.katchMcArdle:
        return 'KATCH_MCARDLE';
      case BmrMethodEnum.owen:
        return 'OWEN';
    }
  }

  String? _genderToString(GenderEnum? gender) {
    if (gender == null) return null;
    switch (gender) {
      case GenderEnum.female:
        return 'FEMALE';
      case GenderEnum.male:
        return 'MALE';
      case GenderEnum.other:
        return 'OTHER';
    }
  }

  String _weekDayToString(WeekDayEnum day) {
    return day.name.toUpperCase();
  }

  Future<void> finishSetup() async {
    final l10n = AppLocalizations.of(context)!;

    Map<String, int>? weeklyDistribution;
    if (enableWeeklyDistribution) {
      weeklyDistribution = {};
      dayControllers.forEach((dayEnum, controller) {
        final val = int.tryParse(controller.text) ?? 0;
        if (val != 0) {
          weeklyDistribution![_weekDayToString(dayEnum)] = val;
        }
      });
    }

    final hourlyCarbRatioMap = <String, double>{
      for (final item in hourIcrItems) item.hour.toString(): item.icrValue,
    };

    final request = ProfileRequest(
      gender: _genderToString(selectedGender),
      weightInKg: double.tryParse(weightController.text.replaceAll(',', '.')),
      heightInCm: double.tryParse(heightController.text.replaceAll(',', '.')),
      birthDate: selectedBirthDate?.toIso8601String().split('T')[0],
      physicalActivityLevel: double.parse(palValue.toStringAsFixed(2)),
      kcalGoalDifference: kcalGoalDifference,
      weeklyKcalDistribution: weeklyDistribution,
      bodyFatPercentage: knowsBodyFat
          ? double.tryParse(bodyFatController.text.replaceAll(',', '.'))
          : null,
      bmrCalculationMethod: selectedBmrMethod != null
          ? _bmrMethodToString(selectedBmrMethod!)
          : null,
      macroStrategy: {
        'PROTEIN': proteinPercent / 100.0,
        'FAT': fatPercent / 100.0,
        'CARBOHYDRATE': carbPercent / 100.0,
      },
      insulinSensitivityFactor: double.tryParse(
        isfController.text.replaceAll(',', '.'),
      ),
      insulinFatProteinRatio: double.tryParse(
        ifpController.text.replaceAll(',', '.'),
      ),
      insulinDeliveryMethod: insulinDeliveryMethod.name.toUpperCase(),
      combinedInsulinCalculationMethod: combinedInsulinMethod.name
          .toUpperCase(),
      hourlyCarbRatio: hourlyCarbRatioMap,
    );

    try {
      await ref.read(profileControllerProvider.notifier).submitProfile(request);

      if (mounted) {
        if (widget.isEditing) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.errorGeneric(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileControllerProvider);

    return profileState.when(
      data: (profile) {
        if (profile != null && !widget.isEditing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profileSetupTitle),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (currentStep + 1) / totalSteps,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.profileStepIndicator(currentStep + 1, totalSteps),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Step1BasicsWidget(parent: this),
                        Step2BmrWidget(parent: this),
                        Step3PalWidget(parent: this),
                        Step4GoalWidget(parent: this),
                        Step5WeeklyWidget(parent: this),
                        Step6MacroWidget(parent: this),
                        Step7DiabeticWidget(parent: this),
                        Step8IcrWidget(parent: this),
                        Step9FpuWidget(parent: this),
                        Step10SummaryWidget(parent: this),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (err, _) => Scaffold(
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
                  l10n.errorTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(profileControllerProvider);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.backToFormButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HourIcrItem {
  HourIcrItem({required this.hour, required this.icrValue});

  int hour;
  double icrValue;
}
