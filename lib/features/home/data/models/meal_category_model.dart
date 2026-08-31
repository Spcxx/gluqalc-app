import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_category_model.freezed.dart';
part 'meal_category_model.g.dart';

@freezed
abstract class MealCategoryResponse with _$MealCategoryResponse {
  const factory MealCategoryResponse({
    required String id,
    required String name,
    required int sortOrder,
    @Default([]) List<MealEntryResponse> entries,
    NutritionInfo? totalNutrition,
    InsulinDoseInfo? insulinDose,
  }) = _MealCategoryResponse;

  factory MealCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$MealCategoryResponseFromJson(json);
}

@freezed
abstract class MealEntryResponse with _$MealEntryResponse {
  const factory MealEntryResponse({
    required String id,
    required String productId,
    required String productName,
    required PortionInfo portion,
    required NutritionInfo nutrition,
    required String consumptionDate,
    required String consumptionTime,
    String? brand,
    String? barcode,
    String? provider,
    InsulinDoseInfo? insulinDose,
  }) = _MealEntryResponse;

  factory MealEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$MealEntryResponseFromJson(json);
}

@freezed
abstract class PortionInfo with _$PortionInfo {
  const factory PortionInfo({
    required String id,
    required String name,
    @JsonKey(fromJson: _toDouble) required double quantity,
    @JsonKey(fromJson: _toDouble) required double unitWeight,
    @JsonKey(fromJson: _toDouble) required double totalWeight,
  }) = _PortionInfo;

  factory PortionInfo.fromJson(Map<String, dynamic> json) =>
      _$PortionInfoFromJson(json);
}

@freezed
abstract class NutritionInfo with _$NutritionInfo {
  const factory NutritionInfo({
    @JsonKey(fromJson: _toDouble) required double energyKcal,
    @JsonKey(fromJson: _toDouble) required double carbohydrates,
    @JsonKey(fromJson: _toDouble) required double sugars,
    @JsonKey(fromJson: _toDouble) required double fat,
    @JsonKey(fromJson: _toDouble) required double saturatedFat,
    @JsonKey(fromJson: _toDouble) required double protein,
    @JsonKey(fromJson: _toDouble) required double fiber,
    @JsonKey(fromJson: _toDouble) required double salt,
    @JsonKey(fromJson: _toDouble) required double glycemicIndex,
  }) = _NutritionInfo;

  factory NutritionInfo.fromJson(Map<String, dynamic> json) =>
      _$NutritionInfoFromJson(json);
}

@freezed
abstract class InsulinDoseInfo with _$InsulinDoseInfo {
  const factory InsulinDoseInfo({
    @JsonKey(fromJson: _toDouble) required double carbUnit,
    @JsonKey(fromJson: _toDouble) required double fatProteinUnit,
    @JsonKey(fromJson: _toDouble) required double carbDose,
    @JsonKey(fromJson: _toDouble) required double fatProteinDose,
    @JsonKey(fromJson: _toDouble) required double totalDose,
    required int bolusDurationMinutes,
    String? description,
  }) = _InsulinDoseInfo;

  factory InsulinDoseInfo.fromJson(Map<String, dynamic> json) =>
      _$InsulinDoseInfoFromJson(json);
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0;
}
