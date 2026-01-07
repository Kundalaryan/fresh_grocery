import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Responsive

import '../../../../core/constants/app_colors.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../models/product_model.dart';

class ProductDetailSheet extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic to check availability
    final bool isAvailable = product.stock > 0 && product.active;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Hug content height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle (Visual Cue)
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 2. Large Image (With Hero Animation)
          Center(
            child: Hero(
              tag: 'product_img_${product.id}', // Must match the tag in HomeScreen
              child: Container(
                height: 200.h,
                width: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.grey[50], // Background while loading
                ),
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.contain, // Contain ensures full product is visible
                  placeholder: (context, url) => Center(
                    child: Icon(Icons.image, size: 50.sp, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.image_not_supported, size: 50.sp, color: Colors.grey),
                  ),
                )
                    : Icon(Icons.image_not_supported, size: 80.sp, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // 3. Name & Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                "₹${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 4. Unit & Category
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  product.unit,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "•  ${product.category}",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),
          Divider(color: const Color(0xFFF0F0F0), thickness: 1.h),
          SizedBox(height: 16.h),

          // 5. Description Title
          Text(
            "Description",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),

          // 6. Description Body
          Text(
            product.description.isNotEmpty
                ? product.description
                : "No description available for this product.",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5, // Better readability
            ),
          ),

          SizedBox(height: 30.h),

          // 7. Add to Cart Button (Full Width)
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: isAvailable
                  ? () {
                // --- HAPTIC FEEDBACK ---
                HapticFeedback.lightImpact();

                // Add to Cart Logic
                ref.read(cartProvider.notifier).addToCart(product);

                // Close Sheet
                Navigator.pop(context);

                // Show Feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product.name} added to cart"),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating, // Floats above bottom nav
                  ),
                );
              }
                  : null, // Disabled if stock is 0
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                isAvailable ? "Add to Cart" : "Sold Out",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h), // Safe area spacing
        ],
      ),
    );
  }
}