import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

@freezed
abstract class ProfileResponse with _$ProfileResponse {
  const factory ProfileResponse({
    String? gender,
    double? weightInKg,
    double? heightInCm,
    String? birthDate,
    int? age,
    double? physicalActivityLevel,
    int? kcalGoalDifference,
    Map<String, int>? weeklyKcalDistribution,
    double? bodyFatPercentage,
    String? bmrMethod,
    Map<String, double>? macroStrategy,
    double? insulinSensitivityFactor,
    double? insulinFatProteinRatio,
    String? insulinDeliveryMethod,
    String? combinedInsulinCalculationMethod,
    Map<String, double>? hourlyCarbRatio,
    ProfileTargets? targets,
  }) = _ProfileResponse;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
}

@freezed
abstract class ProfileTargets with _$ProfileTargets {
  const factory ProfileTargets({
    required double bmr,
    required double tdee,
    required double dailyKcalGoal,
    required double proteinGrams,
    required double fatGrams,
    required double carbsGrams,
  }) = _ProfileTargets;

  factory ProfileTargets.fromJson(Map<String, dynamic> json) =>
      _$ProfileTargetsFromJson(json);
}

@freezed
abstract class ProfileRequest with _$ProfileRequest {
  const factory ProfileRequest({
    String? gender,
    double? weightInKg,
    double? heightInCm,
    String? birthDate,
    double? physicalActivityLevel,
    int? kcalGoalDifference,
    Map<String, int>? weeklyKcalDistribution,
    double? bodyFatPercentage,
    String? bmrCalculationMethod,
    Map<String, double>? macroStrategy,
    double? insulinSensitivityFactor,
    double? insulinFatProteinRatio,
    String? insulinDeliveryMethod,
    String? combinedInsulinCalculationMethod,
    Map<String, double>? hourlyCarbRatio,
  }) = _ProfileRequest;

  factory ProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileRequestFromJson(json);
}
