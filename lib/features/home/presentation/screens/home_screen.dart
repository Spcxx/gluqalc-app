import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/core/presentation/widgets/app_drawer.dart';
import 'package:gluqalc_app/features/home/data/models/day_summary_model.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_category_controller.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/add_category_modal.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/bottom_macro_summary.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/category_tile_item.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/date_slider_selector.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _showAddCategoryModal(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddCategoryModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedDate = ref.watch(homeSelectedDateProvider);
    final summaryAsync = ref.watch(daySummaryControllerProvider);
    final controller = ref.read(daySummaryControllerProvider.notifier);

    final categoriesAsync = ref.watch(mealCategoryControllerProvider);
    final summary =
        summaryAsync.value ?? controller.getCachedSummary(selectedDate);

    ref.listen<AppConnectionState>(connectivityServiceProvider, (prev, next) {
      if (next == AppConnectionState.offlineStartup) {
        context.go('/offline');
      } else if (next == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOffline),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next == AppConnectionState.online &&
          prev == AppConnectionState.offlineRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackbarOnline),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final connectionState = ref.watch(connectivityServiceProvider);
    final isOnline = connectionState == AppConnectionState.online;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Center(
          child: Tooltip(
            message: isOnline ? l10n.tooltipOnline : l10n.tooltipOffline,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? Colors.blue : colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        title: Assets.icons.appIcon.image(
          height: 42,
          fit: BoxFit.contain,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          const DateSliderSelector(),
          const Divider(height: 1),
          if (summaryAsync.isLoading || categoriesAsync.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: categoriesAsync.when(
              loading: () => categoriesAsync.hasValue
                  ? _buildCategoriesList(
                      context,
                      ref,
                      categoriesAsync.value!,
                      l10n,
                    )
                  : const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  l10n.errorUnknown(err.toString()),
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 64,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.emptyCategoriesTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.emptyCategoriesSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showAddCategoryModal(context, l10n),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addCategory),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _buildCategoriesList(context, ref, categories, l10n);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomMacroSummary(
        consumed:
            summary?.consumed ??
            const NutrientValues(
              energyKcal: 0,
              protein: 0,
              fat: 0,
              carbohydrates: 0,
            ),
        target:
            summary?.target ??
            const NutrientValues(
              energyKcal: 2000,
              protein: 150,
              fat: 65,
              carbohydrates: 200,
            ),
        l10n: l10n,
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    WidgetRef ref,
    List<MealCategoryResponse> categories,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: TextButton.icon(
                onPressed: () => _showAddCategoryModal(context, l10n),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  l10n.addCategory,
                  style: const TextStyle(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }

        final category = categories[index];
        return CategoryTileItem(
          key: ValueKey(category.id),
          category: category,
          l10n: l10n,
        );
      },
    );
  }
}
