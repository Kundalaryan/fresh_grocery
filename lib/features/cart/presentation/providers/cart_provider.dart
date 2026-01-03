import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../models/cart_item_model.dart';
import '../../../home/models/product_model.dart';

// 1. THE STATE NOTIFIER (The Logic)
class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]); // Start with empty list

  // ACTION: Add Product from Home Screen
  void addToCart(ProductModel product) {
    // Check if item already exists
    final index = state.indexWhere((item) => item.productId == product.id);

    if (index >= 0) {
      // If exists, just increase quantity
      // We must create a NEW list to trigger UI update (Immutability)
      List<CartItemModel> oldItems = [...state];
      CartItemModel oldItem = oldItems[index];

      oldItems[index] = CartItemModel(
        productId: oldItem.productId,
        name: oldItem.name,
        imageUrl: oldItem.imageUrl,
        price: oldItem.price,
        quantity: oldItem.quantity + 1,
      );
      state = oldItems;
    } else {
      // If new, add to list
      state = [
        ...state,
        CartItemModel(
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
          quantity: 1,
        ),
      ];
    }
  }

  // ACTION: Update Quantity (+ or - in Cart)
  void updateQuantity(int productId, int change) {
    state = [
      for (final item in state)
        if (item.productId == productId)
          CartItemModel(
            productId: item.productId,
            name: item.name,
            imageUrl: item.imageUrl,
            price: item.price,
            quantity: item.quantity + change,
          )
        else
          item
    ];
    // Remove items with 0 quantity
    state = state.where((item) => item.quantity > 0).toList();
  }

  // ACTION: Clear Cart
  void clearCart() {
    state = [];
  }
}

// 2. THE PROVIDER ( The Access Point)
// This is what the UI will listen to.
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

// 3. HELPER PROVIDERS (derived state)
// Automatically calculates cart count for the badge
final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.length; // Or items.fold(0, (sum, item) => sum + item.quantity) for total units
});

// Automatically calculates total price
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
});