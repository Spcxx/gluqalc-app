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

double _toDouble(dynamic value) {
  if (value == null) return 0;
  return (value as num).toDouble();
}
