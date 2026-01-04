class OrderDetailsModel {
  final int orderId;
  final String status;
  final double totalAmount;
  final String createdAt;
  final List<OrderItem> items;
  final List<TimelineItem> timeline;

  OrderDetailsModel({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
    required this.timeline,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      orderId: json['orderId'] ?? 0,
      status: json['status'] ?? 'UNKNOWN',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] ?? '',
      items: (json['items'] as List?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ??
          [],
      timeline: (json['timeline'] as List?)
          ?.map((e) => TimelineItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  // Helper: Calculate Subtotal from items
  double get subtotal {
    return items.fold(0, (sum, item) => sum + (item.priceAtPurchase * item.quantity));
  }

  // Helper: Calculate Fees (Total - Subtotal)
  double get fees => totalAmount - subtotal;
}

class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double priceAtPurchase;

  // Note: API doesn't provide ImageURL or Description yet,
  // so we will handle that gracefully in UI

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? 'Unknown Item',
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TimelineItem {
  final String status;
  final String timestamp;

  TimelineItem({required this.status, required this.timestamp});

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}