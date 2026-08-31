import 'package:dio/dio.dart';
import 'package:gluqalc_app/core/networking/dio_provider.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
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

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MealCategoryResponse.fromJson)
        .toList();
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
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

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

  Future<MealEntryResponse> getMealEntryDetails(String entryId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/log/$entryId',
    );
    return MealEntryResponse.fromJson(response.data!);
  }

  Future<ProductResponse> getProductDetails(String productId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/products/$productId',
    );
    return ProductResponse.fromJson(response.data!);
  }

  Future<List<ProductResponse>> getMyProducts() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/users/me/products');

    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ProductResponse.fromJson)
        .toList();
  }

  Future<List<ProductResponse>> searchProducts(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/products/search',
      queryParameters: {'q': query, 'quick': false},
    );

    final content = response.data?['content'] as List<dynamic>?;
    if (content == null) return [];

    final rawProducts = content
        .whereType<Map<String, dynamic>>()
        .map(ProductResponse.fromJson)
        .toList();

    final uniqueProductsMap = <String, ProductResponse>{};

    for (final product in rawProducts) {
      final barcode = product.barcode?.trim();

      final key = (barcode != null && barcode.isNotEmpty)
          ? 'barcode_$barcode'
          : 'name_${product.name.trim().toLowerCase()}_${(product.brand ?? '').trim().toLowerCase()}';

      if (uniqueProductsMap.containsKey(key)) {
        final existing = uniqueProductsMap[key]!;

        final isExistingLocal = existing.provider?.toUpperCase() == 'LOCAL';
        final isCurrentLocal = product.provider?.toUpperCase() == 'LOCAL';

        if (!isExistingLocal && isCurrentLocal) {
          uniqueProductsMap[key] = product;
        }
      } else {
        uniqueProductsMap[key] = product;
      }
    }

    return uniqueProductsMap.values.toList();
  }

  Future<ProductResponse> importExternalProduct(String barcode) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/products/import',
      data: {'barcode': barcode},
    );
    return ProductResponse.fromJson(response.data!);
  }

  Future<ProductResponse> updateProduct(
    String productId,
    Map<String, dynamic> updatedFields,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/products/$productId',
      data: updatedFields,
    );

    if (response.data == null || response.data!.isEmpty) {
      return getProductDetails(productId);
    }

    return ProductResponse.fromJson(response.data!);
  }
}
