import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../data/orders_repository.dart';

class OrderHelpScreen extends StatefulWidget {
  final int orderId;

  const OrderHelpScreen({super.key, required this.orderId});

  @override
  State<OrderHelpScreen> createState() => _OrderHelpScreenState();
}

class _OrderHelpScreenState extends State<OrderHelpScreen> {
  final OrdersRepository _repository = OrdersRepository();
  final TextEditingController _descController = TextEditingController();

  bool _isLoading = false;
  String? _selectedIssueType;

  // Enum Mapping
  final Map<String, String> _issueTypes = {
    "NOT_RECEIVED": "Order not received",
    "PARTIAL_MISSING": "Items missing from order",
    "WRONG_ITEMS": "Received wrong items",
    "DAMAGED_ITEMS": "Items were damaged",
    "DELIVERED_TO_WRONG_PERSON": "Delivered to wrong person",
  };

  Future<void> _submitIssue() async {
    if (_selectedIssueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a reason")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await _repository.reportIssue(
      widget.orderId,
      _selectedIssueType!,
      _descController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully! Support will contact you."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to Order Details
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help for Order #${widget.orderId}",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. DROPDOWN SECTION
                  Text(
                    "HELP REASON",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    value: _selectedIssueType,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    hint: Text("Select a reason", style: TextStyle(color: Colors.black87, fontSize: 16.sp)),
                    style: TextStyle(fontSize: 16.sp, color: Colors.black, fontFamily: 'PlusJakartaSans'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB), // Light grey
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _issueTypes.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedIssueType = val),
                  ),

                  SizedBox(height: 24.h),

                  // 2. DESCRIPTION SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DESCRIPTION",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Optional",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _descController,
                    maxLines: 5,
                    style: TextStyle(fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: "Tell us more about the problem...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(16.r),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 3. INFO CARD
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD).withOpacity(0.5), // Very Light Blue
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            "Our support team typically responds within 30 minutes for active orders.",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF1565C0), // Darker Blue text
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. SUBMIT BUTTON (Fixed at bottom)
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  "Submit Report",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}