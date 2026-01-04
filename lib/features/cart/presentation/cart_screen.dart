import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED
import 'package:grocery_fresh/features/cart/presentation/widgets/order_success_dialog.dart';

import '../../../core/constants/app_colors.dart';
import '../data/cart_repository.dart';
import '../models/cart_item_model.dart';

// Import Provider
import 'providers/cart_provider.dart';
import 'widgets/order_failed_dialog.dart';
import '../../orders/presentation/order_details_screen.dart';

// 1. Change State class to ConsumerStatefulWidget
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

// 2. Change State to ConsumerState
class _CartScreenState extends ConsumerState<CartScreen> {
  final CartRepository _repository = CartRepository();
  bool _isLoading = false;

  // NO LOCAL LIST VARIABLE. WE USE RIVERPOD.

  Future<void> _handleCheckout() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() => _isLoading = true);

    // Call API
    final response = await _repository.createOrder(cartItems);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success && response.data != null) {
      // 1. Clear Cart
      ref.read(cartProvider.notifier).clearCart();

      // 2. Get Order ID from response
      final int newOrderId = response.data!;

      // 3. Show Custom Dialog
      showDialog(
        context: context,
        barrierDismissible: false, // User must click a button to close
        builder: (ctx) => OrderSuccessDialog(
          orderId: newOrderId,
          onTrackOrder: () {
            Navigator.pop(ctx); // Close dialog
            // TODO: Navigate to Order Tracking Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(orderId: newOrderId),
              ),
            );
          },
          onContinueShopping: () {
            Navigator.pop(ctx); // Close dialog
            Navigator.of(context).popUntil((route) => route.isFirst); // Go back to Home Screen
          },
        ),
      );
    } else {
      // FAILURE LOGIC (Updated)

      // Instead of SnackBar, show the Failed Dialog
      showDialog(
        context: context,
        builder: (ctx) => OrderFailedDialog(
          // Pass the API message ("One or more products are not available")
          errorMessage: response.message,

          onTryAgain: () {
            Navigator.pop(ctx); // Close dialog so user can edit cart
          },

          onContinueShopping: () {
            Navigator.pop(ctx); // Close dialog
            // Go back to Home Screen (Clear stack)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE STATE (Real Data)
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final deliveryFee = 2.00;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Cart (${cartItems.length})",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear All Action
              ref.read(cartProvider.notifier).clearCart();
            },
            child: Text(
              "Clear All",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      // Handle Empty State
      body: cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : Column(
        children: [
          // 1. SCROLLABLE ITEM LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const Divider(height: 30, color: Color(0xFFF0F0F0)),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItem(item);
              },
            ),
          ),

          // 2. BOTTOM SECTION
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPriceRow("Subtotal", subtotal),
                  const SizedBox(height: 12),
                  _buildPriceRow("Delivery Fee", deliveryFee),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "including VAT",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Proceed to Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "\$${total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            image: item.imageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
                : null,
          ),
          child: item.imageUrl.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "1kg • Organic",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // QTY CONTROLS
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // MINUS
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: Colors.black,
                          onPressed: () {
                            ref.read(cartProvider.notifier).updateQuantity(item.productId, -1);
                          },
                        ),
                        // COUNT
                        Text(
                          "${item.quantity}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        // PLUS
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            color: Colors.white,
                            onPressed: () {
                              ref.read(cartProvider.notifier).updateQuantity(item.productId, 1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}