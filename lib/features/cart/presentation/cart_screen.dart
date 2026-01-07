import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../data/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../../orders/presentation/order_details_screen.dart';
import 'widgets/order_success_dialog.dart';
import 'widgets/order_failed_dialog.dart';
import 'providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final CartRepository _repository = CartRepository();
  bool _isLoading = false;

  Future<void> _handleCheckout() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() => _isLoading = true);

    final response = await _repository.createOrder(cartItems);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success && response.data != null) {
      ref.read(cartProvider.notifier).clearCart();
      final int newOrderId = response.data!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => OrderSuccessDialog(
          orderId: newOrderId,
          onTrackOrder: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(orderId: newOrderId),
              ),
            );
          },
          onContinueShopping: () {
            Navigator.pop(ctx);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => OrderFailedDialog(
          errorMessage: response.message,
          onTryAgain: () => Navigator.pop(ctx),
          onContinueShopping: () {
            Navigator.pop(ctx);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final total = subtotal;

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
            fontSize: 20.sp, // Changed from default
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
              child: Text(
                "Clear All",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 80.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 1. SCROLLABLE ITEM LIST
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 30.h, color: const Color(0xFFF0F0F0)),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),

                // 2. BOTTOM SECTION
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20.r,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPriceRow("Subtotal", subtotal),

                        SizedBox(height: 20.h),
                        const Divider(color: Color(0xFFE0E0E0), thickness: 1),
                        SizedBox(height: 20.h),

                        // TOTAL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹${total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "including Taxes",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // CHECKOUT BUTTON
                        // CHECKOUT BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // FIX: Wrap Text in Flexible to prevent overflow
                                      Flexible(
                                        child: Text(
                                          "Proceed to Checkout",
                                          maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis, // Adds "..." if screen is too small
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 10.w), // Safety gap

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              "₹${total.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 16.sp,
                                            ),
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
        // Image
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: item.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
        SizedBox(width: 16.w),

        // Details
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                "${item.unit} • ${item.category}",
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),

              // QTY CONTROLS
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 18.sp),
                          color: Colors.black,
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.productId, -1);
                          },
                        ),
                        Text(
                          "${item.quantity}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, size: 18.sp),
                            color: Colors.white,
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(item.productId, 1);
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
          style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
        ),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ],
    );
  }
}
