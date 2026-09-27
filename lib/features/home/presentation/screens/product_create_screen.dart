import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/product_create_controller.dart';
import 'package:gluqalc_app/features/home/presentation/widgets/macro_table_form_widget.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ProductCreateScreen extends ConsumerStatefulWidget {
  const ProductCreateScreen({
    required this.categoryId,
    this.barcode,
    super.key,
  });
  final String categoryId;
  final String? barcode;

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _giCtrl = TextEditingController();
  final _sugarsCtrl = TextEditingController();
  final _satFatCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _saltCtrl = TextEditingController();

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

  Future<void> _submit(AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

    final parsedSatFat = _parse(_satFatCtrl.text) ?? 0.0;
    final parsedSugars = _parse(_sugarsCtrl.text) ?? 0.0;

    if (parsedSatFat > parsedFat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productEditValidationSatFatExceedsFat),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (parsedSugars > parsedCarbs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productEditValidationSugarsExceedCarbs),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final productData = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'energyKcal': parsedKcal,
      'carbohydrates': parsedCarbs,
      'protein': parsedProtein,
      'fat': parsedFat,
    };

    if (widget.barcode != null && widget.barcode!.isNotEmpty) {
      productData['barcode'] = widget.barcode;
    }

    final brand = _brandCtrl.text.trim();
    if (brand.isNotEmpty) productData['brand'] = brand;

    final giText = _giCtrl.text.trim();
    if (giText.isNotEmpty) productData['glycemicIndex'] = int.tryParse(giText);

    final sugars = _parse(_sugarsCtrl.text);
    if (sugars != null) productData['sugars'] = sugars;

    final satFat = _parse(_satFatCtrl.text);
    if (satFat != null) productData['saturatedFat'] = satFat;

    final fiber = _parse(_fiberCtrl.text);
    if (fiber != null) productData['fiber'] = fiber;

    final salt = _parse(_saltCtrl.text);
    if (salt != null) productData['salt'] = salt;

    final createdProduct = await ref
        .read(productCreateControllerProvider.notifier)
        .createProduct(productData);

    if (createdProduct != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productCreateSuccess),
          backgroundColor: colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      context.replace(
        '/meal-entry-details/${createdProduct.id}?categoryId=${widget.categoryId}&isCreation=true',
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productCreateError),
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
    final isLoading = ref.watch(productCreateControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.productCreateTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  if (widget.barcode != null && widget.barcode!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    IgnorePointer(
                      child: TextFormField(
                        initialValue: widget.barcode,
                        readOnly: true,
                        enableInteractiveSelection: false,
                        canRequestFocus: false,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.barcodeLabel,
                          prefixIcon: Icon(
                            Icons.qr_code,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
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
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: SizedBox(
                      width: double.infinity,
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
                            : const Icon(Icons.add),
                        label: Text(
                          isLoading ? l10n.saving : l10n.productCreateButton,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
