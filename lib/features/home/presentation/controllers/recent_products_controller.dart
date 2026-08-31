import 'package:gluqalc_app/features/home/data/models/product_response_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_products_controller.g.dart';

@Riverpod(keepAlive: true)
class RecentProductsController extends _$RecentProductsController {
  @override
  List<ProductResponse> build() {
    return [];
  }

  void addProduct(ProductResponse product) {
    if (product.id.isEmpty) return;

    final current = List<ProductResponse>.from(state)
      ..removeWhere((p) => p.id == product.id)
      ..insert(0, product);

    if (current.length > 15) {
      current.removeLast();
    }

    state = current;
  }

  void clearHistory() {
    state = [];
  }
}
