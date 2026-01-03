class ProductModel {
  final int id;
  final String name;
  final String category;
  final String unit;
  final double price;
  final int stock;
  final String description;
  final String imageUrl;

  // New fields matching your API response
  final bool active;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    required this.stock,
    required this.description,
    required this.imageUrl,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      // Safely handle Number types (int or double)
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',

      // Mapping the new fields
      active: json['active'] ?? false, // Default to false for safety
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}