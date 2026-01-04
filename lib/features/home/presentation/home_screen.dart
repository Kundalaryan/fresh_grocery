import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
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

  // State variable for Address
  String _deliveryAddress = "Loading...";

  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    "All",
    "Essentials",
    "Pulses",
    "Dairy",
    "Vegetables",
    "Fruits"
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchAddress(); // Fetch address on startup
  }

  // 1. Fetch Address API
  Future<void> _fetchAddress() async {
    final response = await _repository.getUserAddress();
    if (mounted) {
      setState(() {
        if (response.success && response.data != null && response.data!.isNotEmpty) {
          _deliveryAddress = response.data!;
        } else {
          _deliveryAddress = "Select Delivery Location";
        }
      });
    }
  }

  // 2. Show Address Update Dialog
  void _showAddressDialog() {
    final textValue = _deliveryAddress == "Select Delivery Location" || _deliveryAddress == "Loading..."
        ? ""
        : _deliveryAddress;

    final TextEditingController addressController = TextEditingController(text: textValue);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Update Address", style: TextStyle(fontWeight: FontWeight.bold)),
              content: TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: "Enter full address",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                    if (addressController.text.trim().isEmpty) return;

                    setStateDialog(() => isUpdating = true);

                    final response = await _repository.updateAddress(addressController.text.trim());

                    if (context.mounted) {
                      Navigator.pop(context);

                      if (response.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Address updated!"),
                              backgroundColor: Colors.green
                          ),
                        );
                        // Refresh address on screen
                        _fetchAddress();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(response.message),
                              backgroundColor: Colors.red
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isUpdating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- MODIFIED LOCATION ROW ---
                  // Wrapped in GestureDetector to make it clickable
                  GestureDetector(
                    onTap: _showAddressDialog, // <--- Connects to the Dialog
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                              Icons.location_on, color: AppColors.primary,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        // Expanded ensures long addresses don't overflow
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivering to",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              // Display the DYNAMIC ADDRESS here
                              Text(
                                _deliveryAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dropdown indicator icon
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search milk, bread, veggies...",
                      hintStyle: TextStyle(
                          color: Colors.grey[500]),
                      prefixIcon: const Icon(
                          Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. FIXED CATEGORY CHIPS ---
            SizedBox(
              height: 45,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(
                            0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. FIXED TITLE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Popular Near You",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- 4. SCROLLABLE LIST SECTION ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("No products found",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildProductCard(_products[index]);
                },
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
        selectedLabelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
          }
          else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
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
              icon: Icon(Icons.receipt_long_outlined), label: "Orders"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final bool isAvailable = product.stock > 0 && product.active;

    return Row(
      children: [
        // IMAGE SECTION
        Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: product.imageUrl.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: product.imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Icon(Icons.image, color: Colors.grey)),
            ),
            errorWidget: (context, url, error) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          )
              : Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),

        const SizedBox(width: 16),

        // TEXT DETAILS
        Expanded(
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${product.unit} • ${product.category}",
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),

        // ACTION BUTTON
        if (isAvailable)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart(product);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product.name} added to cart"),
                    duration: const Duration(seconds: 1),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const CartScreen())),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Sold Out",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}