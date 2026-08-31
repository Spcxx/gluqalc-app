import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/product_search_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_edit_controller.g.dart';

@riverpod
class ProductEditController extends _$ProductEditController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> updateProduct({
    required String productId,
    required Map<String, dynamic> updatedFields,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(mealCategoryRepositoryProvider);

      final fieldsToSend = updatedFields.entries
          .where((e) => e.value != null)
          .fold<Map<String, dynamic>>(
            {},
            (map, entry) => map..[entry.key] = entry.value,
          );

      if (fieldsToSend.isEmpty) {
        state = const AsyncValue.data(null);
        return true;
      }

      await repo.updateProduct(productId, fieldsToSend);

      ref.invalidate(productSearchControllerProvider);

      state = const AsyncValue.data(null);
      return true;
    } on Object catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
