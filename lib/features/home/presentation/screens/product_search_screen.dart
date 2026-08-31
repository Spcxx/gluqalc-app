import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:gluqalc_app/features/home/data/repositories/meal_category_repository.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/meal_category_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/product_search_controller.dart';
import 'package:gluqalc_app/features/home/presentation/controllers/recent_products_controller.dart';
import 'package:gluqalc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({required this.categoryId, super.key});
  final String categoryId;

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _executeSearch(AppLocalizations l10n) async {
    final query = _searchController.text.trim();
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchQueryTooShortError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await ref
        .read(productSearchControllerProvider.notifier)
        .searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final searchState = ref.watch(productSearchControllerProvider);
    final searchNotifier = ref.read(productSearchControllerProvider.notifier);
    final recentProducts = ref.watch(recentProductsControllerProvider);

    var categoryName = '';
    final categoriesAsync = ref.watch(mealCategoryControllerProvider);
    if (categoriesAsync.hasValue) {
      try {
        final category = categoriesAsync.value!.firstWhere(
          (cat) => cat.id == widget.categoryId,
        );
        categoryName = category.name;
      } on Object catch (_) {}
    }

    final formattedDate = DateFormat.yMMMMd(l10n.localeName)
        .format(DateTime.now());
    final formattedTime = DateFormat.Hm().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$formattedDate, $formattedTime',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.tabSearch),
              Tab(text: l10n.tabCustom),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.addMeal,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: l10n.searchProductsHint,
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                if (val.trim().isEmpty) {
                                  searchNotifier.clearSearch();
                                }
                              },
                              onSubmitted: (_) => _executeSearch(l10n),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => _executeSearch(l10n),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: searchState.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(
                            child: Text(l10n.errorUnknown(err.toString())),
                          ),
                          data: (products) {
                            if (_searchController.text.trim().isEmpty) {
                              if (recentProducts.isEmpty) {
                                return Center(
                                  child: Text(
                                    l10n.noRecentProducts,
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ListView(
                                children: [
                                  Text(
                                    l10n.recentProductsTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...recentProducts.map(
                                    (p) => _buildProductTile(
                                      context,
                                      ref,
                                      p,
                                      l10n,
                                    ),
                                  ),
                                ],
                              );
                            }

                            if (products.isEmpty) {
                              return Center(child: Text(l10n.noProductsFound));
                            }

                            return ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return _buildProductTile(
                                  context,
                                  ref,
                                  products[index],
                                  l10n,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addNewProductButton),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: FutureBuilder<List<ProductResponse>>(
                          future: searchNotifier.getMyProducts(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  l10n.errorUnknown(snapshot.error.toString()),
                                ),
                              );
                            }
                            final myProducts = snapshot.data ?? [];
                            if (myProducts.isEmpty) {
                              return Center(child: Text(l10n.noCustomProducts));
                            }

                            return ListView.builder(
                              itemCount: myProducts.length,
                              itemBuilder: (context, index) {
                                return _buildProductTile(
                                  context,
                                  ref,
                                  myProducts[index],
                                  l10n,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    WidgetRef ref,
    ProductResponse product,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExternal = product.provider?.toUpperCase() != 'LOCAL';

    final carbs = product.nutrition.carbohydrates.toStringAsFixed(1);
    final protein = product.nutrition.protein.toStringAsFixed(1);
    final fat = product.nutrition.fat.toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Row(
          children: [
            Flexible(
              child: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExternal) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: l10n.externalDatabaseTooltip,
                child: Icon(
                  Icons.public,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ],
        ),
        subtitle: product.brand != null && product.brand!.isNotEmpty
            ? Text(product.brand!)
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.nutrition.energyKcal.toInt()} kcal / 100g',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${l10n.unitCarbShort}:${carbs}g • ${l10n.unitProteinShort}:${protein}g • ${l10n.unitFatShort}:${fat}g',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () async {
          var productToCache = product;
          String? targetProductId = product.id;
          final isLocal = product.provider?.toUpperCase() == 'LOCAL';

          if (!isLocal &&
              product.barcode != null &&
              product.barcode!.isNotEmpty) {
            unawaited(
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );

            try {
              final repository = ref.read(mealCategoryRepositoryProvider);
              final imported = await repository.importExternalProduct(
                product.barcode!,
              );

              if (imported.id.isEmpty) {
                throw Exception('Imported product has empty ID');
              }

              targetProductId = imported.id;
              productToCache = imported;
            } on Object catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.productImportError),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              return;
            } finally {
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            }
          }

          if (targetProductId.isEmpty) {
            return;
          }

          ref
              .read(recentProductsControllerProvider.notifier)
              .addProduct(productToCache);

          if (context.mounted) {
            await context.push(
              '/meal-entry-details/$targetProductId?categoryId=${widget.categoryId}&isCreation=true',
            );
          }
        },
      ),
    );
  }
}
