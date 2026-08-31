import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_entry_detail_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_portions_controller.g.dart';

@riverpod
class ProductPortionsController extends _$ProductPortionsController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<ProductResponse?> addPortion({
    required String productId,
    required String name,
    required double weightInGrams,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mealCategoryRepositoryProvider);
      final updatedProduct = await repo.addPortion(
        productId: productId,
        name: name,
        weightInGrams: weightInGrams,
      );

      ref.invalidate(mealEntryDetailControllerProvider);

      state = const AsyncValue.data(null);
      return updatedProduct;
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<ProductResponse?> updatePortion({
    required String portionId,
    required String productId,
    required String name,
    required double weightInGrams,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mealCategoryRepositoryProvider);
      final updatedProduct = await repo.updatePortion(
        portionId: portionId,
        productId: productId,
        name: name,
        weightInGrams: weightInGrams,
      );

      ref.invalidate(mealEntryDetailControllerProvider);

      state = const AsyncValue.data(null);
      return updatedProduct;
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deletePortion(String portionId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mealCategoryRepositoryProvider);
      await repo.deletePortion(portionId);

      ref.invalidate(mealEntryDetailControllerProvider);

      state = const AsyncValue.data(null);
      return true;
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
