import 'package:flutter/foundation.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/data/models/product_response.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_category_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_entry_detail_controller.g.dart';

@immutable
class MealEntryDetailState {
  const MealEntryDetailState({
    required this.entry,
    required this.product,
    required this.categoryName,
  });
  final MealEntryResponse entry;
  final ProductResponse product;
  final String categoryName;
}

@riverpod
class MealEntryDetailController extends _$MealEntryDetailController {
  @override
  Future<MealEntryDetailState> build(String entryId) async {
    final repository = ref.watch(mealCategoryRepositoryProvider);

    final entry = await repository.getMealEntryDetails(entryId);

    final product = await repository.getProductDetails(entry.productId);
    var categoryName = '';
    final categoriesAsync = ref.read(mealCategoryControllerProvider);
    if (categoriesAsync.hasValue) {
      for (final cat in categoriesAsync.value!) {
        if (cat.entries.any((e) => e.id == entryId)) {
          categoryName = cat.name;
          break;
        }
      }
    }

    return MealEntryDetailState(
      entry: entry,
      product: product,
      categoryName: categoryName,
    );
  }

  Future<bool> updatePortion({
    required String entryId,
    required String categoryId,
    required String productId,
    required double quantity,
    required DateTime date,
    String? portionId,
  }) async {
    final repository = ref.read(mealCategoryRepositoryProvider);

    try {
      await repository.deleteMealEntry(entryId);

      await repository.addMealEntry(
        categoryId: categoryId,
        productId: productId,
        quantity: quantity,
        date: date,
        portionId: portionId,
      );

      ref
        ..invalidate(mealCategoryControllerProvider)
        ..invalidate(daySummaryControllerProvider);

      return true;
    } on Object catch (_) {
      return false;
    }
  }
}
