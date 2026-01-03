import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/orders_repository.dart';
import '../models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersRepository _repository = OrdersRepository();

  bool _isLoading = true;
  List<OrderModel> _allOrders = []; // Stores everything from API
  List<OrderModel> _filteredOrders = []; // Stores what is visible

  // Filter State
  String _selectedFilter = 'All';
  final List<String> _filters = ["All", "Delivered", "Processing", "Cancelled"];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    final response = await _repository.getMyOrders();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _allOrders = response.data!;
          // Sort by newest first (optional)
          // _allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _applyFilter(); // Initial filter
        }
      });
    }
  }

  // Client-side filtering logic
  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredOrders = List.from(_allOrders);
      } else {
        // Map UI filter names to API status keys if needed,
        // or just match based on our helper logic.
        // Logic: Check if the UI Status contains the filter word
        _filteredOrders = _allOrders.where((order) {
          return order.uiStatus == _selectedFilter;
        }).toList();
      }
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Order History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Optional: Show advanced filter
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. FILTER CHIPS
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => _onFilterSelected(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 2. ORDERS LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? Center(
              child: Text("No orders found", style: TextStyle(color: Colors.grey)),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return _buildOrderCard(_filteredOrders[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Determine colors based on status
    Color statusColor;
    Color statusBg;
    IconData statusIcon;
    String btnText;

    switch (order.status) {
      case 'DELIVERED':
        statusColor = const Color(0xFF2962FF);
        statusBg = const Color(0xFFE3F2FD);
        statusIcon = Icons.check_circle;
        btnText = "Reorder";
        break;
      case 'CANCELLED':
        statusColor = Colors.grey;
        statusBg = Colors.grey.shade200;
        statusIcon = Icons.cancel;
        btnText = "Reorder";
        break;
      default: // ORDER_PLACED / Processing
        statusColor = const Color(0xFFFF9800); // Orange
        statusBg = const Color(0xFFFFF3E0);
        statusIcon = Icons.local_shipping;
        btnText = "Track";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGE PLACEHOLDER (Since API doesn't give image, we use generic icon)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                // You can add a placeholder asset here
                image: NetworkImage("https://via.placeholder.com/150"),
                fit: BoxFit.cover,
              ),
            ),
            // Fallback icon if no image
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),

          const SizedBox(width: 16),

          // 2. ORDER DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Title (Using ID since API lacks store name)
                Text(
                  "Order #${order.id}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Date & Items (API lacks item count, so we show just Date)
                Text(
                  "${order.formattedDate} • FastGoods",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 10),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        order.uiStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. PRICE & ACTION
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${order.totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Handle Reorder/Track logic
                },
                child: Text(
                  btnText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}