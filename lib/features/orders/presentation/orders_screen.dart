import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeletons.dart';
import '../data/orders_repository.dart';
import '../models/order_model.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersRepository _repository = OrdersRepository();

  bool _isLoading = true;
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];

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
          _applyFilter();
        }
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredOrders = List.from(_allOrders);
      } else {
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
        // --- FIXED: REMOVED BACK BUTTON ---
        automaticallyImplyLeading: false,
        // ----------------------------------
        title: Text(
          "Order History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp, // Increased size slightly for main header
          ),
        ),
        // --- FIXED: REMOVED FILTER ACTION BUTTON ---
        actions: const [],
        // -------------------------------------------
      ),
      body: Column(
        children: [
          // 1. FILTER CHIPS
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => _onFilterSelected(filter),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10.h),

          // 2. ORDERS LIST
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await _fetchOrders();
              },
              child: _isLoading
                  ? ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 0.h),
                itemBuilder: (context, index) =>
                const SkeletonOrderItem(),
              )
                  : _filteredOrders.isEmpty
                  ? Center(
                child: Text(
                  "No orders found",
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              )
                  : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: _filteredOrders.length,
                separatorBuilder: (_, __) => SizedBox(height: 20.h),
                itemBuilder: (context, index) {
                  return _buildOrderCard(_filteredOrders[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
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
        statusColor = const Color(0xFFFF9800);
        statusBg = const Color(0xFFFFF3E0);
        statusIcon = Icons.local_shipping;
        btnText = "Track";
    }

    return GestureDetector(
      onTap: () async {
        final bool? shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.id),
          ),
        );

        if (shouldRefresh == true) {
          _fetchOrders();
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                image: const DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/150"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.grey,
              ),
            ),

            SizedBox(width: 12.w),

            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order.id}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${order.formattedDate} • FastGoods",
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 10.h),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14.sp, color: statusColor),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            order.uiStatus,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Price & Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${order.totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  btnText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}