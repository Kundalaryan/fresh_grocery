import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/orders_repository.dart';
import '../models/order_details_model.dart';
import 'widgets/cancel_order_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId; // We need ID to fetch data

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

  @override
  @override
  Widget build(BuildContext context) {
    // 1. WRAP IN POPSCOPE
    // This handles the Android System Back Button/Gesture
    return PopScope(
      canPop: false, // We disable auto-pop so we can manually send data back
      onPopInvoked: (didPop) {
        if (didPop) return;
        // When system back is pressed, return the _hasChanges flag
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
            // 2. UPDATE APP BAR BACK BUTTON
            // When arrow is clicked, return the _hasChanges flag
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: Text(
            "Order #${widget.orderId}",
            style: const TextStyle( // Added const for optimization
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : _order == null
            ? const Center(child: Text("Order not found"))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STATUS HEADER
              Text(
                _getMainStatusText(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // 2. TIMELINE PROGRESS BAR
              _buildTimelineWidget(),

              const SizedBox(height: 40),

              // 3. ITEMS LIST HEADER
              const Text(
                "Your Items",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // 4. DYNAMIC ITEMS LIST
              ..._order!.items.map((item) => _buildItemRow(item)),

              const SizedBox(height: 20),
              const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 20),

              // 5. BILLING SECTION
              _buildPricingRow("Subtotal", _order!.subtotal),
              const SizedBox(height: 12),
              // Assuming remaining amount is fees since API gives total
              _buildPricingRow("Delivery & Service Fee", _order!.fees),

              const SizedBox(height: 20),
              const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),

              // TOTAL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "\$${_order!.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary, // Blue
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 6. ACTION BUTTONS
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to view receipt or re-download
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View Receipt",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Only show Cancel button if status is NOT Cancelled or Delivered
              if (_order!.status != 'CANCELLED' && _order!.status != 'DELIVERED')
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    // CONNECT THE FUNCTION HERE
                    onPressed: _showCancelDialog,

                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel Order",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  // --- HELPER WIDGETS ---

  // Decide headline based on status
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
    // Simple logic:
    // Placed = 33%, Shipped = 66%, Delivered = 100%
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
            Text("Arriving in 15 mins",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            // Mock Data
            Text("12:45 PM", style: TextStyle(color: Colors.grey)),
            // Mock Data
          ],
        ),
        const SizedBox(height: 12),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[100],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        // Labels
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
        fontSize: 12,
        color: isActive ? AppColors.primary : Colors.grey,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder (API missing Image URL)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${item.priceAtPurchase.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
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
                      SnackBar(content: Text(response.message),
                          backgroundColor: Colors.green),
                    );

                    // MARK AS CHANGED
                    setState(() {
                      _hasChanges = true;
                    });

                    _fetchDetails(); // Refresh current screen UI
                  } else {
                    // ... error handling
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}