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
    @JsonKey(fromJson: _clampPositive) required double bmr,
    @JsonKey(fromJson: _clampPositive) required double tdee,
    @JsonKey(fromJson: _clampPositive) required double dailyKcalGoal,
    @JsonKey(fromJson: _clampPositive) required double proteinGrams,
    @JsonKey(fromJson: _clampPositive) required double fatGrams,
    @JsonKey(fromJson: _clampPositive) required double carbsGrams,
  }) = _ProfileTargets;

  factory ProfileTargets.fromJson(Map<String, dynamic> json) =>
      _$ProfileTargetsFromJson(json);
}

double _clampPositive(dynamic value) {
  if (value == null) return 0;
  return (value as num).toDouble().clamp(0.0, double.infinity);
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
