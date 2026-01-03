class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  // Factory constructor to parse JSON
  // "T" is the type of data (e.g., User, Product, List<Product>)
  // "fromJsonT" is a function that tells us how to parse "data" specifically
  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      // If data is null, return null. Otherwise, use the parsing function.
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}