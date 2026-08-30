import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_category_repository.g.dart';

@riverpod
MealCategoryRepository mealCategoryRepository(Ref ref) {
  return MealCategoryRepository(ref.watch(dioProvider));
}

class MealCategoryRepository {
  MealCategoryRepository(this._dio);
  final Dio _dio;

  Future<List<MealCategoryResponse>> getCategoriesWithEntries(
    DateTime date,
  ) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/log',
      queryParameters: {'date': dateStr},
    );
    return response.data
            ?.map(
              (json) =>
                  MealCategoryResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList() ??
        [];
  }

  Future<MealCategoryResponse> createCategory(String name) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/log/categories',
      data: {'name': name},
    );
    return MealCategoryResponse.fromJson(response.data!);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete<void>('/api/v1/log/categories/$id');
  }

  Future<void> addMealEntry({
    required String categoryId,
    required String productId,
    required double quantity,
    required DateTime date,
    String? portionId,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final body = <String, dynamic>{
      'productId': productId,
      'mealCategoryId': categoryId,
      'date': dateStr,
      'quantity': quantity,
    };

    if (portionId != null) {
      body['portionId'] = portionId;
    }

    await _dio.post<dynamic>('/api/v1/log', data: body);
  }

  Future<void> deleteMealEntry(String entryId) async {
    await _dio.delete<void>('/api/v1/log/$entryId');
  }
}
