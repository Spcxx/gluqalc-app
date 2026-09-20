import 'package:flutter/foundation.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/recent_products_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_search_controller.g.dart';

@riverpod
class ProductSearchController extends _$ProductSearchController {
  @override
  FutureOr<List<ProductResponse>> build() async {
    return [];
  }

  Future<void> searchProducts(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 3) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    final repository = ref.read(mealCategoryRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.searchProducts(trimmedQuery);
    });
  }

  Future<List<ProductResponse>> getMyProducts() async {
    final repository = ref.read(mealCategoryRepositoryProvider);
    try {
      return await repository.getMyProducts();
    } on Object catch (e, stackTrace) {
      debugPrint('Failed to fetch custom products: $e\n$stackTrace');
      return [];
    }
  }

  Future<String?> resolveOrImportBarcode(String barcode) async {
    final repository = ref.read(mealCategoryRepositoryProvider);
    try {
      final imported = await repository.importExternalProduct(barcode);
      if (imported.id.isNotEmpty) {
        ref
            .read(recentProductsControllerProvider.notifier)
            .addProduct(imported);
        return imported.id;
      }
    } on Object catch (_) {
      return null;
    }
    return null;
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}
