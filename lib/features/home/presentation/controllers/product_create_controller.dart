import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/product_search_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_create_controller.g.dart';

@riverpod
class ProductCreateController extends _$ProductCreateController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<ProductResponse?> createProduct(
    Map<String, dynamic> productData,
  ) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mealCategoryRepositoryProvider);
      final createdProduct = await repo.createProduct(productData);

      ref.invalidate(productSearchControllerProvider);

      state = const AsyncValue.data(null);
      return createdProduct;
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
