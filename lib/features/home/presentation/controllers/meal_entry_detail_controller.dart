import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_category_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_entry_detail_controller.g.dart';

class MealEntryDetailState {
  MealEntryDetailState({
    required this.entry,
    required this.product,
    required this.categoryName,
    required this.selectedDateTime,
  });
  final MealEntryResponse? entry;
  final ProductResponse product;
  final String categoryName;
  final DateTime selectedDateTime;

  MealEntryDetailState copyWith({
    MealEntryResponse? entry,
    ProductResponse? product,
    String? categoryName,
    DateTime? selectedDateTime,
  }) {
    return MealEntryDetailState(
      entry: entry ?? this.entry,
      product: product ?? this.product,
      categoryName: categoryName ?? this.categoryName,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
    );
  }
}

@riverpod
class MealEntryDetailController extends _$MealEntryDetailController {
  late String _categoryId;

  @override
  Future<MealEntryDetailState> build(
    String entryId, {
    bool isCreation = false,
    String? categoryId,
  }) async {
    _categoryId = categoryId ?? '';

    final repository = ref.watch(mealCategoryRepositoryProvider);

    ProductResponse product;
    MealEntryResponse? entry;
    var categoryName = '';
    DateTime currentDateTime;

    if (isCreation) {
      final selectedDateFromState = ref.read(homeSelectedDateProvider);
      final now = DateTime.now();
      currentDateTime = DateTime(
        selectedDateFromState.year,
        selectedDateFromState.month,
        selectedDateFromState.day,
        now.hour,
        now.minute,
      );

      product = await repository.getProductDetails(
        entryId,
        time: currentDateTime,
      );

      if (_categoryId.isNotEmpty) {
        final categoriesAsync = ref.read(mealCategoryControllerProvider);
        if (categoriesAsync.hasValue) {
          for (final cat in categoriesAsync.value!) {
            if (cat.id == _categoryId) {
              categoryName = cat.name;
              break;
            }
          }
        }
      }
    } else {
      entry = await repository.getMealEntryDetails(entryId);
      currentDateTime =
          DateTime.tryParse(
            '${entry.consumptionDate}T${entry.consumptionTime}',
          ) ??
          DateTime.now();
      product = await repository.getProductDetails(
        entry.productId,
        time: currentDateTime,
      );

      final categoriesAsync = ref.read(mealCategoryControllerProvider);
      if (categoriesAsync.hasValue) {
        for (final cat in categoriesAsync.value!) {
          if (cat.entries.any((e) => e.id == entryId)) {
            categoryName = cat.name;
            _categoryId = cat.id;
            break;
          }
        }
      }
    }

    return MealEntryDetailState(
      entry: entry,
      product: product,
      categoryName: categoryName,
      selectedDateTime: currentDateTime,
    );
  }

  Future<void> updateDateTime(DateTime newDateTime) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(selectedDateTime: newDateTime),
    );

    if (currentState.entry != null) {
      await saveEntry(
        currentState.entry!.portion.quantity,
        currentState.entry!.portion.id,
      );
    }
  }

  Future<bool> saveEntry(double quantity, String portionId) async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      final repo = ref.read(mealCategoryRepositoryProvider);

      if (currentState.entry != null) {
        await repo.deleteMealEntry(currentState.entry!.id);
      }

      final newEntry = await repo.addMealEntry(
        categoryId: _categoryId,
        productId: currentState.product.id,
        quantity: quantity,
        date: currentState.selectedDateTime,
        portionId: portionId,
      );

      state = AsyncValue.data(currentState.copyWith(entry: newEntry));

      ref
        ..invalidate(mealCategoryControllerProvider)
        ..invalidate(daySummaryControllerProvider);

      return true;
    } on Object catch (_) {
      return false;
    }
  }
}
