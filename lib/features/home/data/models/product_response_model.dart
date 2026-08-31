import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';

part 'product_response_model.freezed.dart';

@freezed
abstract class ProductResponse with _$ProductResponse {
  const factory ProductResponse({
    required String id,
    required String name,
    required NutritionInfo nutrition,
    String? brand,
    String? barcode,
    String? provider,
    @Default([]) List<ProductPortionResponse> portions,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    NutritionInfo parsedNutrition;
    try {
      parsedNutrition = NutritionInfo.fromJson(
        (json['nutrition'] as Map<String, dynamic>?) ?? {},
      );
    } on Object catch (_) {
      parsedNutrition = NutritionInfo.fromJson({});
    }

    return ProductResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nutrition: parsedNutrition,
      brand: json['brand']?.toString(),
      barcode: json['barcode']?.toString(),
      provider: json['provider']?.toString(),
      portions:
          (json['portions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ProductPortionResponse.fromJson)
              .toList() ??
          [],
    );
  }
}

@freezed
abstract class ProductPortionResponse with _$ProductPortionResponse {
  const factory ProductPortionResponse({
    required String id,
    required String name,
    required double weightInGrams,
  }) = _ProductPortionResponse;

  factory ProductPortionResponse.fromJson(Map<String, dynamic> json) {
    return ProductPortionResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      weightInGrams: _toDouble(json['weightInGrams']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0;
}
