import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_category_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_entry_detail_controller.g.dart';

class MealEntryDetailState {
  MealEntryDetailState({
    required this.entry,
    required this.product,
    required this.categoryName,
  });
  final MealEntryResponse? entry;
  final ProductResponse product;
  final String categoryName;
}

@riverpod
class MealEntryDetailController extends _$MealEntryDetailController {
  @override
  Future<MealEntryDetailState> build(
    String entryId, {
    bool isCreation = false,
    String? categoryId,
  }) async {
    final repository = ref.watch(mealCategoryRepositoryProvider);

    ProductResponse product;
    MealEntryResponse? entry;
    var categoryName = '';

    if (isCreation) {
      product = await repository.getProductDetails(entryId);

      if (categoryId != null) {
        final categoriesAsync = ref.read(mealCategoryControllerProvider);
        if (categoriesAsync.hasValue) {
          for (final cat in categoriesAsync.value!) {
            if (cat.id == categoryId) {
              categoryName = cat.name;
              break;
            }
          }
        }
      }
    } else {
      entry = await repository.getMealEntryDetails(entryId);
      product = await repository.getProductDetails(entry.productId);

      final categoriesAsync = ref.read(mealCategoryControllerProvider);
      if (categoriesAsync.hasValue) {
        for (final cat in categoriesAsync.value!) {
          if (cat.entries.any((e) => e.id == entryId)) {
            categoryName = cat.name;
            break;
          }
        }
      }
    }

    return MealEntryDetailState(
      entry: entry,
      product: product,
      categoryName: categoryName,
    );
  }

  Future<bool> saveOrUpdateEntry({
    required String id,
    required String categoryId,
    required double quantity,
    required DateTime date,
    required bool isCreation,
    String? portionId,
    String? oldEntryId,
  }) async {
    final repository = ref.read(mealCategoryRepositoryProvider);

    try {
      if (isCreation) {
        await repository.addMealEntry(
          categoryId: categoryId,
          productId: id,
          quantity: quantity,
          date: date,
          portionId: portionId,
        );
      } else {
        if (oldEntryId != null) {
          await repository.deleteMealEntry(oldEntryId);
        }
        await repository.addMealEntry(
          categoryId: categoryId,
          productId: id,
          quantity: quantity,
          date: date,
          portionId: portionId,
        );
      }

      ref
        ..invalidate(mealCategoryControllerProvider)
        ..invalidate(daySummaryControllerProvider);

      return true;
    } on Object catch (_) {
      return false;
    }
  }
}
