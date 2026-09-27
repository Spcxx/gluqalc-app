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
    required this.originalEntryId,
    required this.calculatedEntry,
    required this.product,
    required this.categoryName,
    required this.selectedDateTime,
    required this.draftQuantity,
    required this.draftPortionId,
    this.isCalculating = false,
  });
  final String? originalEntryId;
  final MealEntryResponse? calculatedEntry;
  final ProductResponse product;
  final String categoryName;
  final DateTime selectedDateTime;
  final double draftQuantity;
  final String draftPortionId;
  final bool isCalculating;

  MealEntryDetailState copyWith({
    MealEntryResponse? calculatedEntry,
    ProductResponse? product,
    String? categoryName,
    DateTime? selectedDateTime,
    double? draftQuantity,
    String? draftPortionId,
    bool? isCalculating,
  }) {
    return MealEntryDetailState(
      originalEntryId: originalEntryId,
      calculatedEntry: calculatedEntry ?? this.calculatedEntry,
      product: product ?? this.product,
      categoryName: categoryName ?? this.categoryName,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      draftQuantity: draftQuantity ?? this.draftQuantity,
      draftPortionId: draftPortionId ?? this.draftPortionId,
      isCalculating: isCalculating ?? this.isCalculating,
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
    MealEntryResponse? calculated;
    var categoryName = '';
    DateTime currentDateTime;
    var draftQuantity = 1.0;
    var draftPortionId = '';

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

      if (product.portions.isNotEmpty) {
        final p100 = product.portions.firstWhere(
          (p) => p.name.trim().toLowerCase() == '100g',
          orElse: () => product.portions.first,
        );
        draftPortionId = p100.id;
      }

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

      calculated = await repository.calculateMealEntry(
        categoryId: _categoryId,
        productId: product.id,
        quantity: draftQuantity,
        date: currentDateTime,
        portionId: draftPortionId,
      );
    } else {
      calculated = await repository.getMealEntryDetails(entryId);
      currentDateTime =
          DateTime.tryParse(
            '${calculated.consumptionDate}T${calculated.consumptionTime}',
          ) ??
          DateTime.now();
      product = await repository.getProductDetails(
        calculated.productId,
        time: currentDateTime,
      );

      draftQuantity = calculated.portion.quantity;
      draftPortionId = calculated.portion.id;

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
      originalEntryId: isCreation ? null : entryId,
      calculatedEntry: calculated,
      product: product,
      categoryName: categoryName,
      selectedDateTime: currentDateTime,
      draftQuantity: draftQuantity,
      draftPortionId: draftPortionId,
    );
  }

  Future<void> updateDateTime(DateTime newDateTime) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        selectedDateTime: newDateTime,
        isCalculating: true,
      ),
    );
    await _recalculateDraft();
  }

  Future<void> updateDraft(double quantity, String portionId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        draftQuantity: quantity,
        draftPortionId: portionId,
        isCalculating: true,
      ),
    );
    await _recalculateDraft();
  }

  Future<void> _recalculateDraft() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final repo = ref.read(mealCategoryRepositoryProvider);
      final newCalc = await repo.calculateMealEntry(
        categoryId: _categoryId,
        productId: currentState.product.id,
        quantity: currentState.draftQuantity,
        date: currentState.selectedDateTime,
        portionId: currentState.draftPortionId,
      );
      state = AsyncValue.data(
        state.value!.copyWith(
          calculatedEntry: newCalc,
          isCalculating: false,
        ),
      );
    } on Object catch (_) {
      state = AsyncValue.data(state.value!.copyWith(isCalculating: false));
    }
  }

  Future<bool> commitEntry() async {
    final currentState = state.value;
    if (currentState == null) return false;

    try {
      final repo = ref.read(mealCategoryRepositoryProvider);

      if (currentState.originalEntryId != null) {
        await repo.deleteMealEntry(currentState.originalEntryId!);
      }

      await repo.addMealEntry(
        categoryId: _categoryId,
        productId: currentState.product.id,
        quantity: currentState.draftQuantity,
        date: currentState.selectedDateTime,
        portionId: currentState.draftPortionId,
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
