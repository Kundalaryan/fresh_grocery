class OrderModel {
  final int id;
  final String status; // ORDER_PLACED, DELIVERED, CANCELLED
  final double totalAmount;
  final String createdAt;

  // Extra fields from API if you need them later:
  final String customerName;
  final String address;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.customerName,
    required this.address,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      // Handle int or double for price
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? '',
      customerName: json['customerName'] ?? '',
      address: json['address'] ?? '',
    );
  }

  // Helper to get readable date (Simple implementation)
  // Input: 2026-01-03T13:43:25.552Z -> Output: Jan 03
  String get formattedDate {
    if (createdAt.isEmpty) return "";
    try {
      final DateTime date = DateTime.parse(createdAt);
      final List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return "${months[date.month - 1]} ${date.day}";
    } catch (e) {
      return createdAt;
    }
  }

  // Helper to map API Status to UI text
  String get uiStatus {
    switch (status) {
      case 'ORDER_PLACED': return 'Processing';
      case 'DELIVERED': return 'Delivered';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }
}