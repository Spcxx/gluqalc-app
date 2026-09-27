import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_entry_detail_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/product_edit_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/product_portions_controller.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/macro_table_form_widget.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({required this.product, super.key});
  final ProductResponse product;

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  late ProductResponse _currentProduct;
  bool _isPortionsEditable = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _kcalCtrl;
  late final TextEditingController _carbsCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _giCtrl;
  late final TextEditingController _sugarsCtrl;
  late final TextEditingController _satFatCtrl;
  late final TextEditingController _fiberCtrl;
  late final TextEditingController _saltCtrl;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _initControllers();
  }

  void _initControllers() {
    final n = _currentProduct.nutrition;
    _nameCtrl = TextEditingController(text: _currentProduct.name);
    _brandCtrl = TextEditingController(text: _currentProduct.brand ?? '');

    _kcalCtrl = TextEditingController(text: _formatNum(n.energyKcal));
    _carbsCtrl = TextEditingController(text: _formatNum(n.carbohydrates));
    _proteinCtrl = TextEditingController(text: _formatNum(n.protein));
    _fatCtrl = TextEditingController(text: _formatNum(n.fat));
    _giCtrl = TextEditingController(
      text: n.glycemicIndex > 0 ? n.glycemicIndex.toStringAsFixed(0) : '',
    );

    _sugarsCtrl = TextEditingController(text: _formatNum(n.sugars));
    _satFatCtrl = TextEditingController(text: _formatNum(n.saturatedFat));
    _fiberCtrl = TextEditingController(text: _formatNum(n.fiber));
    _saltCtrl = TextEditingController(text: _formatNum(n.salt));
  }

  String _formatNum(double val) {
    if (val == 0) return '';
    return val.toStringAsFixed(2).replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _kcalCtrl.dispose();
    _carbsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _giCtrl.dispose();
    _sugarsCtrl.dispose();
    _satFatCtrl.dispose();
    _fiberCtrl.dispose();
    _saltCtrl.dispose();
    super.dispose();
  }

  double? _parse(String text) {
    if (text.trim().isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  Future<void> _showPortionDialog({
    ProductPortionResponse? portionToEdit,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final nameController = TextEditingController(
      text: portionToEdit?.name ?? '',
    );
    final weightController = TextEditingController(
      text: portionToEdit != null
          ? _formatNum(portionToEdit.weightInGrams)
          : '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          portionToEdit == null ? l10n.addPortionTitle : l10n.editPortionTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: l10n.portionNameLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.errorFieldRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  style: textTheme.bodyMedium,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.portionWeightGramsLabel,
                    suffixText: 'g',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.errorFieldRequired;
                    }
                    final weight = double.tryParse(v.replaceAll(',', '.'));
                    if (weight == null || weight <= 0) {
                      return l10n.errorInvalidNumber;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameController.text.trim();
              final weight = double.parse(
                weightController.text.replaceAll(',', '.'),
              );

              Navigator.pop(context);

              final messenger = ScaffoldMessenger.of(context);

              ProductResponse? updated;
              if (portionToEdit == null) {
                updated = await ref
                    .read(productPortionsControllerProvider.notifier)
                    .addPortion(
                      productId: _currentProduct.id,
                      name: name,
                      weightInGrams: weight,
                    );
              } else {
                updated = await ref
                    .read(productPortionsControllerProvider.notifier)
                    .updatePortion(
                      portionId: portionToEdit.id,
                      productId: _currentProduct.id,
                      name: name,
                      weightInGrams: weight,
                    );
              }

              if (updated == null || !mounted) return;

              setState(() => _currentProduct = updated!);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.productEditSuccess),
                  backgroundColor: colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePortion(String portionId, AppLocalizations l10n) async {
    final colorScheme = Theme.of(context).colorScheme;

    final success = await ref
        .read(productPortionsControllerProvider.notifier)
        .deletePortion(portionId);

    if (success && mounted) {
      setState(() {
        _currentProduct = _currentProduct.copyWith(
          portions: _currentProduct.portions
              .where((p) => p.id != portionId)
              .toList(),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.portionDeletedSuccess),
          backgroundColor: colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorConflict),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final colorScheme = Theme.of(context).colorScheme;

    if (_nameCtrl.text.trim().isEmpty ||
        _kcalCtrl.text.trim().isEmpty ||
        _carbsCtrl.text.trim().isEmpty ||
        _proteinCtrl.text.trim().isEmpty ||
        _fatCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productEditValidationRequired),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final parsedKcal = _parse(_kcalCtrl.text) ?? 0.0;
    final parsedCarbs = _parse(_carbsCtrl.text) ?? 0.0;
    final parsedProtein = _parse(_proteinCtrl.text) ?? 0.0;
    final parsedFat = _parse(_fatCtrl.text) ?? 0.0;

    final calculatedKcal =
        (parsedCarbs * 4.0) + (parsedProtein * 4.0) + (parsedFat * 9.0);
    final difference = (parsedKcal - calculatedKcal).abs();
    final allowedTolerance = 30.0 + (calculatedKcal * 0.15);

    if (difference > allowedTolerance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.productEditValidationCaloricMismatch(
              parsedKcal.toStringAsFixed(0),
              calculatedKcal.toStringAsFixed(0),
            ),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final updatedFields = <String, dynamic>{};
    final p = _currentProduct;
    final n = p.nutrition;

    final newName = _nameCtrl.text.trim();
    if (newName != p.name) updatedFields['name'] = newName;

    final newBrand = _brandCtrl.text.trim();
    final originalBrand = p.brand ?? '';
    if (newBrand != originalBrand) {
      updatedFields['brand'] = newBrand.isEmpty ? null : newBrand;
    }

    if (parsedKcal != n.energyKcal) updatedFields['energyKcal'] = parsedKcal;
    if (parsedCarbs != n.carbohydrates) {
      updatedFields['carbohydrates'] = parsedCarbs;
    }
    if (parsedProtein != n.protein) updatedFields['protein'] = parsedProtein;
    if (parsedFat != n.fat) updatedFields['fat'] = parsedFat;

    final giText = _giCtrl.text.trim();
    final newGi = giText.isEmpty ? 0 : (int.tryParse(giText) ?? 0);
    if (newGi != n.glycemicIndex) {
      updatedFields['glycemicIndex'] = newGi == 0 ? null : newGi;
    }

    final newSugars = _parse(_sugarsCtrl.text);
    if (newSugars != n.sugars) updatedFields['sugars'] = newSugars;

    final newSatFat = _parse(_satFatCtrl.text);
    if (newSatFat != n.saturatedFat) updatedFields['saturatedFat'] = newSatFat;

    final newFiber = _parse(_fiberCtrl.text);
    if (newFiber != n.fiber) updatedFields['fiber'] = newFiber;

    final newSalt = _parse(_saltCtrl.text);
    if (newSalt != n.salt) updatedFields['salt'] = newSalt;

    final success = await ref
        .read(productEditControllerProvider.notifier)
        .updateProduct(
          productId: _currentProduct.id,
          updatedFields: updatedFields,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productEditSuccess),
          backgroundColor: colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      ref.invalidate(mealEntryDetailControllerProvider);
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productEditError),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final isProductLoading = ref.watch(productEditControllerProvider).isLoading;
    final isPortionsLoading = ref
        .watch(productPortionsControllerProvider)
        .isLoading;
    final isLoading = isProductLoading || isPortionsLoading;

    final customPortions = _currentProduct.portions.where((p) {
      final nameLower = p.name.trim().toLowerCase();
      return nameLower != '100g' && nameLower != '100 g';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.productEditTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.productEditSectionIdentification,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.productEditNameLabel,
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _brandCtrl,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.productEditBrandLabel,
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.portionsTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(
                        () => _isPortionsEditable = !_isPortionsEditable,
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        _isPortionsEditable
                            ? Icons.lock_open
                            : Icons.lock_outline,
                        size: 16,
                      ),
                      label: Text(
                        _isPortionsEditable
                            ? l10n.lockButton
                            : l10n.unlockButton,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Opacity(
                    opacity: _isPortionsEditable ? 1.0 : 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (customPortions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                l10n.noCustomProducts,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ...customPortions.asMap().entries.map((mapEntry) {
                              final index = mapEntry.key;
                              final portion = mapEntry.value;
                              final isLast = index == customPortions.length - 1;

                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      portion.name,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${portion.weightInGrams} g',
                                      style: textTheme.bodyMedium,
                                    ),
                                    trailing: _isPortionsEditable
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _showPortionDialog(
                                                      portionToEdit: portion,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: colorScheme.error,
                                                ),
                                                onPressed: () => _deletePortion(
                                                  portion.id,
                                                  l10n,
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                  if (!isLast) const Divider(height: 1),
                                ],
                              );
                            }),
                          if (_isPortionsEditable) ...[
                            if (customPortions.isNotEmpty)
                              const Divider(height: 24),
                            OutlinedButton.icon(
                              onPressed: _showPortionDialog,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addPortionButton),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.productEditMainMacrosTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                MacroTableFormWidget(
                  kcalCtrl: _kcalCtrl,
                  giCtrl: _giCtrl,
                  fatCtrl: _fatCtrl,
                  satFatCtrl: _satFatCtrl,
                  carbsCtrl: _carbsCtrl,
                  sugarsCtrl: _sugarsCtrl,
                  fiberCtrl: _fiberCtrl,
                  proteinCtrl: _proteinCtrl,
                  saltCtrl: _saltCtrl,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: isLoading ? null : () => _submit(l10n),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(
              isLoading ? l10n.saving : l10n.productEditSaveChanges,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
