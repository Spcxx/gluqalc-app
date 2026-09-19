import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_category_controller.g.dart';

@riverpod
class MealCategoryController extends _$MealCategoryController {
  @override
  Future<List<MealCategoryResponse>> build() async {
    final date = ref.watch(homeSelectedDateProvider);
    final repository = ref.watch(mealCategoryRepositoryProvider);
    return repository.getCategoriesWithEntries(date);
  }

  Future<void> createCategory(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(mealCategoryRepositoryProvider);
      await repository.createCategory(name);
      final date = ref.read(homeSelectedDateProvider);
      return repository.getCategoriesWithEntries(date);
    });
  }

  Future<void> deleteCategory(String id, {bool force = false}) async {
    final repository = ref.read(mealCategoryRepositoryProvider);

    try {
      await repository.deleteCategory(id, force: force);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(mealCategoryRepositoryProvider);
      await repository.deleteMealEntry(entryId);

      ref.invalidate(daySummaryControllerProvider);

      final date = ref.read(homeSelectedDateProvider);
      return repository.getCategoriesWithEntries(date);
    });
  }
}
