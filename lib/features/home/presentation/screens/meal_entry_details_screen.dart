import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_entry_detail_controller.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/insulin_details_dialog.dart';
import 'package:gluqalc_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MealEntryDetailsScreen extends ConsumerStatefulWidget {
  const MealEntryDetailsScreen({
    required this.entryId,
    required this.categoryId,
    this.isCreation = false,
    super.key,
  });
  final String entryId;
  final String categoryId;
  final bool isCreation;

  @override
  ConsumerState<MealEntryDetailsScreen> createState() =>
      _MealEntryDetailsScreenState();
}

class _MealEntryDetailsScreenState
    extends ConsumerState<MealEntryDetailsScreen> {
  bool _isSaving = false;

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    setState(() => _isSaving = true);

    final success = await ref
        .read(
          mealEntryDetailControllerProvider(
            widget.entryId,
            isCreation: widget.isCreation,
            categoryId: widget.categoryId,
          ).notifier,
        )
        .commitEntry();

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isCreation
                  ? l10n.mealAddedSuccessfully
                  : l10n.portionUpdatedSuccess,
            ),
            backgroundColor: colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorCouldntSaveEntry),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final stateAsync = ref.watch(
      mealEntryDetailControllerProvider(
        widget.entryId,
        isCreation: widget.isCreation,
        categoryId: widget.categoryId,
      ),
    );
    final summaryAsync = ref.watch(daySummaryControllerProvider);
    final profile = ref.watch(profileControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: const Icon(Icons.check),
                color: colorScheme.primary,
                onPressed: _handleSave,
              ),
            ),
        ],
        title: stateAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Text(l10n.mealDetailsTitle),
          data: (state) {
            final currentDateTime = state.selectedDateTime;
            final formattedDate = DateFormat.yMMMMd(l10n.localeName)
                .format(currentDateTime);
            final formattedTime = DateFormat.Hm().format(currentDateTime);
            final formattedDateTime = '$formattedDate, $formattedTime';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.categoryName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDateTime,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.errorUnknown(err.toString()),
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (state) {
          final product = state.product;

          final entry = state.calculatedEntry;
          final nutrition = entry?.nutrition ?? product.nutrition;
          final currentInsulin = entry?.insulinDose;

          final dailyTarget = summaryAsync.value?.target;
          final targetCarbs = dailyTarget?.carbohydrates ?? 250.0;
          final targetProtein = dailyTarget?.protein ?? 120.0;
          final targetFat = dailyTarget?.fat ?? 70.0;

          final draftPortionId = state.draftPortionId;

          final isCurrent100g =
              entry != null &&
              entry.portion.name.trim().toLowerCase() == '100g';

          final currentPortionLabel = entry != null
              ? (isCurrent100g
                    ? '${entry.portion.totalWeight.toInt()} g'
                    : '${entry.portion.quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} x ${entry.portion.name} (${entry.portion.totalWeight.toInt()} g)')
              : '';

          final sortedPortions =
              List<ProductPortionResponse>.from(product.portions)..sort((a, b) {
                final isA100g = a.name.trim().toLowerCase() == '100g';
                final isB100g = b.name.trim().toLowerCase() == '100g';
                if (isA100g && !isB100g) return 1;
                if (!isA100g && isB100g) return -1;
                return 0;
              });

          final durationText = currentInsulin != null
              ? getInsulinDurationText(currentInsulin, profile)
              : '';
          final isPen = profile?.insulinDeliveryMethod == 'PEN';
          final showDurationRow =
              currentInsulin != null &&
              (currentInsulin.bolusDurationMinutes > 0 ||
                  (isPen && currentInsulin.fatProteinDose > 0));

          final currentDateTime = state.selectedDateTime;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Material(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () async {
                                await context.push(
                                  '/product-edit',
                                  extra: product,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        product.name,
                                        style: textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              height: 1.1,
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit_rounded,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (product.provider?.toUpperCase() != 'LOCAL') ...[
                          const SizedBox(width: 12),
                          Tooltip(
                            message: l10n.externalDatabaseTooltip,
                            child: Icon(
                              Icons.public,
                              size: 24,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product.brand != null && product.brand!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          product.brand!,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: currentDateTime,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                final newDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  currentDateTime.hour,
                                  currentDateTime.minute,
                                );
                                await ref
                                    .read(
                                      mealEntryDetailControllerProvider(
                                        widget.entryId,
                                        isCreation: widget.isCreation,
                                        categoryId: widget.categoryId,
                                      ).notifier,
                                    )
                                    .updateDateTime(newDateTime);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      DateFormat.yMMMd(l10n.localeName)
                                          .format(currentDateTime),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  currentDateTime,
                                ),
                              );
                              if (time != null) {
                                final newDateTime = DateTime(
                                  currentDateTime.year,
                                  currentDateTime.month,
                                  currentDateTime.day,
                                  time.hour,
                                  time.minute,
                                );
                                await ref
                                    .read(
                                      mealEntryDetailControllerProvider(
                                        widget.entryId,
                                        isCreation: widget.isCreation,
                                        categoryId: widget.categoryId,
                                      ).notifier,
                                    )
                                    .updateDateTime(newDateTime);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      DateFormat.Hm().format(currentDateTime),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.editPortionTitle,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.isCalculating)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: sortedPortions.asMap().entries.map((
                          mapEntry,
                        ) {
                          final index = mapEntry.key;
                          final portion = mapEntry.value;
                          final isLast = index == sortedPortions.length - 1;
                          final isSelected = portion.id == draftPortionId;

                          return Column(
                            key: ValueKey('col_${portion.id}'),
                            children: [
                              _PortionRow(
                                key: ValueKey(portion.id),
                                portion: portion,
                                product: product,
                                isSelected: isSelected,
                                categoryId: widget.categoryId,
                                entryId: widget.entryId,
                                isCreation: widget.isCreation,
                                currentDraftQty: state.draftQuantity,
                              ),
                              if (!isLast) const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${l10n.mealDetailsCalculationsInfo}\n$currentPortionLabel',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (currentInsulin != null && currentInsulin.totalDose > 0)
                      Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => showInsulinDetailsModal(
                            context,
                            currentInsulin,
                            profile,
                            l10n,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.bolt,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.insulinDoseTitle,
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.insulinTotalDose,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${currentInsulin.totalDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  height: 1,
                                ),
                                const SizedBox(height: 16),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: _buildInsulinColumn(
                                          context: context,
                                          title: l10n.insulinCarbDose,
                                          doseVal: currentInsulin.carbDose,
                                          unit: currentInsulin.carbUnit,
                                          unitLabel: l10n.unitCarbExchange,
                                          l10n: l10n,
                                        ),
                                      ),
                                      VerticalDivider(
                                        width: 1,
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInsulinColumn(
                                          context: context,
                                          title: l10n.insulinFatProteinDose,
                                          doseVal:
                                              currentInsulin.fatProteinDose,
                                          unit: currentInsulin.fatProteinUnit,
                                          unitLabel:
                                              l10n.unitFatProteinExchange,
                                          durationText: showDurationRow
                                              ? durationText
                                              : null,
                                          l10n: l10n,
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
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.dailyMacroShareTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildCircularMacroShare(
                                  context,
                                  label: l10n.macroCarbohydratesFull,
                                  current: nutrition.carbohydrates,
                                  target: targetCarbs,
                                  color: colorScheme.primary,
                                ),
                                _buildCircularMacroShare(
                                  context,
                                  label: l10n.macroProteinFull,
                                  current: nutrition.protein,
                                  target: targetProtein,
                                  color: colorScheme.error,
                                ),
                                _buildCircularMacroShare(
                                  context,
                                  label: l10n.macroFatFull,
                                  current: nutrition.fat,
                                  target: targetFat,
                                  color: colorScheme.tertiary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.nutritionDetailsTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            _buildDataRow(
                              context,
                              l10n.macroEnergy,
                              '${nutrition.energyKcal.toStringAsFixed(1)} kcal',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroCarbohydratesFull,
                              '${nutrition.carbohydrates.toStringAsFixed(1)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroSugars,
                              '${nutrition.sugars.toStringAsFixed(1)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroFatFull,
                              '${nutrition.fat.toStringAsFixed(1)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroSaturatedFat,
                              '${nutrition.saturatedFat.toStringAsFixed(1)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroProteinFull,
                              '${nutrition.protein.toStringAsFixed(1)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroFiber,
                              '${nutrition.fiber.toStringAsFixed(1)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroSalt,
                              '${nutrition.salt.toStringAsFixed(2)} g',
                            ),
                            _buildDataRow(
                              context,
                              l10n.macroGlycemicIndex,
                              (product.nutrition.glycemicIndex > 0)
                                  ? product.nutrition.glycemicIndex
                                        .toStringAsFixed(0)
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsulinColumn({
    required BuildContext context,
    required String title,
    required double doseVal,
    required double unit,
    required String unitLabel,
    required AppLocalizations l10n,
    String? durationText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Text(
          title,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '${doseVal.toStringAsFixed(2)} ${l10n.unitInsulin}',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          '${unit.toStringAsFixed(1)} $unitLabel',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (durationText != null && durationText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              durationText,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCircularMacroShare(
    BuildContext context, {
    required String label,
    required double current,
    required double target,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final rawPercentage = target > 0 ? (current / target) : 0.0;
    final progress = rawPercentage.clamp(0.0, 1.0);
    final percentVal = (rawPercentage * 100).toInt();
    final isExceeded = rawPercentage > 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Text(
                  '$percentVal%',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExceeded
                        ? colorScheme.error
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${current.toStringAsFixed(1)}g',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _PortionRow extends ConsumerStatefulWidget {
  const _PortionRow({
    required this.portion,
    required this.product,
    required this.isSelected,
    required this.categoryId,
    required this.entryId,
    required this.isCreation,
    required this.currentDraftQty,
    super.key,
  });

  final ProductPortionResponse portion;
  final ProductResponse product;
  final bool isSelected;
  final String categoryId;
  final String entryId;
  final bool isCreation;
  final double currentDraftQty;

  @override
  ConsumerState<_PortionRow> createState() => _PortionRowState();
}

class _PortionRowState extends ConsumerState<_PortionRow> {
  late final TextEditingController _controller;
  bool _is100g = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _is100g = widget.portion.name.trim().toLowerCase() == '100g';

    var initialValue = 1.0;
    if (widget.isSelected) {
      if (_is100g) {
        initialValue = widget.currentDraftQty * widget.portion.weightInGrams;
      } else {
        initialValue = widget.currentDraftQty;
      }
    } else if (_is100g) {
      initialValue = 100.0;
    }

    _controller = TextEditingController(
      text: initialValue.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _triggerDraftUpdate(double quantity) {
    unawaited(
      ref
          .read(
            mealEntryDetailControllerProvider(
              widget.entryId,
              isCreation: widget.isCreation,
              categoryId: widget.categoryId,
            ).notifier,
          )
          .updateDraft(quantity, widget.portion.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final parsedInput =
        double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0.0;
    final displayQty = _is100g ? (parsedInput / 100.0) : parsedInput;
    final totalWeight = widget.portion.weightInGrams * displayQty;

    final totalKcal =
        (widget.product.nutrition.energyKcal / 100.0) * totalWeight;

    return Container(
      decoration: widget.isSelected
          ? BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.2),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
              ],
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.2,
                ),
              ),
              onChanged: (val) {
                final currentParsed =
                    double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                final currentQty = _is100g
                    ? (currentParsed / 100.0)
                    : currentParsed;

                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  if (currentQty > 0) {
                    _triggerDraftUpdate(currentQty);
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _is100g ? 'g' : 'x  ${widget.portion.name}',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: widget.isSelected ? colorScheme.primary : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _is100g
                      ? '${totalKcal.toInt()} kcal'
                      : '${totalWeight.toInt()} g  •  ${totalKcal.toInt()} kcal',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isSelected)
            IconButton.filled(
              icon: const Icon(Icons.check, size: 18),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (displayQty > 0) {
                  _triggerDraftUpdate(displayQty);
                }
              },
            )
          else
            IconButton.outlined(
              icon: const Icon(Icons.check, size: 18),
              color: colorScheme.primary,
              style: IconButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (displayQty > 0) {
                  _triggerDraftUpdate(displayQty);
                }
              },
            ),
        ],
      ),
    );
  }
}
