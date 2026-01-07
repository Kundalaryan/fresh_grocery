import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT ADDED
import 'package:grocery_fresh/features/home/presentation/widget/product_detail_sheet.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeletons.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/home_repository.dart';
import '../models/product_model.dart';

import '../../cart/presentation/providers/cart_provider.dart';
import '../../cart/presentation/cart_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final HomeRepository _repository = HomeRepository();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Address State
  String _deliveryAddress = "Loading...";

  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    "All",
    "Essentials",
    "Pulses",
    "Dairy",
    "Vegetables",
    "Fruits",
    "Snacks & Drinks",
    "Beauty & Personal Care",
    "Household Essentials",
    "Pooja Essentials",
    "Premium",
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchAddress();
  }

  // 1. Fetch Address (GET Only)
  Future<void> _fetchAddress() async {
    final response = await _repository.getUserAddress();
    if (mounted) {
      setState(() {
        if (response.success &&
            response.data != null &&
            response.data!.isNotEmpty) {
          _deliveryAddress = response.data!;
        } else {
          _deliveryAddress = "No address set";
        }
      });
    }
  }

  Future<void> _fetchProducts({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await _repository.getProducts(
      category: _selectedCategory,
      search: query ?? _searchController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _products = response.data!;
        } else {
          _errorMessage = response.message;
        }
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchProducts();
  }

  void _onSearchChanged(String value) {
    _fetchProducts(query: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. FIXED HEADER SECTION (Location & Search) ---
            Padding(
              // Adaptive Padding
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- READ-ONLY LOCATION ROW ---
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r), // Adaptive
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20.sp, // Adaptive Icon
                        ),
                      ),
                      SizedBox(width: 12.w), // Adaptive Spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivering to",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.sp, // Adaptive Font
                              ),
                            ),
                            Text(
                              _deliveryAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp, // Adaptive Font
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: "Search milk, bread, veggies...",
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 22.sp,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r), // Adaptive Radius
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h), // Adaptive Height
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. FIXED CATEGORY CHIPS ---
            SizedBox(
              height: 45.h, // Adaptive Height
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Text(
                        category,
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

            // --- 3. FIXED TITLE ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular Near You",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // --- 4. SCROLLABLE LIST SECTION ---
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await Future.wait([_fetchProducts(), _fetchAddress()]);
                },
                child: _isLoading
                    ? ListView.separated(
                  padding: EdgeInsets.all(20.r),
                  itemCount: 6,
                  separatorBuilder: (_, __) => SizedBox(height: 0.h),
                  itemBuilder: (context, index) =>
                  const SkeletonProductItem(),
                )
                    : _products.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 60.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "No products found",
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding: EdgeInsets.all(20.r),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    return _buildProductCard(_products[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Consumer(
              builder: (context, ref, child) {
                final count = ref.watch(cartCountProvider);
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "Orders",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final bool isAvailable = product.stock > 0 && product.active;

    return Container(
      // Optional: Add a transparent color to ensure the whole row captures clicks
      color: Colors.transparent,
      child: Row(
        children: [
          // --- CLICKABLE AREA STARTS ---
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Show the Bottom Sheet
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // Important for dynamic height
                  backgroundColor: Colors.transparent,
                  builder: (context) => ProductDetailSheet(product: product),
                );
              },
              child: Row(
                children: [
                  // IMAGE SECTION
                  Opacity(
                    opacity: isAvailable ? 1.0 : 0.5,
                    child: Hero(
                      tag: 'product_img_${product.id}', // UNIQUE TAG for Animation
                      child: product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16.r),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Center(
                              child: Icon(Icons.image, color: Colors.grey)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      )
                          : Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // TEXT DETAILS
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
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "${product.unit} • ${product.category}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[500]),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "\₹${product.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
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
          // --- CLICKABLE AREA ENDS ---

          SizedBox(width: 12.w), // Spacing before button

          // ACTION BUTTON (Not part of GestureDetector so it works independently)
          if (isAvailable)
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
                  // HAPTIC FEEDBACK HERE TOO
                  HapticFeedback.lightImpact();

                  ref.read(cartProvider.notifier).addToCart(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${product.name} added to cart"),
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Sold Out",
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}