import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_category_controller.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/insulin_details_dialog.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CategoryTileItem extends ConsumerStatefulWidget {
  const CategoryTileItem({
    required this.category,
    required this.l10n,
    super.key,
  });

  final MealCategoryResponse category;
  final AppLocalizations l10n;

  @override
  ConsumerState<CategoryTileItem> createState() => _CategoryTileItemState();
}

class _CategoryTileItemState extends ConsumerState<CategoryTileItem> {
  bool _isExpanded = true;
  bool _showCategoryMacros = false;
  final Set<String> _showEntryMacrosIds = {};

  Widget _buildSingleMacroColumn(
    String label,
    double value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(1)}g',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMacrosExpandableSection({
    required bool isExpanded,
    required VoidCallback onTap,
    required double carbs,
    required double protein,
    required double fat,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSingleMacroColumn(
                          l10n.unitCarbShort,
                          carbs,
                          colorScheme,
                          textTheme,
                        ),
                        _buildSingleMacroColumn(
                          l10n.unitProteinShort,
                          protein,
                          colorScheme,
                          textTheme,
                        ),
                        _buildSingleMacroColumn(
                          l10n.unitFatShort,
                          fat,
                          colorScheme,
                          textTheme,
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_left,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final category = widget.category;
    final l10n = widget.l10n;
    final profile = ref.watch(profileControllerProvider).value;

    final nutrition = category.totalNutrition;
    final kcal = nutrition?.energyKcal.toInt() ?? 0;
    final carbs = nutrition?.carbohydrates ?? 0.0;
    final protein = nutrition?.protein ?? 0.0;
    final fat = nutrition?.fat ?? 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$kcal kcal',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMacrosExpandableSection(
                    isExpanded: _showCategoryMacros,
                    onTap: () => setState(
                      () => _showCategoryMacros = !_showCategoryMacros,
                    ),
                    carbs: carbs,
                    protein: protein,
                    fat: fat,
                    l10n: l10n,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 90,
                    child: buildInsulinComponent(
                      context,
                      category.insulinDose,
                      profile,
                      l10n,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        try {
                          await ref
                              .read(mealCategoryControllerProvider.notifier)
                              .deleteCategory(category.id);
                        } on Object catch (e) {
                          if (context.mounted) {
                            final message =
                                e is DioException &&
                                    e.response?.statusCode == 409
                                ? l10n.categoryNotEmptyError
                                : l10n.errorUnknown(e.toString());

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.deleteCategory,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      color: colorScheme.primary,
                      tooltip: l10n.addMeal,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await context.push('/product-search/${category.id}');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: category.entries.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.placeholderMeal,
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: category.entries.map((entry) {
                      final entryKcal = entry.nutrition.energyKcal.toInt();
                      final entryCarbs = entry.nutrition.carbohydrates;
                      final entryProtein = entry.nutrition.protein;
                      final entryFat = entry.nutrition.fat;
                      final isEntryMacrosShown = _showEntryMacrosIds.contains(
                        entry.id,
                      );

                      final isDefault100g =
                          entry.portion.name.trim().toLowerCase() == '100g';
                      final qtyStr = entry.portion.quantity
                          .toStringAsFixed(1)
                          .replaceAll(RegExp(r'\.0$'), '');
                      final portionLabel = isDefault100g
                          ? '${entry.portion.totalWeight.toInt()} g'
                          : '$qtyStr x ${entry.portion.name} (${entry.portion.totalWeight.toInt()} g)';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push(
                            '/meal-entry-details/${entry.id}?categoryId=${widget.category.id}',
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              entry.productName,
                                              style: textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (entry.provider != null &&
                                              entry.provider!.toUpperCase() !=
                                                  'LOCAL') ...[
                                            const SizedBox(width: 4),
                                            Tooltip(
                                              message:
                                                  l10n.externalDatabaseTooltip,
                                              child: Icon(
                                                Icons.public,
                                                size: 14,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        portionLabel,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$entryKcal kcal',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildMacrosExpandableSection(
                                      isExpanded: isEntryMacrosShown,
                                      onTap: () {
                                        setState(() {
                                          if (isEntryMacrosShown) {
                                            _showEntryMacrosIds.remove(
                                              entry.id,
                                            );
                                          } else {
                                            _showEntryMacrosIds.add(entry.id);
                                          }
                                        });
                                      },
                                      carbs: entryCarbs,
                                      protein: entryProtein,
                                      fat: entryFat,
                                      l10n: l10n,
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 90,
                                      child: buildInsulinComponent(
                                        context,
                                        entry.insulinDose,
                                        profile,
                                        l10n,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      color: colorScheme.error.withValues(
                                        alpha: 0.7,
                                      ),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              mealCategoryControllerProvider
                                                  .notifier,
                                            )
                                            .deleteEntry(entry.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
      ],
    );
  }
}
