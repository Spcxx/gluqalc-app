import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

@freezed
abstract class ProductResponse with _$ProductResponse {
  const factory ProductResponse({
    required String id,
    required String name,
    required NutritionInfo nutrition,
    String? brand,
    String? barcode,
    @Default([]) List<ProductPortionResponse> portions,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
}

@freezed
abstract class ProductPortionResponse with _$ProductPortionResponse {
  const factory ProductPortionResponse({
    required String id,
    required String name,
    @JsonKey(fromJson: _toDouble) required double weightInGrams,
    @Default(false) bool published,
  }) = _ProductPortionResponse;

  factory ProductPortionResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductPortionResponseFromJson(json);
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0;
}
