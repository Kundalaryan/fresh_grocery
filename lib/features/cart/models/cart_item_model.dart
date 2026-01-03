// 1. Model for the UI (The list of items visible in the cart)
class CartItemModel {
  final int productId;
  final String name;
  final String imageUrl;
  final double price;
  int quantity; // Mutable because we can change it in the UI

  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}

// 2. Model for the API Request Body
class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}