import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/data/models/meal_category_model.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/day_summary_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/home_selected_date_controller.dart';
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
        title: stateAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Text(l10n.mealDetailsTitle),
          data: (state) {
            var formattedDateTime = '';
            if (!widget.isCreation && state.entry != null) {
              final dateParsed =
                  DateTime.tryParse(state.entry!.consumptionDate) ??
                  DateTime.now();
              final formattedDate = DateFormat.yMMMMd(l10n.localeName)
                  .format(dateParsed);

              final timeParts = state.entry!.consumptionTime.split(':');
              final formattedTime = timeParts.length >= 2
                  ? '${timeParts[0]}:${timeParts[1]}'
                  : state.entry!.consumptionTime;
              formattedDateTime = '$formattedDate, $formattedTime';
            } else {
              final selectedDate = ref.read(homeSelectedDateProvider);
              final formattedDate = DateFormat.yMMMMd(l10n.localeName)
                  .format(selectedDate);
              final formattedTime = DateFormat.Hm().format(DateTime.now());
              formattedDateTime = '$formattedDate, $formattedTime';
            }

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
          final entry = state.entry;

          final nutrition = entry?.nutrition ?? product.nutrition;

          final dailyTarget = summaryAsync.value?.target;
          final targetCarbs = dailyTarget?.carbohydrates ?? 250.0;
          final targetProtein = dailyTarget?.protein ?? 120.0;
          final targetFat = dailyTarget?.fat ?? 70.0;

          final defaultPortion = product.portions.isNotEmpty
              ? product.portions.first
              : null;

          final isCurrent100g = entry != null
              ? entry.portion.name.trim().toLowerCase() == '100g'
              : (defaultPortion?.name.trim().toLowerCase() == '100g');

          final currentPortionLabel = entry != null
              ? (isCurrent100g
                    ? '${entry.portion.totalWeight.toInt()} g'
                    : '${entry.portion.quantity.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} x ${entry.portion.name} (${entry.portion.totalWeight.toInt()} g)')
              : (defaultPortion != null
                    ? '1 x ${defaultPortion.name} (${defaultPortion.weightInGrams.toInt()} g)'
                    : '');

          final sortedPortions =
              List<ProductPortionResponse>.from(
                product.portions,
              )..sort((a, b) {
                final isA100g = a.name.trim().toLowerCase() == '100g';
                final isB100g = b.name.trim().toLowerCase() == '100g';
                if (isA100g && !isB100g) return 1;
                if (!isA100g && isB100g) return -1;
                return 0;
              });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                    Text(
                      l10n.editPortionTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                          final isSelected = entry != null
                              ? portion.id == entry.portion.id
                              : portion.id == defaultPortion?.id;

                          return Column(
                            children: [
                              _PortionRow(
                                portion: portion,
                                product: product,
                                currentEntry: entry,
                                isSelected: isSelected,
                                categoryId: widget.categoryId,
                                entryId: widget.entryId,
                                isCreation: widget.isCreation,
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
                    if (entry?.insulinDose != null &&
                        entry!.insulinDose!.totalDose > 0)
                      Card(
                        elevation: 1,
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => showInsulinDetailsModal(
                            context,
                            entry.insulinDose!,
                            profile,
                            l10n,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
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
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    '${entry.insulinDose!.totalDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.primary,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildInsulinSubDetail(
                                      l10n.insulinCarbs,
                                      '${entry.insulinDose!.carbDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
                                      colorScheme,
                                      textTheme,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    _buildInsulinSubDetail(
                                      l10n.insulinFatProtein,
                                      '${entry.insulinDose!.fatProteinDose.toStringAsFixed(2)} ${l10n.unitInsulin}',
                                      colorScheme,
                                      textTheme,
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                              nutrition.glycemicIndex.toStringAsFixed(0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

  Widget _buildInsulinSubDetail(
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
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
    required this.currentEntry,
    required this.isSelected,
    required this.categoryId,
    required this.entryId,
    required this.isCreation,
  });

  final ProductPortionResponse portion;
  final ProductResponse product;
  final MealEntryResponse? currentEntry;
  final bool isSelected;
  final String categoryId;
  final String entryId;
  final bool isCreation;

  @override
  ConsumerState<_PortionRow> createState() => _PortionRowState();
}

class _PortionRowState extends ConsumerState<_PortionRow> {
  late final TextEditingController _controller;
  bool _is100g = false;

  @override
  void initState() {
    super.initState();
    _is100g = widget.portion.name.trim().toLowerCase() == '100g';

    var initialValue = 1.0;
    if (widget.currentEntry != null &&
        widget.currentEntry!.portion.id == widget.portion.id) {
      if (_is100g) {
        initialValue =
            widget.currentEntry!.portion.quantity *
            widget.portion.weightInGrams;
      } else {
        initialValue = widget.currentEntry!.portion.quantity;
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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate(double quantity) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actualProductId = widget.isCreation
        ? widget.entryId
        : widget.currentEntry!.productId;

    final selectedDate = ref.read(homeSelectedDateProvider);

    final success = await ref
        .read(
          mealEntryDetailControllerProvider(
            widget.entryId,
            isCreation: widget.isCreation,
            categoryId: widget.categoryId,
          ).notifier,
        )
        .saveOrUpdateEntry(
          id: actualProductId,
          categoryId: widget.categoryId,
          quantity: quantity,
          date: widget.currentEntry != null
              ? DateTime.parse(widget.currentEntry!.consumptionDate)
              : selectedDate,
          portionId: widget.portion.id,
          isCreation: widget.isCreation,
          oldEntryId: widget.currentEntry?.id,
        );

    if (success && mounted) {
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
      context.pop();
    }
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

    final kcalPer100 = widget.product.nutrition.energyKcal;
    final totalKcal = (kcalPer100 / 100.0) * totalWeight;

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
              onChanged: (_) => setState(() {}),
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
                    if (widget.isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
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
          IconButton.filled(
            icon: const Icon(Icons.arrow_forward, size: 18),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (displayQty > 0) {
                await _submitUpdate(displayQty);
              }
            },
          ),
        ],
      ),
    );
  }
}
