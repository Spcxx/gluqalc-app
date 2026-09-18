import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_summary_model.freezed.dart';
part 'day_summary_model.g.dart';

@freezed
abstract class DaySummaryResponse with _$DaySummaryResponse {
  const factory DaySummaryResponse({
    required String date,
    required NutrientValues target,
    required NutrientValues consumed,
    required NutrientValues remaining,
    DailyInsulinSummary? insulinSummary,
  }) = _DaySummaryResponse;

  factory DaySummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DaySummaryResponseFromJson(json);
}

@freezed
abstract class NutrientValues with _$NutrientValues {
  const factory NutrientValues({
    @JsonKey(fromJson: _toDouble) required double energyKcal,
    @JsonKey(fromJson: _toDouble) required double protein,
    @JsonKey(fromJson: _toDouble) required double fat,
    @JsonKey(fromJson: _toDouble) required double carbohydrates,
  }) = _NutrientValues;

  factory NutrientValues.fromJson(Map<String, dynamic> json) =>
      _$NutrientValuesFromJson(json);
}

@freezed
abstract class DailyInsulinSummary with _$DailyInsulinSummary {
  const factory DailyInsulinSummary({
    @JsonKey(fromJson: _toDouble) required double totalCarbUnits,
    @JsonKey(fromJson: _toDouble) required double totalFatProteinUnits,
    @JsonKey(name: 'totalCarbDose', fromJson: _toDouble)
    required double consumedCarbDose,
    @JsonKey(name: 'totalFatProteinDose', fromJson: _toDouble)
    required double consumedFatProteinDose,
    @JsonKey(name: 'totalBolusDose', fromJson: _toDouble)
    required double consumedBolusDose,
    @JsonKey(fromJson: _toDoubleNullable) double? estimatedTotalDailyDose,
    @JsonKey(fromJson: _toDoubleNullable) double? dailyBasalInsulin,
    @JsonKey(fromJson: _toDoubleNullable) double? estimatedBolusTarget,
    @JsonKey(fromJson: _toDoubleNullable) double? remainingBolusTarget,
  }) = _DailyInsulinSummary;

  factory DailyInsulinSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyInsulinSummaryFromJson(json);
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  return (value as num).toDouble();
}

double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  return (value as num).toDouble();
}
