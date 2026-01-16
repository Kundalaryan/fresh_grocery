import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Responsive
import 'package:open_filex/open_filex.dart';

import '../../../core/constants/app_colors.dart';
import '../data/orders_repository.dart';
import '../models/order_details_model.dart';
import 'order_help_screen.dart';
import 'widgets/cancel_order_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrdersRepository _repository = OrdersRepository();
  bool _isLoading = true;
  String _errorMessage = '';
  OrderDetailsModel? _order;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final response = await _repository.getOrderDetails(widget.orderId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _order = response.data;
        } else {
          _errorMessage = response.message;
        }
      });
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool isCancelling = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return CancelOrderDialog(
              isCancelling: isCancelling,
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                setStateDialog(() => isCancelling = true);
                final response = await _repository.cancelOrder(widget.orderId);

                if (context.mounted) Navigator.pop(context);

                if (context.mounted) {
                  if (response.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.message),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      _hasChanges = true;
                    });

                    _fetchDetails();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: Text(
            "Order #${widget.orderId}",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          // --- ADDED HELP BUTTON ---
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to the new Full Screen Design
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderHelpScreen(orderId: widget.orderId),
                  ),
                );
              },
              child: Text(
                "Help",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w), // Right Padding
          ],
          // -------------------------
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _order == null
            ? const Center(child: Text("Order not found"))
            : SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. STATUS HEADER
                    Text(
                      _getMainStatusText(),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // 2. TIMELINE PROGRESS BAR
                    _buildTimelineWidget(),

                    SizedBox(height: 40.h),

                    // 3. ITEMS LIST HEADER
                    Text(
                      "Your Items",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 4. DYNAMIC ITEMS LIST
                    ..._order!.items.map((item) => _buildItemRow(item)),

                    SizedBox(height: 20.h),
                    Divider(thickness: 1, color: const Color(0xFFF0F0F0)),
                    SizedBox(height: 20.h),

                    // 5. BILLING SECTION
                    _buildPricingRow("Subtotal", _order!.subtotal),

                    SizedBox(height: 20.h),
                    Divider(thickness: 1, color: const Color(0xFFF0F0F0)),
                    SizedBox(height: 10.h),

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
                        Flexible(
                          child: Text(
                            "\₹${_order!.totalAmount.toStringAsFixed(2)}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                    // 6. ACTION BUTTONS
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          // 1. CHECK STATUS
                          bool isDelivered = _order!.status == 'DELIVERED';

                          // 2. IF NOT DELIVERED, SHOW MESSAGE & STOP
                          if (!isDelivered) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Receipt is available only after delivery.",
                                ),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return; // Stop execution
                          }

                          // 3. IF DELIVERED, PROCEED DOWNLOAD
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Downloading Receipt..."),
                            ),
                          );

                          final String? filePath = await _repository
                              .downloadReceipt(widget.orderId);

                          if (filePath != null) {
                            final result = await OpenFilex.open(filePath);
                            if (result.type != ResultType.done) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Could not open file: ${result.message}",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to download receipt"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          // 4. CHANGE COLOR BASED ON STATUS
                          backgroundColor: _order!.status == 'DELIVERED'
                              ? AppColors.primary
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "View Receipt",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Cancel Button
                    if (_order!.status != 'CANCELLED' &&
                        _order!.status != 'DELIVERED')
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: _showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEBEE),
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "Cancel Order",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  String _getMainStatusText() {
    switch (_order!.status) {
      case 'ORDER_PLACED':
        return "Preparing";
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return "On the way";
      case 'DELIVERED':
        return "Arrived";
      case 'CANCELLED':
        return "Cancelled";
      default:
        return "Processing";
    }
  }

  Widget _buildTimelineWidget() {
    double progress = 0.33;
    String status = _order!.status;

    if (status == 'SHIPPED' || status == 'OUT_FOR_DELIVERY') progress = 0.66;
    if (status == 'DELIVERED') progress = 1.0;
    if (status == 'CANCELLED') progress = 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "",
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.h,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(
              status == 'CANCELLED' ? Colors.red : AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimelineLabel("Preparing", progress >= 0.33),
            _buildTimelineLabel("On the way", progress >= 0.66),
            _buildTimelineLabel("Delivered", progress >= 1.0),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineLabel(String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        color: isActive
            ? (_order!.status == 'CANCELLED' ? Colors.red : AppColors.primary)
            : Colors.grey,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Qty: ${item.quantity}",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            "₹${item.priceAtPurchase.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, double amount) {
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
