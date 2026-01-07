import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/cart_item_model.dart';
import '../../../home/models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  // ACTION: Add Product from Home Screen
  void addToCart(ProductModel product) {
    final index = state.indexWhere((item) => item.productId == product.id);

    if (index >= 0) {
      // If exists, update quantity but KEEP dynamic details
      List<CartItemModel> oldItems = [...state];
      CartItemModel oldItem = oldItems[index];

      oldItems[index] = CartItemModel(
        productId: oldItem.productId,
        name: oldItem.name,
        imageUrl: oldItem.imageUrl,
        price: oldItem.price,
        unit: oldItem.unit,         // Keep existing unit
        category: oldItem.category, // Keep existing category
        quantity: oldItem.quantity + 1,
      );
      state = oldItems;
    } else {
      // If new, add to list with dynamic unit/category from ProductModel
      state = [
        ...state,
        CartItemModel(
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
          unit: product.unit,         // <--- MAPPED HERE
          category: product.category, // <--- MAPPED HERE
          quantity: 1,
        ),
      ];
    }
  }

  void updateQuantity(int productId, int change) {
    state = [
      for (final item in state)
        if (item.productId == productId)
          CartItemModel(
            productId: item.productId,
            name: item.name,
            imageUrl: item.imageUrl,
            price: item.price,
            unit: item.unit,         // Preserve
            category: item.category, // Preserve
            quantity: item.quantity + change,
          )
        else
          item
    ];
    state = state.where((item) => item.quantity > 0).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.length;
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
});