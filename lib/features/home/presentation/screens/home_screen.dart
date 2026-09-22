import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/core/gen/assets.gen.dart';
import 'package:gluqalc_app/core/networking/connectivity_service.dart';
import 'package:gluqalc_app/core/networking/server_health_service.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const AddCategoryModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    final selectedDate = ref.watch(homeSelectedDateProvider);
    final summaryAsync = ref.watch(daySummaryControllerProvider);
    final controller = ref.read(daySummaryControllerProvider.notifier);

    final categoriesAsync = ref.watch(mealCategoryControllerProvider);
    final summary =
        summaryAsync.value ?? controller.getCachedSummary(selectedDate);

    ref.listen<AppConnectionState>(connectivityServiceProvider, (prev, next) {
      if (next == AppConnectionState.offlineStartup) {
        context.go('/offline');
      }
    });
    final serverHealthState = ref.watch(serverHealthServiceProvider);

    Color getDotColor() {
      switch (serverHealthState) {
        case ServerHealthState.online:
          return colorScheme.tertiary;
        case ServerHealthState.warning:
          return Colors.orange;
        case ServerHealthState.offline:
          return colorScheme.error;
        case ServerHealthState.loading:
          return Colors.grey;
      }
    }

    String getTooltipMessage() {
      switch (serverHealthState) {
        case ServerHealthState.online:
          return l10n.tooltipOnline;
        case ServerHealthState.warning:
          return l10n.tooltipReconnecting;
        case ServerHealthState.offline:
        case ServerHealthState.loading:
          return l10n.tooltipOffline;
      }
    }

    final macroSummaryWidget = BottomMacroSummary(
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
      insulinSummary: summary?.insulinSummary,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Center(
          child: Tooltip(
            message: getTooltipMessage(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: getDotColor(),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        title: Assets.icons.appIcon.image(
          height: 42,
          fit: BoxFit.contain,
        ),
        actions: isDesktop
            ? []
            : [
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
      endDrawer: isDesktop ? null : const AppDrawer(),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const DateSliderSelector(),
                const Divider(height: 1),
                if (summaryAsync.isLoading || categoriesAsync.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
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
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.errorUnknown(err.toString()),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer
                                            .withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.restaurant_menu_rounded,
                                        size: 48,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.emptyCategoriesTitle,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.emptyCategoriesSubtitle,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _showAddCategoryModal(context, l10n),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: Text(l10n.addCategory),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return _buildCategoriesList(
                            context,
                            ref,
                            categories,
                            l10n,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (isDesktop) macroSummaryWidget,
              ],
            ),
          ),
          if (isDesktop)
            SizedBox(
              width: 320,
              child: Material(
                color: colorScheme.surface,
                child: const AppDrawerBody(isDrawer: false),
              ),
            ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : macroSummaryWidget,
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    WidgetRef ref,
    List<MealCategoryResponse> categories,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: () => _showAddCategoryModal(context, l10n),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  l10n.addCategory,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
