import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeletons.dart';
import '../../cart/models/cart_item_model.dart';
import '../data/home_repository.dart';
import '../models/product_model.dart';
import '../../cart/presentation/providers/cart_provider.dart';
// Note: We don't import other screens here anymore for Nav Bar

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final HomeRepository _repository = HomeRepository();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _deliveryAddress = "Loading...";
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    "All", "Essentials", "Pulses", "Dairy", "Vegetables", "Fruits",
    "Snacks & Drinks", "Beauty & Personal Care", "Household Essentials"
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final response = await _repository.getUserAddress();
    if (mounted) {
      setState(() {
        if (response.success && response.data != null && response.data!.isNotEmpty) {
          _deliveryAddress = response.data!;
        } else {
          _deliveryAddress = "No address set";
        }
      });
    }
  }

  Future<void> _fetchProducts({String? query}) async {
    setState(() => _isLoading = true);
    final response = await _repository.getProducts(
      category: _selectedCategory,
      search: query ?? _searchController.text,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _products = response.data!;
        }
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED SCAFFOLD BOTTOM NAV BAR
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Address & Search)
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Delivering to", style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                            Text(
                              _deliveryAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => _fetchProducts(query: val), // Simple search for now
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 22.sp),
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Categories
            SizedBox(
              height: 45.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final isSelected = _categories[index] == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(_categories[index]),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20.h),

            // 3. List
            Expanded(
              child: _isLoading
                  ? ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: 6,
                separatorBuilder: (_, __) => SizedBox(height: 0.h),
                itemBuilder: (_, __) => const SkeletonProductItem(),
              )
                  : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: _products.length,
                separatorBuilder: (_, __) => SizedBox(height: 20.h),
                itemBuilder: (context, index) => _buildProductCard(_products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- THE SMART PRODUCT CARD ---
  Widget _buildProductCard(ProductModel product) {
    final bool isAvailable = product.stock > 0 && product.active;

    // 1. CHECK CART STATE
    // We listen to the cart provider to find if this product is already added
    final cartItems = ref.watch(cartProvider);

    // Find item in cart matching this product ID
    final cartItem = cartItems.firstWhere(
          (item) => item.productId == product.id,
      orElse: () => CartItemModel(productId: -1, name: '', imageUrl: '', price: 0, unit: '', category: '', quantity: 0),
    );

    final int quantityInCart = cartItem.quantity;

    return Row(
      children: [
        // Image
        Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
        SizedBox(width: 16.w),

        // Text
        Expanded(
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${product.unit} • ${product.category}",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                ),
                SizedBox(height: 4.h),
                Text(
                  "\₹${product.price.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),

        // --- THE MAGIC BUTTON LOGIC ---
        if (!isAvailable)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.r)),
            child: Text("Sold Out", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          )
        else if (quantityInCart > 0)
        // 2. SHOW QUANTITY COUNTER ([- 2 +])
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary, // Blue background
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.white, size: 18.sp),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(product.id, -1);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 35.w),
                ),
                Text(
                  "$quantityInCart",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(product.id, 1);
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 35.w),
                ),
              ],
            ),
          )
        else
        // 3. SHOW DEFAULT ADD BUTTON
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: AppColors.primary, size: 24.sp),
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart(product);
                // Optional: No snackbar needed now because the button changes visually!
              },
            ),
          ),
      ],
    );
  }
}